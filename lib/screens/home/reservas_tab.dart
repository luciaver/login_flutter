import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../home_widgets.dart';

class ReservasTab extends StatelessWidget {
  final String uid;
  const ReservasTab({super.key, required this.uid});

  static const Color rosa     = Color(0xFF8B5CF6);
  static const Color rosaDark = Color(0xFF8B5CF6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EEFF),
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
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: rosa));
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final docs = snapshot.data?.docs ?? [];

          if (docs.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.calendar_today_outlined, size: 72, color: rosa.withOpacity(0.3)),
                const SizedBox(height: 16),
                const Text('No tienes reservas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Color(0xFF8B5CF6))),
                const SizedBox(height: 8),
                Text('Ve a la pestaña Pistas para reservar',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              ]),
            );
          }

          final sorted = List.of(docs);
          sorted.sort((a, b) {
            final fa = (a.data() as Map<String, dynamic>)['fecha'] as String? ?? '';
            final fb = (b.data() as Map<String, dynamic>)['fecha'] as String? ?? '';
            return fb.compareTo(fa);
          });

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: sorted.length,
            itemBuilder: (context, i) {
              final data = sorted[i].data() as Map<String, dynamic>;
              return ReservaCard(data: data);
            },
          );
        },
      ),
    );
  }
}