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

  // Colores por deporte - más variados y con personalidad
  Color _colorDeporte(String tipo) {
    switch (tipo) {
      case 'Tenis':      return const Color(0xFFFF6B6B);
      case 'Fútbol':     return const Color(0xFF4CAF50);
      case 'Pádel':      return const Color(0xFF2196F3);
      case 'Baloncesto': return const Color(0xFFFF9800);
      default:           return rosa;
    }
  }

  String _emojiDeporte(String tipo) {
    switch (tipo) {
      case 'Tenis':      return '🎾';
      case 'Fútbol':     return '⚽';
      case 'Pádel':      return '🏓';
      case 'Baloncesto': return '🏀';
      default:           return '🏅';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F6),
      appBar: AppBar(
        title: const Text('Instalaciones', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: rosaDark,
        foregroundColor: Colors.white,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(2),
          child: Container(height: 2, color: rosa.withOpacity(0.5)),
        ),
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
                const Text('🏟️', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 14),
                const Text('Aún no hay pistas añadidas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: rosa)),
                const SizedBox(height: 6),
                Text('Pulsa + para añadir la primera 💪',
                    style: TextStyle(color: Colors.grey.shade500)),
              ]),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 100),
            itemCount: snap.data!.docs.length,
            itemBuilder: (_, i) {
              final doc = snap.data!.docs[i];
              final d = doc.data() as Map<String, dynamic>;
              final nombre     = d['nombre'] ?? 'Pista';
              final tipo       = d['tipo'] ?? '';
              final precio     = d['precio']?.toString() ?? '0';
              final disponible = d['disponible'] as bool? ?? true;
              final color      = _colorDeporte(tipo);
              final emoji      = _emojiDeporte(tipo);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: color.withOpacity(0.18), blurRadius: 12, offset: const Offset(0, 5)),
                  ],
                  border: Border.all(color: color.withOpacity(0.15), width: 1.5),
                ),
                child: Column(children: [
                  // Cabecera con color por deporte
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [color.withOpacity(0.15), color.withOpacity(0.05)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    ),
                    child: Row(children: [
                      // Emoji grande como icono
                      Container(
                        width: 48,
                        height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: color.withOpacity(0.3), blurRadius: 6)],
                        ),
                        child: Center(
                          child: Text(emoji, style: const TextStyle(fontSize: 24)),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(
                            nombre,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: color,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: color,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                tipo,
                                style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '💶 $precio€/h',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500),
                            ),
                          ]),
                        ]),
                      ),
                      // Switch de disponibilidad
                      Column(children: [
                        Switch(
                          value: disponible,
                          activeColor: color,
                          onChanged: (v) => FirebaseFirestore.instance
                              .collection('pistas')
                              .doc(doc.id)
                              .update({'disponible': v}),
                        ),
                        Text(
                          disponible ? 'Abierta' : 'Cerrada',
                          style: TextStyle(
                            fontSize: 10,
                            color: disponible ? Colors.green : Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ]),
                    ]),
                  ),
                  // Botones editar / eliminar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Row(children: [
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () => _editar(context, doc.id, d),
                          icon: const Icon(Icons.edit_note, size: 16),
                          label: const Text('Editar', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: color,
                            foregroundColor: Colors.white,
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () => _eliminar(context, doc.id, nombre),
                          icon: const Icon(Icons.delete_outline, size: 16),
                          label: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.bold)),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: Colors.red,
                            side: const BorderSide(color: Colors.red),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            padding: const EdgeInsets.symmetric(vertical: 10),
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
        label: const Text('Nueva Pista', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  static const _deportes = ['Fútbol', 'Baloncesto', 'Pádel', 'Tenis'];

  void _agregar(BuildContext context) {
    final nombreCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    String tipoLocal = 'Fútbol';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (dialogCtx, setStateDialog) {
            return AlertDialog(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              title: const Row(children: [
                Text('🏟️ ', style: TextStyle(fontSize: 22)),
                Text('Nueva Instalación', style: TextStyle(fontWeight: FontWeight.bold)),
              ]),
              content: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, children: [
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
                        items: _deportes.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                        onChanged: (v) { if (v != null) setStateDialog(() => tipoLocal = v); },
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
                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text('Introduce el nombre de la pista'),
                        backgroundColor: Colors.orange,
                        behavior: SnackBarBehavior.floating,
                      ));
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
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('🎉 Pista "$nombre" creada!'),
                          backgroundColor: const Color(0xFFEC4899),
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ));
                      }
                    } catch (e) {
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                          content: Text('Error: $e'),
                          backgroundColor: Colors.red,
                          behavior: SnackBarBehavior.floating,
                        ));
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
                Text('✏️ ', style: TextStyle(fontSize: 22)),
                Text('Editar Instalación', style: TextStyle(fontWeight: FontWeight.bold)),
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
                        items: _deportes.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
                        onChanged: (v) { if (v != null) setStateDialog(() => tipoLocal = v); },
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

  void _eliminar(BuildContext context, String id, String nombre) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('⚠️ Eliminar instalación'),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 15),
            children: [
              const TextSpan(text: '¿Segura que quieres eliminar '),
              TextSpan(
                text: '"$nombre"',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFEC4899)),
              ),
              const TextSpan(text: '? No se puede deshacer.'),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
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
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Pista "$nombre" eliminada'),
                  backgroundColor: Colors.red.shade700,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ));
              }
            },
          ),
        ],
      ),
    );
  }
}