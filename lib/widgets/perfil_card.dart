import 'package:flutter/material.dart';

class PerfilCard extends StatelessWidget {
  final String nombre;
  final String email;
  final String rol;
  final VoidCallback? onTap;
  final VoidCallback? onEdit;

  const PerfilCard({
    super.key,
    required this.nombre,
    required this.email,
    required this.rol,
    this.onTap,
    this.onEdit,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.all(16),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Avatar
              CircleAvatar(
                radius: 50,
                backgroundColor: _getRolColor(rol),
                child: Icon(
                  _getRolIcon(rol),
                  size: 50,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 16),

              // Nombre
              Text(
                nombre,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Email
              Text(
                email,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey.shade600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Rol
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                decoration: BoxDecoration(
                  color: _getRolColor(rol).withOpacity(0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getRolIcon(rol),
                      size: 16,
                      color: _getRolColor(rol),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      rol.toUpperCase(),
                      style: TextStyle(
                        color: _getRolColor(rol),
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Botón editar
              if (onEdit != null) ...[
                const SizedBox(height: 16),
                ElevatedButton.icon(
                  onPressed: onEdit,
                  icon: const Icon(Icons.edit),
                  label: const Text('Editar Perfil'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green.shade700,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Color _getRolColor(String rol) {
    switch (rol.toLowerCase()) {
      case 'jugador':
        return Colors.blue;
      case 'entrenador':
        return Colors.orange;
      case 'arbitro':
        return Colors.purple;
      case 'admin':
        return Colors.red;
      default:
        return Colors.grey;
    }
  }

  IconData _getRolIcon(String rol) {
    switch (rol.toLowerCase()) {
      case 'jugador':
        return Icons.sports_soccer;
      case 'entrenador':
        return Icons.sports;
      case 'arbitro':
        return Icons.sports_score;
      case 'admin':
        return Icons.admin_panel_settings;
      default:
        return Icons.person;
    }
  }
}

///  perfil card
class PerfilCardCompact extends StatelessWidget {
  final String nombre;
  final String email;
  final String rol;
  final VoidCallback? onTap;

  const PerfilCardCompact({
    super.key,
    required this.nombre,
    required this.email,
    required this.rol,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: _getRolColor(rol),
          child: Icon(_getRolIcon(rol), color: Colors.white),
        ),
        title: Text(nombre),
        subtitle: Text('$email\nRol: ${rol.toUpperCase()}'),
        isThreeLine: true,
        onTap: onTap,
      ),
    );
  }

  Color _getRolColor(String rol) {
    switch (rol.toLowerCase()) {
      case 'jugador': return Colors.blue;
      case 'entrenador': return Colors.orange;
      case 'arbitro': return Colors.purple;
      case 'admin': return Colors.red;
      default: return Colors.grey;
    }
  }

  IconData _getRolIcon(String rol) {
    switch (rol.toLowerCase()) {
      case 'jugador': return Icons.sports_soccer;
      case 'entrenador': return Icons.sports;
      case 'arbitro': return Icons.sports_score;
      case 'admin': return Icons.admin_panel_settings;
      default: return Icons.person;
    }
  }
}