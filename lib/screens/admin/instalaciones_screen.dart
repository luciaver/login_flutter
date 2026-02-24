import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InstalacionesScreen extends StatefulWidget {
  const InstalacionesScreen({super.key});

  @override
  State<InstalacionesScreen> createState() => _InstalacionesScreenState();
}

class _InstalacionesScreenState extends State<InstalacionesScreen> {
  static const Color rosa     = Color(0xFFEC4899);
  static const Color rosaDark = Color(0xFFDB2777);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F6),
      appBar: AppBar(
        title: const Text('Instalaciones'),
        backgroundColor: rosaDark,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pistas').snapshots(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: rosa));
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                Icon(Icons.sports_tennis, size: 72, color: rosa.withOpacity(0.3)),
                const SizedBox(height: 16),
                const Text('No hay instalaciones',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: rosa)),
                const SizedBox(height: 8),
                Text('Pulsa + para añadir una pista', style: TextStyle(color: Colors.grey.shade500)),
              ]),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: snap.data!.docs.length,
            itemBuilder: (_, i) {
              final doc = snap.data!.docs[i];
              final d = doc.data() as Map<String, dynamic>;
              final nombre     = d['nombre'] ?? 'Pista';
              final tipo       = d['tipo'] ?? '';
              final precio     = d['precio']?.toString() ?? '0';
              final disponible = d['disponible'] as bool? ?? true;

              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 12),
                child: Column(children: [
                  ListTile(
                    leading: CircleAvatar(
                      backgroundColor: disponible ? rosa.withOpacity(0.15) : Colors.grey.shade200,
                      child: Icon(_icono(tipo), color: disponible ? rosa : Colors.grey),
                    ),
                    title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Row(children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: rosa.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(tipo, style: const TextStyle(fontSize: 11, color: rosa, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(width: 8),
                      Text('€$precio/h', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ]),
                    trailing: Switch(
                      value: disponible,
                      activeColor: rosa,
                      onChanged: (v) => FirebaseFirestore.instance
                          .collection('pistas')
                          .doc(doc.id)
                          .update({'disponible': v}),
                    ),
                  ),
                  // Botones separados
                  Padding(
                    padding: const EdgeInsets.fromLTRB(14, 0, 14, 12),
                    child: Row(children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _editar(context, doc.id, d),
                          icon: const Icon(Icons.edit, size: 16),
                          label: const Text('Editar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: rosa,
                            side: const BorderSide(color: rosa),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _eliminar(context, doc.id, nombre),
                          icon: const Icon(Icons.delete, size: 16),
                          label: const Text('Eliminar'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ),
                    ]),
                  ),
                ]),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _agregar(context),
        backgroundColor: rosaDark,
        icon: const Icon(Icons.add),
        label: const Text('Nueva Pista'),
      ),
    );
  }

  IconData _icono(String tipo) {
    switch (tipo) {
      case 'Tenis':      return Icons.sports_tennis;
      case 'Fútbol':     return Icons.sports_soccer;
      case 'Pádel':      return Icons.sports;
      case 'Baloncesto': return Icons.sports_basketball;
      default:           return Icons.sports;
    }
  }

  static const _deportes = ['Fútbol', 'Baloncesto', 'Pádel', 'Tenis'];

  // ── AGREGAR ──────────────────────────────────────────────

  void _agregar(BuildContext context) {
    final nombreCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    String tipo = 'Fútbol';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        // Usamos StatefulBuilder para que el dropdown funcione
        String tipoLocal = tipo;
        return StatefulBuilder(
          builder: (dialogCtx, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(children: [
                Icon(Icons.add_circle, color: Color(0xFFEC4899)),
                SizedBox(width: 8),
                Text('Nueva Instalación'),
              ]),
              content: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  // Campo nombre
                  TextField(
                    controller: nombreCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nombre de la pista',
                      prefixIcon: const Icon(Icons.sports_tennis, color: Color(0xFFEC4899)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFEC4899), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Campo precio
                  TextField(
                    controller: precioCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Precio €/hora',
                      prefixIcon: const Icon(Icons.euro, color: Color(0xFFEC4899)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFEC4899), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Dropdown tipo de deporte
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFEC4899)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: tipoLocal,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFEC4899)),
                        items: _deportes
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setStateDialog(() => tipoLocal = v);
                        },
                      ),
                    ),
                  ),
                ]),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Crear'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFEC4899),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    final nombre = nombreCtrl.text.trim();
                    final precio = precioCtrl.text.trim();

                    if (nombre.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Introduce el nombre de la pista'),
                          backgroundColor: Colors.orange,
                          behavior: SnackBarBehavior.floating,
                        ),
                      );
                      return;
                    }

                    try {
                      await FirebaseFirestore.instance.collection('pistas').add({
                        'nombre': nombre,
                        'tipo': tipoLocal,
                        'precio': precio.isEmpty ? '0' : precio,
                        'disponible': true,
                      });
                      Navigator.pop(ctx);
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Pista "$nombre" creada correctamente'),
                            backgroundColor: const Color(0xFFEC4899),
                            behavior: SnackBarBehavior.floating,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        );
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Error al crear la pista: $e'),
                            backgroundColor: Colors.red,
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── EDITAR ───────────────────────────────────────────────

  void _editar(BuildContext context, String id, Map<String, dynamic> data) {
    final nombreCtrl = TextEditingController(text: data['nombre']);
    final precioCtrl = TextEditingController(text: data['precio']?.toString() ?? '');
    String tipoLocal = data['tipo'] ?? 'Fútbol';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(children: [
                Icon(Icons.edit, color: Color(0xFFDB2777)),
                SizedBox(width: 8),
                Text('Editar Instalación'),
              ]),
              content: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  TextField(
                    controller: nombreCtrl,
                    decoration: InputDecoration(
                      labelText: 'Nombre',
                      prefixIcon: const Icon(Icons.sports_tennis, color: Color(0xFFDB2777)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFDB2777), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: precioCtrl,
                    keyboardType: TextInputType.number,
                    decoration: InputDecoration(
                      labelText: 'Precio €/hora',
                      prefixIcon: const Icon(Icons.euro, color: Color(0xFFDB2777)),
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: const BorderSide(color: Color(0xFFDB2777), width: 2),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFFDB2777)),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: tipoLocal,
                        isExpanded: true,
                        icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFDB2777)),
                        items: _deportes
                            .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                            .toList(),
                        onChanged: (v) {
                          if (v != null) setStateDialog(() => tipoLocal = v);
                        },
                      ),
                    ),
                  ),
                ]),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
                ),
                ElevatedButton.icon(
                  icon: const Icon(Icons.save),
                  label: const Text('Guardar'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFDB2777),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () async {
                    try {
                      await FirebaseFirestore.instance.collection('pistas').doc(id).update({
                        'nombre': nombreCtrl.text.trim(),
                        'tipo': tipoLocal,
                        'precio': precioCtrl.text.trim(),
                      });
                      Navigator.pop(ctx);
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
                        );
                      }
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ── ELIMINAR ─────────────────────────────────────────────

  void _eliminar(BuildContext context, String id, String nombre) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Eliminar instalación'),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 15),
            children: [
              const TextSpan(text: '¿Eliminar la pista '),
              TextSpan(text: '"$nombre"', style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEC4899))),
              const TextSpan(text: '? Esta acción no se puede deshacer.'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('pistas').doc(id).delete();
              Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Pista "$nombre" eliminada'),
                    backgroundColor: Colors.red.shade700,
                    behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                );
              }
            },
          ),
        ],
      ),
    );
  }
}