import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class UserProvider extends ChangeNotifier {
  final _db   = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  String _filtroRol = 'todos';
  String get filtroRol => _filtroRol;

  void cambiarFiltroRol(String v) {
    _filtroRol = v;
    notifyListeners();
  }

  Stream<QuerySnapshot> obtenerUsuarios() {
    if (_filtroRol == 'todos') return _db.collection('usuarios').snapshots();
    return _db.collection('usuarios').where('rol', isEqualTo: _filtroRol).snapshots();
  }

  Future<bool> agregarUsuario({
    required String nombre,
    required String email,
    required String password,
    required String rol,
    required String fechaNacimiento,
    required String telefono,
    String? posicion,
    String? equipoId,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final uid = cred.user!.uid;

      final data = <String, dynamic>{
        'nombre': nombre,
        'email': email,
        'rol': rol,
        'fechaNacimiento': fechaNacimiento,
        'telefono': telefono,
      };
      if (rol == 'jugador' && posicion != null) data['posicion'] = posicion;
      if (equipoId != null) data['equipo'] = equipoId;

      await _db.collection('usuarios').doc(uid).set(data);

      if (equipoId != null) {
        await _asignarUsuarioAEquipo(uid: uid, equipoId: equipoId, rol: rol);
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> editarUsuario({
    required String userId,
    required String nombre,
    required String rol,
    required String fechaNacimiento,
    required String telefono,
    String? posicion,
    String? equipoId,
  }) async {
    try {
      final docActual = await _db.collection('usuarios').doc(userId).get();
      final equipoAnterior = (docActual.data() as Map<String, dynamic>?)?['equipo'] as String?;

      final data = <String, dynamic>{
        'nombre': nombre,
        'rol': rol,
        'fechaNacimiento': fechaNacimiento,
        'telefono': telefono,
      };

      if (rol == 'jugador') {
        if (posicion != null) data['posicion'] = posicion;
      } else {
        data['posicion'] = FieldValue.delete();
      }

      if (equipoId != null) {
        data['equipo'] = equipoId;
      } else {
        data['equipo'] = FieldValue.delete();
      }

      await _db.collection('usuarios').doc(userId).update(data);

      if (equipoAnterior != equipoId) {
        // Quitar del equipo anterior
        if (equipoAnterior != null) {
          await _quitarUsuarioDeEquipo(uid: userId, equipoId: equipoAnterior, rol: rol);
        }
        // Añadir al nuevo equipo
        if (equipoId != null) {
          await _asignarUsuarioAEquipo(uid: userId, equipoId: equipoId, rol: rol);
        }
      }

      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _asignarUsuarioAEquipo({
    required String uid,
    required String equipoId,
    required String rol,
  }) async {
    if (rol == 'jugador') {
      await _db.collection('equipos').doc(equipoId).update({
        'jugadoresIds': FieldValue.arrayUnion([uid]),
      });
    } else if (rol == 'entrenador') {
      await _db.collection('equipos').doc(equipoId).update({
        'entrenadorId': uid,
      });
    }
  }

  Future<void> _quitarUsuarioDeEquipo({
    required String uid,
    required String equipoId,
    required String rol,
  }) async {
    try {
      if (rol == 'jugador') {
        await _db.collection('equipos').doc(equipoId).update({
          'jugadoresIds': FieldValue.arrayRemove([uid]),
        });
      } else if (rol == 'entrenador') {
        await _db.collection('equipos').doc(equipoId).update({
          'entrenadorId': FieldValue.delete(),
        });
      }
    } catch (_) {}
  }

  Future<bool> eliminarUsuario(String userId) async {
    try {
      final doc = await _db.collection('usuarios').doc(userId).get();
      final data = doc.data() as Map<String, dynamic>?;
      final equipoId = data?['equipo'] as String?;
      final rol = data?['rol'] as String? ?? '';
      if (equipoId != null) {
        await _quitarUsuarioDeEquipo(uid: userId, equipoId: equipoId, rol: rol);
      }
      await _db.collection('usuarios').doc(userId).delete();
      return true;
    } catch (_) {
      return false;
    }
  }
}