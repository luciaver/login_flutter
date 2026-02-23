import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../home_widgets.dart';


class EquipoTab extends StatelessWidget {
  final String uid;
  final String rol;
  const EquipoTab({super.key, required this.uid, required this.rol});

  Stream<QuerySnapshot> get _stream => rol == 'entrenador'
      ? FirebaseFirestore.instance.collection('equipos').where('entrenadorId', isEqualTo: uid).snapshots()
      : FirebaseFirestore.instance.collection('equipos').where('jugadoresIds', arrayContains: uid).snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        title: Text(rol == 'entrenador' ? 'Mis Equipos' : 'Mi Equipo'),
        backgroundColor: const Color(0xFF6B4CE6),
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const CardVacia(texto: 'Sin equipo asignado');
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final doc = docs[i];
              return EquipoDetalleCard(
                equipoId: doc.id,
                data: doc.data() as Map<String, dynamic>,
                rol: rol,
                uid: uid,
              );
            },
          );
        },
      ),
    );
  }
}