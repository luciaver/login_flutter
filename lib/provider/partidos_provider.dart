import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PartidosProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> obtenerPartidos() =>
      _db.collection('partidos').orderBy('fecha', descending: true).snapshots();

  Future<bool> crearPartido({
    required String equipoLocalId,
    required String equipoVisitanteId,
    required DateTime fechaHora,
    required String estado,
    String? arbitroId,
    int? golLocal,
    int? golVisitante,
  }) async {
    try {
      await _db.collection('partidos').add({
        'equipoLocalId': equipoLocalId,
        'equipoVisitanteId': equipoVisitanteId,
        'fecha': fechaHora.toIso8601String(),
        'estado': estado,
        if (arbitroId != null) 'arbitroId': arbitroId,
        if (golLocal != null) 'golLocal': golLocal,
        if (golVisitante != null) 'golVisitante': golVisitante,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> editarPartido({
    required String id,
    required String equipoLocalId,
    required String equipoVisitanteId,
    required DateTime fechaHora,
    required String estado,
    String? arbitroId,
    int? golLocal,
    int? golVisitante,
  }) async {
    try {
      await _db.collection('partidos').doc(id).update({
        'equipoLocalId': equipoLocalId,
        'equipoVisitanteId': equipoVisitanteId,
        'fecha': fechaHora.toIso8601String(),
        'estado': estado,
        'arbitroId': arbitroId ?? FieldValue.delete(),
        if (golLocal != null) 'golLocal': golLocal,
        if (golVisitante != null) 'golVisitante': golVisitante,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> eliminarPartido(String id) async {
    try {
      await _db.collection('partidos').doc(id).delete();
      return true;
    } catch (_) {
      return false;
    }
  }
}