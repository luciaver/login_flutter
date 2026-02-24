import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../home_widgets.dart';
import '../login_screen.dart';

class PerfilTab extends StatelessWidget {
  final String nombre;
  final String rol;
  final String uid;
  const PerfilTab({super.key, required this.nombre, required this.rol, required this.uid});

  static const Color rosa     = Color(0xFFEC4899);
  static const Color rosaDark = Color(0xFFDB2777);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F6),
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('usuarios').doc(uid).get(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          return CustomScrollView(
            slivers: [
              _buildAppBar(context),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    PerfilInfoCard(data: data),
                    const SizedBox(height: 16),
                    const SeccionTitulo(titulo: 'Mis incidencias', icono: Icons.warning_amber_outlined, color: rosaDark),
                    const SizedBox(height: 10),
                    IncidenciasList(uid: uid),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 220,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: rosaDark,
      actions: [
        IconButton(
          icon: const Icon(Icons.logout, color: Colors.white),
          onPressed: () async {
            await FirebaseAuth.instance.signOut();
            if (!context.mounted) return;
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const LoginScreen()));
          },
        ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFDB2777), Color(0xFFEC4899), Color(0xFFF472B6)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 44,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: Text(
                    nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
                    style: const TextStyle(fontSize: 38, color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(height: 10),
                Text(nombre,
                    style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    rol.toUpperCase(),
                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold, letterSpacing: 1.2),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}