import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../provider/user_provider.dart';


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
        backgroundColor: const Color(0xFFD946EF),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Filtro por rol
          Container(
            padding: const EdgeInsets.all(16.0),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  const Color(0xFFD946EF).withOpacity(0.1),
                  const Color(0xFFF0ABFC).withOpacity(0.1),
                ],
              ),
            ),
            child: Row(
              children: [
                const Text(
                  'Filtrar: ',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFFD946EF),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFFD946EF)),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: userProvider.filtroRol,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD946EF)),
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
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Color(0xFFD946EF),
                    ),
                  );
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
                    final edad = data['edad'] ?? 0;
                    final telefono = data['telefono'] ?? 'Sin teléfono';
                    final posicion = data['posicion'];
                    final equipo = data['equipo'];


                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      elevation: 3,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: _getColor(rol).withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      child: ExpansionTile(
                        leading: CircleAvatar(
                          backgroundColor: _getColor(rol),
                          child: Icon(_getIcon(rol), color: Colors.white),
                        ),
                        title: Text(
                          nombre,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        subtitle: Text(
                          '$email\nRol: ${rol.toUpperCase()}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Container(
                              decoration: BoxDecoration(
                                color: const Color(0xFFD946EF).withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.edit, color: Color(0xFFD946EF)),
                                onPressed: () => _editUser(
                                  context,
                                  doc.id,
                                  nombre,
                                  email,
                                  rol,
                                  edad,
                                  telefono,
                                  posicion,
                                  equipo,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.red.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: () => _deleteUser(context, doc.id, nombre),
                              ),
                            ),
                          ],
                        ),
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: _getColor(rol).withOpacity(0.05),
                            ),
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                _buildInfoRow(Icons.cake, 'Edad', '$edad años', _getColor(rol)),
                                const SizedBox(height: 8),
                                _buildInfoRow(Icons.phone, 'Teléfono', telefono, _getColor(rol)),
                                if (posicion != null) ...[
                                  const SizedBox(height: 8),
                                  _buildInfoRow(Icons.sports_soccer, 'Posición', posicion, _getColor(rol)),
                                ],
                                if (equipo != null) ...[
                                  const SizedBox(height: 8),
                                  _buildInfoRow(Icons.groups, 'Equipo', equipo, _getColor(rol)),
                                ],
                              ],
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _addUser(context),
        backgroundColor: const Color(0xFFD946EF),
        icon: const Icon(Icons.add),
        label: const Text('Nuevo'),
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value, Color color) {
    return Row(
      children: [
        Icon(icon, size: 20, color: color),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(color: Colors.black87),
          ),
        ),
      ],
    );
  }

  Color _getColor(String rol) {
    switch (rol) {
      case 'jugador': return const Color(0xFFD946EF);
      case 'entrenador': return const Color(0xFFF0ABFC);
      case 'arbitro': return const Color(0xFFA855F7);
      case 'admin': return const Color(0xFF7C3AED);
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
    final edadCtrl = TextEditingController();
    final telefonoCtrl = TextEditingController();
    final equipoCtrl = TextEditingController();
    String selectedRol = 'jugador';
    String? selectedPosicion = 'Portero';

    final posiciones = ['Portero', 'Defensa', 'Centrocampista', 'Delantero'];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFD946EF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.person_add, color: Color(0xFFD946EF)),
              ),
              const SizedBox(width: 12),
              const Text('Agregar Usuario'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: const Icon(Icons.person, color: Color(0xFFD946EF)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD946EF), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: emailCtrl,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    prefixIcon: const Icon(Icons.email, color: Color(0xFFD946EF)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD946EF), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: edadCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Edad',
                    prefixIcon: const Icon(Icons.cake, color: Color(0xFFD946EF)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD946EF), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: telefonoCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: const Icon(Icons.phone, color: Color(0xFFD946EF)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD946EF), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: passwordCtrl,
                  decoration: InputDecoration(
                    labelText: 'Contraseña',
                    prefixIcon: const Icon(Icons.lock, color: Color(0xFFD946EF)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD946EF), width: 2),
                    ),
                  ),
                  obscureText: true,
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFD946EF)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedRol,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD946EF)),
                      items: const [
                        DropdownMenuItem(value: 'jugador', child: Text('Jugador')),
                        DropdownMenuItem(value: 'entrenador', child: Text('Entrenador')),
                        DropdownMenuItem(value: 'arbitro', child: Text('Árbitro')),
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      ],
                      onChanged: (value) => setState(() => selectedRol = value!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (selectedRol == 'jugador')
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFD946EF)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedPosicion,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD946EF)),
                        items: posiciones.map((pos) {
                          return DropdownMenuItem(value: pos, child: Text(pos));
                        }).toList(),
                        onChanged: (value) => setState(() => selectedPosicion = value),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: equipoCtrl,
                  decoration: InputDecoration(
                    labelText: 'Equipo (opcional)',
                    prefixIcon: const Icon(Icons.groups, color: Color(0xFFD946EF)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFD946EF), width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final edad = int.tryParse(edadCtrl.text.trim());
                if (edad == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edad inválida'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final userProvider = Provider.of<UserProvider>(context, listen: false);
                bool success = await userProvider.agregarUsuario(
                  nombre: nombreCtrl.text.trim(),
                  email: emailCtrl.text.trim(),
                  password: passwordCtrl.text,
                  rol: selectedRol,
                  edad: edad,
                  telefono: telefonoCtrl.text.trim(),
                  posicion: selectedRol == 'jugador' ? selectedPosicion : null,
                  equipo: equipoCtrl.text.trim().isNotEmpty ? equipoCtrl.text.trim() : null,
                );
                Navigator.pop(dialogContext);
                _showMessage(context, success ? 'Usuario agregado' : 'Error al agregar', success ? const Color(0xFFD946EF) : Colors.red);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD946EF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text('Agregar'),
            ),
          ],
        ),
      ),
    );
  }

  void _editUser(
      BuildContext context,
      String userId,
      String currentNombre,
      String currentEmail,
      String currentRol,
      int currentEdad,
      String currentTelefono,
      String? currentPosicion,
      String? currentEquipo,
      ) {
    final nombreCtrl = TextEditingController(text: currentNombre);
    final edadCtrl = TextEditingController(text: currentEdad.toString());
    final telefonoCtrl = TextEditingController(text: currentTelefono);
    final equipoCtrl = TextEditingController(text: currentEquipo ?? '');
    String selectedRol = currentRol;
    String? selectedPosicion = currentPosicion ?? 'Portero';

    final posiciones = ['Portero', 'Defensa', 'Centrocampista', 'Delantero'];

    showDialog(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: const Color(0xFFA855F7).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.edit, color: Color(0xFFA855F7)),
              ),
              const SizedBox(width: 12),
              const Text('Editar Usuario'),
            ],
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: nombreCtrl,
                  decoration: InputDecoration(
                    labelText: 'Nombre',
                    prefixIcon: const Icon(Icons.person, color: Color(0xFFA855F7)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFA855F7), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.email, color: Color(0xFFA855F7)),
                      const SizedBox(width: 12),
                      Text(
                        currentEmail,
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: edadCtrl,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: 'Edad',
                    prefixIcon: const Icon(Icons.cake, color: Color(0xFFA855F7)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFA855F7), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: telefonoCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: InputDecoration(
                    labelText: 'Teléfono',
                    prefixIcon: const Icon(Icons.phone, color: Color(0xFFA855F7)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFA855F7), width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFFA855F7)),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  child: DropdownButtonHideUnderline(
                    child: DropdownButton<String>(
                      value: selectedRol,
                      isExpanded: true,
                      icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFA855F7)),
                      items: const [
                        DropdownMenuItem(value: 'jugador', child: Text('Jugador')),
                        DropdownMenuItem(value: 'entrenador', child: Text('Entrenador')),
                        DropdownMenuItem(value: 'arbitro', child: Text('Árbitro')),
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      ],
                      onChanged: (value) => setState(() => selectedRol = value!),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                if (selectedRol == 'jugador')
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFA855F7)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: selectedPosicion,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFA855F7)),
                        items: posiciones.map((pos) {
                          return DropdownMenuItem(value: pos, child: Text(pos));
                        }).toList(),
                        onChanged: (value) => setState(() => selectedPosicion = value),
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                TextField(
                  controller: equipoCtrl,
                  decoration: InputDecoration(
                    labelText: 'Equipo (opcional)',
                    prefixIcon: const Icon(Icons.groups, color: Color(0xFFA855F7)),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: Color(0xFFA855F7), width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton(
              onPressed: () async {
                final edad = int.tryParse(edadCtrl.text.trim());
                if (edad == null) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Edad inválida'),
                      backgroundColor: Colors.red,
                    ),
                  );
                  return;
                }

                final userProvider = Provider.of<UserProvider>(context, listen: false);
                bool success = await userProvider.editarUsuario(
                  userId: userId,
                  nombre: nombreCtrl.text.trim(),
                  rol: selectedRol,
                  edad: edad,
                  telefono: telefonoCtrl.text.trim(),
                  posicion: selectedRol == 'jugador' ? selectedPosicion : null,
                  equipo: equipoCtrl.text.trim().isNotEmpty ? equipoCtrl.text.trim() : null,
                );
                Navigator.pop(dialogContext);
                _showMessage(context, success ? 'Usuario actualizado' : 'Error al actualizar', success ? const Color(0xFFA855F7) : Colors.red);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFA855F7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.warning, color: Colors.red),
            ),
            const SizedBox(width: 12),
            const Text('Eliminar Usuario'),
          ],
        ),
        content: Text('¿Estás seguro de eliminar a $nombre?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            onPressed: () async {
              final userProvider = Provider.of<UserProvider>(context, listen: false);
              bool success = await userProvider.eliminarUsuario(userId);
              Navigator.pop(dialogContext);
              _showMessage(context, success ? 'Usuario eliminado' : 'Error al eliminar', success ? const Color(0xFFD946EF) : Colors.red);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _showMessage(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}