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

  static const Color lila     = Color(0xFF8B5CF6);
  static const Color lilaOsc  = Color(0xFF6D28D9);
  static const Color fondo    = Color(0xFFF3EEFF);

  String get _saludo {
    switch (rol) {
      case 'entrenador': return '¡Listo para entrenar, ${nombre.split(' ').first}!';
      case 'arbitro':    return '¡Bienvenido árbitro, ${nombre.split(' ').first}!';
      default:           return '¡Hola, ${nombre.split(' ').first}!';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(slivers: [
      _buildAppBar(context),
      SliverPadding(
        padding: const EdgeInsets.all(16),
        sliver: SliverList(delegate: SliverChildListDelegate([
          StatsRow(uid: uid, rol: rol),
          const SizedBox(height: 20),
          if (rol == 'arbitro') ...[
            const SeccionTitulo(titulo: 'Mis partidos', icono: Icons.sports_soccer, color: lila),
            const SizedBox(height: 10),
            PartidosList(uid: uid, soloArbitro: true),
          ],
          if (rol == 'entrenador') ...[
            const SeccionTitulo(titulo: 'Próximas reservas', icono: Icons.calendar_today, color: lila),
            const SizedBox(height: 10),
            ProximasReservas(uid: uid),
            const SizedBox(height: 20),
            const SeccionTitulo(titulo: 'Partidos de mis equipos', icono: Icons.sports_soccer, color: lilaOsc),
            const SizedBox(height: 10),
            PartidosEntrenador(uid: uid),
          ],
          if (rol == 'jugador') ...[
            const SeccionTitulo(titulo: 'Próximas reservas', icono: Icons.calendar_today, color: lila),
            const SizedBox(height: 10),
            ProximasReservas(uid: uid),
          ],
          const SizedBox(height: 80),
        ])),
      ),
    ]);
  }

  SliverAppBar _buildAppBar(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 170,
      floating: false,
      pinned: true,
      automaticallyImplyLeading: false,
      backgroundColor: lila,
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
              colors: [Color(0xFF6D28D9), Color(0xFF8B5CF6), Color(0xFFBEA6FF)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 50, 20, 0),
              child: Row(children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor: Colors.white.withOpacity(0.3),
                  child: Text(
                    nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
                    style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
                    Text(_saludo, style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(rol.toUpperCase(),
                          style: TextStyle(color: Colors.white.withOpacity(0.95), fontSize: 11,
                              fontWeight: FontWeight.bold, letterSpacing: 1)),
                    ),
                  ]),
                ),
              ]),
            ),
          ),
        ),
      ),
    );
  }
}