import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InstalacionesProvider extends ChangeNotifier {
  final _db = FirebaseFirestore.instance;

  Stream<QuerySnapshot> obtenerPistas() =>
      _db.collection('pistas').snapshots();

  Future<bool> agregarPista({
    required String nombre,
    required String tipo,
    required String precio,
  }) async {
    try {
      await _db.collection('pistas').add({
        'nombre': nombre,
        'tipo': tipo,
        'precio': precio,
        'disponible': true,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> editarPista({
    required String id,
    required String nombre,
    required String tipo,
    required String precio,
  }) async {
    try {
      await _db.collection('pistas').doc(id).update({
        'nombre': nombre,
        'tipo': tipo,
        'precio': precio,
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> toggleDisponible(String id, bool valor) async {
    try {
      await _db.collection('pistas').doc(id).update({'disponible': valor});
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<bool> eliminarPista(String id) async {
    try {
      await _db.collection('pistas').doc(id).delete();
      return true;
    } catch (_) {
      return false;
    }
  }
}