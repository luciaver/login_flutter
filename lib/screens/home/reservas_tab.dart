import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_widgets.dart';

class ReservasTab extends StatelessWidget {
  final String uid;
  const ReservasTab({super.key, required this.uid});

  static const Color rosa     = Color(0xFFEC4899);
  static const Color rosaDark = Color(0xFFDB2777);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F6),
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        backgroundColor: rosaDark,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reservas')
            .where('usuarioId', isEqualTo: uid)
            .orderBy('fecha')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: rosa));
          }
          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.calendar_today_outlined, size: 72, color: rosa.withOpacity(0.3)),
                const SizedBox(height: 16),
                const Text('No tienes reservas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFFEC4899))),
                const SizedBox(height: 8),
                Text('Ve a la pestaña Pistas para reservar',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              ]),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: docs.length,
            itemBuilder: (context, i) {
              final data = docs[i].data() as Map<String, dynamic>;
              return ReservaCard(data: data);
            },
          );
        },
      ),
    );
  }
}