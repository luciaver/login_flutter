import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EquiposProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> obtenerEquipos() =>
      _db.collection('equipos').snapshots();

  Future<bool> agregarEquipo({
    required String nombre,
    required String deporte,
    String? entrenadorId,
  }) async {
    try {
      await _db.collection('equipos').add({
        'nombre': nombre,
        'deporte': deporte,
        'jugadoresIds': [],
        if (entrenadorId != null) 'entrenadorId': entrenadorId,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> editarEquipo({
    required String id,
    required String nombre,
    required String deporte,
    String? entrenadorId,
  }) async {
    try {
      await _db.collection('equipos').doc(id).update({
        'nombre': nombre,
        'deporte': deporte,
        'entrenadorId': entrenadorId ?? FieldValue.delete(),
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> eliminarEquipo(String id) async {
    try {
      await _db.collection('equipos').doc(id).delete();
      return true;
    } catch (_) {
      return false;
    }
  }
}