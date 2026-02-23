import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../home_widgets.dart';
import '../login_screen.dart';

class InicioTab extends StatelessWidget {
  final String rol;
  final String nombre;
  final String uid;

  const InicioTab({super.key, required this.rol, required this.nombre, required this.uid});

  static const Color morado = Color(0xFF6B4CE6);
  static const Color rosa = Color(0xFFE91E8C);

  String get _saludo {
    switch (rol) {
      case 'entrenador': return '¡Listo para entrenar, ${nombre.split(' ').first}!';
      case 'arbitro':    return '¡Bienvenido árbitro, ${nombre.split(' ').first}!';
      default:           return '¡Hola, ${nombre.split(' ').first}!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        _buildAppBar(context),
        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              StatsRow(uid: uid, rol: rol),
              const SizedBox(height: 20),
              if (rol == 'arbitro') ...[
                SeccionTitulo(titulo: 'Mis partidos', icono: Icons.sports_soccer, color: const Color(0xFF8B5CF6)),
                const SizedBox(height: 10),
                PartidosList(uid: uid, soloArbitro: true),
              ],
              if (rol == 'entrenador') ...[
                SeccionTitulo(titulo: 'Próximas reservas', icono: Icons.calendar_today, color: morado),
                const SizedBox(height: 10),
                ProximasReservas(uid: uid),
                const SizedBox(height: 20),
                SeccionTitulo(titulo: 'Partidos de mis equipos', icono: Icons.sports_soccer, color: rosa),
                const SizedBox(height: 10),
                PartidosEntrenador(uid: uid),
                const SizedBox(height: 20),
                SeccionTitulo(titulo: 'Incidencias', icono: Icons.warning_amber_outlined, color: rosa),
                const SizedBox(height: 10),
                BotonIncidencia(uid: uid, tipo: 'entrenamiento_cancelado'),
              ],
              if (rol == 'jugador') ...[
                SeccionTitulo(titulo: 'Próximas reservas', icono: Icons.calendar_today, color: morado),
                const SizedBox(height: 10),
                ProximasReservas(uid: uid),
                const SizedBox(height: 20),
                SeccionTitulo(titulo: 'Incidencias', icono: Icons.warning_amber_outlined, color: rosa),
                const SizedBox(height: 10),
                BotonIncidencia(uid: uid, tipo: 'no_asistencia'),
              ],
              const SizedBox(height: 80),
            ]),
          ),
        ),
      ],
    );
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 170,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: morado,
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
              colors: [Color(0xFF6B4CE6), Color(0xFFE91E8C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 26,
                    backgroundColor: Colors.white.withOpacity(0.3),
                    child: Text(nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
                        style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold)),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(_saludo,
                            style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(rol.toUpperCase(),
                            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12)),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}