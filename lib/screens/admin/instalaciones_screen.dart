import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InstalacionesScreen extends StatefulWidget {
  const InstalacionesScreen({super.key});

  @override
  State<InstalacionesScreen> createState() => _InstalacionesScreenState();
}

class _InstalacionesScreenState extends State<InstalacionesScreen> {
  static const Color ac     = Color(0xFFF0ABFC);
  static const Color acDark = Color(0xFFD946EF);
  static const Color fondo  = Color(0xFFFAF0FF);

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
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text('Instalaciones', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: acDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pistas').snapshots(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: acDark));
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('🏟️', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 14),
                const Text('Aún no hay pistas añadidas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: acDark)),
                const SizedBox(height: 6),
                Text('Pulsa + para añadir la primera ',
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
              final emoji      = _emojiDeporte(tipo);

              return Container(
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: acDark.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 5)),
                  ],
                  border: Border.all(color: ac.withOpacity(0.3), width: 1.5),
                ),
                child: Column(children: [
                  // Cabecera
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [acDark.withOpacity(0.12), ac.withOpacity(0.08)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    ),
                    child: Row(children: [
                      Container(
                        width: 48, height: 48,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                          boxShadow: [BoxShadow(color: acDark.withOpacity(0.3), blurRadius: 6)],
                        ),
                        child: Center(child: Text(emoji, style: const TextStyle(fontSize: 24))),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(nombre,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: acDark)),
                          const SizedBox(height: 3),
                          Row(children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: acDark,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(tipo,
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            Text(' $precio€/h',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                          ]),
                        ]),
                      ),
                      // Badge estado en cabecera
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        decoration: BoxDecoration(
                          color: disponible ? Colors.green.withOpacity(0.12) : Colors.red.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: disponible ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          disponible ? 'Abierta' : 'Cerrada',
                          style: TextStyle(
                            color: disponible ? Colors.green : Colors.red,
                            fontSize: 11, fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ]),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Row(children: [
                      // Switch de disponibilidad
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: ac.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: ac.withOpacity(0.3)),
                        ),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Switch(
                            value: disponible,
                            activeColor: acDark,
                            onChanged: (v) => FirebaseFirestore.instance
                                .collection('pistas').doc(doc.id).update({'disponible': v}),
                          ),
                          const SizedBox(width: 4),
                          PopupMenuButton<String>(
                            onSelected: (val) {
                              FirebaseFirestore.instance
                                  .collection('pistas').doc(doc.id)
                                  .update({'disponible': val == 'abierta'});
                            },
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Text(disponible ? 'Abierta' : 'Cerrada',
                                  style: TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.bold,
                                    color: disponible ? Colors.green : Colors.red,
                                  )),
                              Icon(Icons.arrow_drop_down,
                                  color: disponible ? Colors.green : Colors.red, size: 18),
                            ]),
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'abierta', child: Text('  Abierta')),
                              PopupMenuItem(value: 'cerrada', child: Text('  Cerrada')),
                            ],
                          ),
                        ]),
                      ),
                      const Spacer(),
                      // Editar
                      TextButton.icon(
                        onPressed: () => _editar(context, doc.id, d),
                        icon: const Icon(Icons.edit_note, size: 16),
                        label: const Text('Editar', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(foregroundColor: acDark),
                      ),
                      const SizedBox(width: 4),
                      // Eliminar
                      TextButton.icon(
                        onPressed: () => _eliminar(context, doc.id, nombre),
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Eliminar', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(foregroundColor: Colors.red),
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
        backgroundColor: acDark,
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
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, ss) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Text('🏟️ ', style: TextStyle(fontSize: 22)),
            Text('Nueva Instalación', style: TextStyle(fontWeight: FontWeight.bold)),
          ]),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            _campo(nombreCtrl, 'Nombre de la pista', Icons.sports_tennis),
            const SizedBox(height: 12),
            _campo(precioCtrl, 'Precio €/hora', Icons.euro, type: TextInputType.number),
            const SizedBox(height: 12),
            _dropDeporte(tipoLocal, (v) { if (v != null) ss(() => tipoLocal = v); }),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Crear'),
              style: ElevatedButton.styleFrom(
                backgroundColor: acDark, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                final nombre = nombreCtrl.text.trim();
                if (nombre.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                    content: Text('Introduce el nombre de la pista'),
                    backgroundColor: Colors.orange, behavior: SnackBarBehavior.floating,
                  ));
                  return;
                }
                await FirebaseFirestore.instance.collection('pistas').add({
                  'nombre': nombre, 'tipo': tipoLocal,
                  'precio': precioCtrl.text.trim().isEmpty ? '0' : precioCtrl.text.trim(),
                  'disponible': true,
                });
                Navigator.pop(ctx);
                if (mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                    content: Text(' Pista "$nombre" creada!'),
                    backgroundColor: acDark, behavior: SnackBarBehavior.floating,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ));
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  void _editar(BuildContext context, String id, Map<String, dynamic> data) {
    final nombreCtrl = TextEditingController(text: data['nombre']);
    final precioCtrl = TextEditingController(text: data['precio']?.toString() ?? '');
    String tipoLocal = data['tipo'] ?? 'Fútbol';

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, ss) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Row(children: [
            Text('✏️ ', style: TextStyle(fontSize: 22)),
            Text('Editar Instalación', style: TextStyle(fontWeight: FontWeight.bold)),
          ]),
          content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
            _campo(nombreCtrl, 'Nombre', Icons.sports_tennis),
            const SizedBox(height: 12),
            _campo(precioCtrl, 'Precio €/hora', Icons.euro, type: TextInputType.number),
            const SizedBox(height: 12),
            _dropDeporte(tipoLocal, (v) { if (v != null) ss(() => tipoLocal = v); }),
          ])),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx),
                child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
            ElevatedButton.icon(
              icon: const Icon(Icons.save),
              label: const Text('Guardar'),
              style: ElevatedButton.styleFrom(
                backgroundColor: acDark, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                await FirebaseFirestore.instance.collection('pistas').doc(id).update({
                  'nombre': nombreCtrl.text.trim(),
                  'tipo': tipoLocal,
                  'precio': precioCtrl.text.trim(),
                });
                Navigator.pop(ctx);
              },
            ),
          ],
        ),
      ),
    );
  }

  void _eliminar(BuildContext context, String id, String nombre) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(' Eliminar instalación'),
        content: RichText(
          text: TextSpan(
            style: const TextStyle(color: Colors.black87, fontSize: 15),
            children: [
              const TextSpan(text: '¿Seguro que quieres eliminar '),
              TextSpan(text: '"$nombre"',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: acDark)),
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
              backgroundColor: Colors.red, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('pistas').doc(id).delete();
              Navigator.pop(ctx);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text('Pista "$nombre" eliminada'),
                  backgroundColor: Colors.red.shade700, behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ));
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _campo(TextEditingController ctrl, String label, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return TextField(
      controller: ctrl, keyboardType: type,
      decoration: InputDecoration(
        labelText: label, prefixIcon: Icon(icon, color: acDark),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: acDark, width: 2),
        ),
      ),
    );
  }

  Widget _dropDeporte(String value, ValueChanged<String?> onChanged) {
    return Container(
      decoration: BoxDecoration(
          border: Border.all(color: acDark), borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value, isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: acDark),
          items: _deportes.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}