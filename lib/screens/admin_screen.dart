import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';

class AdminScreen extends StatelessWidget {
  const AdminScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    try {
      await FirebaseAuth.instance.signOut();

      if (!context.mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('GesSport - Admin'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Dashboard Administrativo',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.green.shade700,
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: [
                  _buildCard(context, 'Usuarios', Icons.people, Colors.blue, true),
                  _buildCard(context, 'Pistas', Icons.sports_tennis, Colors.orange, false),
                  _buildCard(context, 'Reservas', Icons.calendar_today, Colors.purple, false),
                  _buildCard(context, 'Partidos', Icons.sports_soccer, Colors.red, false),
                  _buildCard(context, 'Equipos', Icons.groups, Colors.teal, false),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCard(BuildContext context, String title, IconData icon, Color color, bool enabled) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: () {
          if (enabled) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => const UsersManagementScreen()),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Sección de $title próximamente')),
            );
          }
        },
        borderRadius: BorderRadius.circular(16),
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [color.withOpacity(0.7), color],
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 60, color: Colors.white),
              const SizedBox(height: 12),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// PANTALLA DE GESTIÓN DE USUARIOS
class UsersManagementScreen extends StatefulWidget {
  const UsersManagementScreen({super.key});

  @override
  State<UsersManagementScreen> createState() => _UsersManagementScreenState();
}

class _UsersManagementScreenState extends State<UsersManagementScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String _filtroRol = 'todos';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filtro
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text('Filtrar: ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: _filtroRol,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'todos', child: Text('Todos')),
                      DropdownMenuItem(value: 'jugador', child: Text('Jugadores')),
                      DropdownMenuItem(value: 'entrenador', child: Text('Entrenadores')),
                      DropdownMenuItem(value: 'arbitro', child: Text('Árbitros')),
                      DropdownMenuItem(value: 'admin', child: Text('Admins')),
                    ],
                    onChanged: (value) {
                      setState(() {
                        _filtroRol = value!;
                      });
                    },
                  ),
                ),
              ],
            ),
          ),

          // Lista de usuarios
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _filtroRol == 'todos'
                  ? _firestore.collection('usuarios').snapshots()
                  : _firestore.collection('usuarios').where('rol', isEqualTo: _filtroRol).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No hay usuarios'));
                }

                final usuarios = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: usuarios.length,
                  itemBuilder: (context, index) {
                    final doc = usuarios[index];
                    final data = doc.data() as Map<String, dynamic>;
                    final nombre = data['nombre'] ?? 'Sin nombre';
                    final email = data['email'] ?? 'Sin email';
                    final rol = data['rol'] ?? 'Sin rol';

                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: ListTile(
                        leading: CircleAvatar(
                          backgroundColor: _getColor(rol),
                          child: Icon(_getIcon(rol), color: Colors.white),
                        ),
                        title: Text(nombre),
                        subtitle: Text('$email\nRol: ${rol.toUpperCase()}'),
                        isThreeLine: true,
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit, color: Colors.blue),
                              onPressed: () => _editUser(doc.id, nombre, email, rol),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteUser(doc.id, nombre),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addUser,
        backgroundColor: Colors.green.shade700,
        child: const Icon(Icons.add),
      ),
    );
  }

  Color _getColor(String rol) {
    switch (rol) {
      case 'jugador': return Colors.blue;
      case 'entrenador': return Colors.orange;
      case 'arbitro': return Colors.purple;
      case 'admin': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getIcon(String rol) {
    switch (rol) {
      case 'jugador': return Icons.sports_soccer;
      case 'entrenador': return Icons.sports;
      case 'arbitro': return Icons.sports_score;
      case 'admin': return Icons.admin_panel_settings;
      default: return Icons.person;
    }
  }

  void _addUser() {
    final nombreCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String selectedRol = 'jugador';

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Añadir Usuario'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: Icon(Icons.person),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Email',
                    prefixIcon: Icon(Icons.email),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordCtrl,
                  decoration: const InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: Icon(Icons.lock),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                DropdownButton<String>(
                  value: selectedRol,
                  isExpanded: true,
                  items: const [
                    DropdownMenuItem(value: 'jugador', child: Text('Jugador')),
                    DropdownMenuItem(value: 'entrenador', child: Text('Entrenador')),
                    DropdownMenuItem(value: 'arbitro', child: Text('Árbitro')),
                    DropdownMenuItem(value: 'admin', child: Text('Admin')),
                  ],
                  onChanged: (value) => setState(() => selectedRol = value!),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  UserCredential userCred = await FirebaseAuth.instance.createUserWithEmailAndPassword(
                    email: emailCtrl.text.trim(),
                    password: passwordCtrl.text,
                  );

                  await _firestore.collection('usuarios').doc(userCred.user!.uid).set({
                    'nombre': nombreCtrl.text.trim(),
                    'email': emailCtrl.text.trim(),
                    'rol': selectedRol,
                  });

                  Navigator.pop(context);
                  _showMessage('Usuario añadido', Colors.green);
                } catch (e) {
                  _showMessage('Error: ${e.toString()}', Colors.red);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Añadir'),
            ),
          ],
        ),
      ),
    );
  }

  void _editUser(String userId, String currentNombre, String currentEmail, String currentRol) {
    final nombreCtrl = TextEditingController(text: currentNombre);
    String selectedRol = currentRol;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Editar Usuario'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nombreCtrl,
                decoration: const InputDecoration(
                  labelText: 'Nombre',
                  prefixIcon: Icon(Icons.person),
                ),
              ),
              const SizedBox(height: 16),
              Text('Email: $currentEmail'),
              const SizedBox(height: 16),
              DropdownButton<String>(
                value: selectedRol,
                isExpanded: true,
                items: const [
                  DropdownMenuItem(value: 'jugador', child: Text('Jugador')),
                  DropdownMenuItem(value: 'entrenador', child: Text('Entrenador')),
                  DropdownMenuItem(value: 'arbitro', child: Text('Árbitro')),
                  DropdownMenuItem(value: 'admin', child: Text('Admin')),
                ],
                onChanged: (value) => setState(() => selectedRol = value!),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                try {
                  await _firestore.collection('usuarios').doc(userId).update({
                    'nombre': nombreCtrl.text.trim(),
                    'rol': selectedRol,
                  });

                  Navigator.pop(context);
                  _showMessage('Usuario actualizado', Colors.green);
                } catch (e) {
                  _showMessage('Error: ${e.toString()}', Colors.red);
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Guardar'),
            ),
          ],
        ),
      ),
    );
  }

  void _deleteUser(String userId, String nombre) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: Text('¿Eliminar a $nombre?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await _firestore.collection('usuarios').doc(userId).delete();
                Navigator.pop(context);
                _showMessage('Usuario eliminado', Colors.green);
              } catch (e) {
                _showMessage('Error: ${e.toString()}', Colors.red);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showMessage(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}