import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'home_widgets.dart';


// Esta pantalla muestra TODAS las reservas que tiene el usuario.
// Es diferente a ReservarPistaScreen (que es para CREAR una reserva nueva).

class ReservasScreen extends StatelessWidget {
  final String uid;
  const ReservasScreen({super.key, required this.uid});

  static const Color morado = Color(0xFF6B4CE6);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        backgroundColor: morado,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reservas')
            .where('usuarioId', isEqualTo: uid)
            .orderBy('fecha', descending: false)
            .snapshots(),
        builder: (context, snap) {
          // Mientras carga
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          // Sin reservas
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No tienes reservas', style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Ve a la pestaña Pistas para reservar',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                ],
              ),
            );
          }

          // Lista de reservas
          final reservas = snap.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reservas.length,
            itemBuilder: (context, i) {
              final data = reservas[i].data() as Map<String, dynamic>;
              return ReservaCard(data: data);
            },
          );
        },
      ),
    );
  }
}