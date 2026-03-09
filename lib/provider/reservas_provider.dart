import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservasProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> obtenerReservas() =>
      _db.collection('reservas').orderBy('fecha', descending: true).snapshots();

  Future<bool> cambiarEstado(String id, String nuevoEstado) async {
    try {
      await _db.collection('reservas').doc(id).update({'estado': nuevoEstado});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> eliminarReserva(String id) async {
    try {
      await _db.collection('reservas').doc(id).delete();
      return true;
    } catch (_) {
      return false;
    }
  }
}