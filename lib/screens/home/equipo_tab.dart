import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_widgets.dart';

class EquipoTab extends StatelessWidget {
  final String uid;
  final String rol;
  const EquipoTab({super.key, required this.uid, required this.rol});

  static const Color lila    = Color(0xFF8B5CF6);
  static const Color lilaOsc = Color(0xFF6D28D9);

  Stream<QuerySnapshot> get _stream => rol == 'entrenador'
      ? FirebaseFirestore.instance.collection('equipos').where('entrenadorId', isEqualTo: uid).snapshots()
      : FirebaseFirestore.instance.collection('equipos').where('jugadoresIds', arrayContains: uid).snapshots();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EEFF),
      appBar: AppBar(
        title: Text(rol == 'entrenador' ? 'Mis Equipos' : 'Mi Equipo'),
        backgroundColor: lila,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: _stream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: lila));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.groups_outlined, size: 72, color: lila.withOpacity(0.3)),
                const SizedBox(height: 16),
                const Text('Sin equipo asignado',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: lila)),
                const SizedBox(height: 8),
                Text('Contacta con el administrador',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              ]),
            );
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