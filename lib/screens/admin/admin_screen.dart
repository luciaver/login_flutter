import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import ' users_management_screen.dart';
import '../login_screen.dart';
import 'equipos_screen.dart';
import 'instalaciones_screen.dart';
import 'reservas_admin_screen.dart';
import 'partidos_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  static const Color fondoApp    = Color(0xFFF4F4F4);
  static const Color appBarColor = Color(0xFFAD1457);
  static const Color cardColor   = Color(0xFFF48FB1);
  static const Color iconCircle  = Color(0xFFFFFFFF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondoApp,
      appBar: AppBar(
        title: const Text('GesSport - Admin'),
        backgroundColor: appBarColor,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (!context.mounted) return;
              Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen()));
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(children: [
          const SizedBox(height: 10),
          const Text(
            'Gestión administrativa',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: Color(0xFF880E4F),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _card(context, 'Usuarios',      Icons.people,          const UsersManagementScreen()),
                _card(context, 'Equipos',       Icons.groups,          const EquiposScreen()),
                _card(context, 'Reservas',      Icons.calendar_today,  const ReservasAdminScreen()),
                _card(context, 'Instalaciones', Icons.sports_tennis,   const InstalacionesScreen()),
                _card(context, 'Partidos',      Icons.sports_soccer,   const PartidosScreen()),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _card(BuildContext context, String titulo, IconData icono, Widget screen) {
    return Card(
      elevation: 3,
      color: cardColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
        borderRadius: BorderRadius.circular(18),
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              shape: BoxShape.circle,
            ),
            child: Icon(icono, size: 38, color: Colors.black87),
          ),
          const SizedBox(height: 12),
          Text(
            titulo,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
        ]),
      ),
    );
  }
}