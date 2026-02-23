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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: AppBar(
        title: const Text('GesSport - Admin'),
        backgroundColor: const Color(0xFFD946EF),
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
        padding: const EdgeInsets.all(16),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Dashboard Administrativo',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Color(0xFFD946EF))),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              children: [
                _card(context, 'Usuarios',      Icons.people,          const Color(0xFFD946EF), const UsersManagementScreen()),
                _card(context, 'Equipos',       Icons.groups,          const Color(0xFF7C3AED), const EquiposScreen()),
                _card(context, 'Reservas',      Icons.calendar_today,  const Color(0xFFA855F7), const ReservasAdminScreen()),
                _card(context, 'Instalaciones', Icons.sports_tennis,   const Color(0xFFEC4899), const InstalacionesScreen()),
                _card(context, 'Partidos',      Icons.sports_soccer,   const Color(0xFFF0ABFC), const PartidosScreen()),
              ],
            ),
          ),
        ]),
      ),
    );
  }

  Widget _card(BuildContext context, String titulo, IconData icono, Color color, Widget screen) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [color.withOpacity(0.7), color],
            ),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Icon(icono, size: 58, color: Colors.white),
            const SizedBox(height: 10),
            Text(titulo, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: Colors.white)),
          ]),
        ),
      ),
    );
  }
}