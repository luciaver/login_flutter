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

  static const Color rosa     = Color(0xFFEC4899);
  static const Color rosaDark = Color(0xFFDB2777);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F6),
      appBar: AppBar(
        title: const Text('GesSport - Admin'),
        backgroundColor: rosaDark,
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
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFDB2777), Color(0xFFEC4899), Color(0xFFF472B6)],
                begin: Alignment.topLeft, end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(children: [
              const CircleAvatar(
                backgroundColor: Colors.white30,
                child: Icon(Icons.admin_panel_settings, color: Colors.white),
              ),
              const SizedBox(width: 12),
              Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('Dashboard Administrativo',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white)),
                Text('Gestiona todos los recursos',
                    style: TextStyle(fontSize: 12, color: Colors.white.withOpacity(0.85))),
              ]),
            ]),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              crossAxisSpacing: 14,
              mainAxisSpacing: 14,
              children: [
                _card(context, 'Usuarios',      Icons.people,          const Color(0xFFEC4899), const UsersManagementScreen()),
                _card(context, 'Equipos',       Icons.groups,          const Color(0xFFDB2777), const EquiposScreen()),
                _card(context, 'Reservas',      Icons.calendar_today,  const Color(0xFFF472B6), const ReservasAdminScreen()),
                _card(context, 'Instalaciones', Icons.sports_tennis,   const Color(0xFFBE185D), const InstalacionesScreen()),
                _card(context, 'Partidos',      Icons.sports_soccer,   const Color(0xFF9D174D), const PartidosScreen()),
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
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: InkWell(
        onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => screen)),
        borderRadius: BorderRadius.circular(18),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            gradient: LinearGradient(
              begin: Alignment.topLeft, end: Alignment.bottomRight,
              colors: [color.withOpacity(0.75), color],
            ),
          ),
          child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(icono, size: 40, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(titulo,
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.white)),
          ]),
        ),
      ),
    );
  }
}