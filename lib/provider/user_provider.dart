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
    String? equipo,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(email: email, password: password);
      final data = <String, dynamic>{
        'nombre': nombre, 'email': email, 'rol': rol,
        'fechaNacimiento': fechaNacimiento, 'telefono': telefono,
      };
      if (rol == 'jugador' && posicion != null) data['posicion'] = posicion;
      if (rol != 'jugador' && equipo != null && equipo.isNotEmpty) data['equipo'] = equipo;
      await _db.collection('usuarios').doc(cred.user!.uid).set(data);
      return true;
    } catch (_) { return false; }
  }

  Future<bool> editarUsuario({
    required String userId,
    required String nombre,
    required String rol,
    required String fechaNacimiento,
    required String telefono,
    String? posicion,
    String? equipo,
  }) async {
    try {
      final data = <String, dynamic>{
        'nombre': nombre, 'rol': rol,
        'fechaNacimiento': fechaNacimiento, 'telefono': telefono,
      };
      if (rol == 'jugador') {
        if (posicion != null) data['posicion'] = posicion;
        data['equipo'] = FieldValue.delete();
      } else {
        data['posicion'] = FieldValue.delete();
        if (equipo != null && equipo.isNotEmpty) data['equipo'] = equipo;
        else data['equipo'] = FieldValue.delete();
      }
      await _db.collection('usuarios').doc(userId).update(data);
      return true;
    } catch (_) { return false; }
  }

  Future<bool> eliminarUsuario(String userId) async {
    try {
      await _db.collection('usuarios').doc(userId).delete();
      return true;
    } catch (_) { return false; }
  }
}