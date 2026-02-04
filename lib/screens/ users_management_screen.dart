import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../provider/user_provider.dart';
import '../providers/user_provider.dart';

class UsersManagementScreen extends StatelessWidget {
  const UsersManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => UserProvider(),
      child: const _UsersManagementContent(),
    );
  }
}

class _UsersManagementContent extends StatelessWidget {
  const _UsersManagementContent();

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestión de Usuarios'),
        backgroundColor: Colors.green.shade700,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filtro por rol
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                const Text(
                  'Filtrar: ',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DropdownButton<String>(
                    value: userProvider.filtroRol,
                    isExpanded: true,
                    items: const [
                      DropdownMenuItem(value: 'todos', child: Text('Todos')),
                      DropdownMenuItem(value: 'jugador', child: Text('Jugadores')),
                      DropdownMenuItem(value: 'entrenador', child: Text('Entrenadores')),
                      DropdownMenuItem(value: 'arbitro', child: Text('Árbitros')),
                      DropdownMenuItem(value: 'admin', child: Text('Admins')),
                    ],
                    onChanged: (value) {
                      if (value != null) {
                        userProvider.cambiarFiltroRol(value);
                      }
                    },
                  ),
                ),
              ],
            ),
          ),

          // Lista de usuarios
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: userProvider.obtenerUsuarios(),
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
                              onPressed: () => _editUser(context, doc.id, nombre, email, rol),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () => _deleteUser(context, doc.id, nombre),
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
        onPressed: () => _addUser(context),
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

  void _addUser(BuildContext context) {
    final nombreCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final passwordCtrl = TextEditingController();
    String selectedRol = 'jugador';

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text('Agregar Usuario'),
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                bool success = await userProvider.agregarUsuario(
                  nombre: nombreCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  password: passwordCtrl.text,
                  rol: selectedRol,
                );
                Navigator.pop(dialogContext);
                _showMessage(context, success ? 'Usuario agregado' : 'Error al agregar', success ? Colors.green : Colors.red);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green.shade700,
                foregroundColor: Colors.white,
              ),
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _editUser(BuildContext context, String userId, String currentNombre, String currentEmail, String currentRol) {
    final nombreCtrl = TextEditingController(text: currentNombre);
    String selectedRol = currentRol;

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
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
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            ElevatedButton(
              onPressed: () async {
                final userProvider = Provider.of<UserProvider>(context, listen: false);
                bool success = await userProvider.editarUsuario(
                  userId: userId,
                  nombre: nombreCtrl.text.trim(),
                  rol: selectedRol,
                );
                Navigator.pop(dialogContext);
                _showMessage(context, success ? 'Usuario actualizado' : 'Error al actualizar', success ? Colors.green : Colors.red);
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

  void _deleteUser(BuildContext context, String userId, String nombre) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Eliminar Usuario'),
        content: Text('¿Eliminar a $nombre?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              bool success = await userProvider.eliminarUsuario(userId);
              Navigator.pop(dialogContext);
              _showMessage(context, success ? 'Usuario eliminado' : 'Error al eliminar', success ? Colors.green : Colors.red);
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

  void _showMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }
}