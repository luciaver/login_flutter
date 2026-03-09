import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../provider/instalaciones_provider.dart';

class InstalacionesScreen extends StatelessWidget {
  const InstalacionesScreen({super.key});

  static const Color ac     = Color(0xFFF0ABFC);
  static const Color acDark = Color(0xFFD946EF);
  static const Color fondo  = Color(0xFFFAF0FF);
  static const _deportes    = ['Fútbol', 'Baloncesto', 'Pádel', 'Tenis'];

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
    final prov = Provider.of<InstalacionesProvider>(context, listen: false);
    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text('Instalaciones', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: acDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: prov.obtenerPistas(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: acDark));
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('🏟️', style: TextStyle(fontSize: 60)),
                const SizedBox(height: 14),
                const Text('Aún no hay pistas',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: acDark)),
                const SizedBox(height: 6),
                Text('Pulsa + para añadir la primera',
                    style: TextStyle(color: Colors.grey.shade500)),
              ]),
            );
          }
          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 100),
            itemCount: snap.data!.docs.length,
            itemBuilder: (_, i) {
              final doc  = snap.data!.docs[i];
              final d    = doc.data() as Map<String, dynamic>;
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
                  boxShadow: [BoxShadow(color: acDark.withOpacity(0.12), blurRadius: 12, offset: const Offset(0, 5))],
                  border: Border.all(color: ac.withOpacity(0.3), width: 1.5),
                ),
                child: Column(children: [
                  // Cabecera
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [acDark.withOpacity(0.12), ac.withOpacity(0.08)],
                        begin: Alignment.centerLeft, end: Alignment.centerRight,
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
                              decoration: BoxDecoration(color: acDark, borderRadius: BorderRadius.circular(8)),
                              child: Text(tipo,
                                  style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(width: 8),
                            Text('$precio€/h',
                                style: TextStyle(fontSize: 13, color: Colors.grey.shade600, fontWeight: FontWeight.w500)),
                          ]),
                        ]),
                      ),
                      // Badge estado
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
                  // Acciones
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                    child: Row(children: [
                      // Switch disponibilidad
                      Row(mainAxisSize: MainAxisSize.min, children: [
                        Switch(
                          value: disponible,
                          activeColor: acDark,
                          onChanged: (v) => prov.toggleDisponible(doc.id, v),
                        ),
                        Text(
                          disponible ? 'Abierta' : 'Cerrada',
                          style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold,
                            color: disponible ? Colors.green : Colors.red,
                          ),
                        ),
                      ]),
                      const Spacer(),
                      TextButton.icon(
                        onPressed: () => _editar(context, doc.id, d),
                        icon: const Icon(Icons.edit_note, size: 16),
                        label: const Text('Editar', style: TextStyle(fontWeight: FontWeight.bold)),
                        style: TextButton.styleFrom(foregroundColor: acDark),
                      ),
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

  void _agregar(BuildContext context) {
    final nombreCtrl = TextEditingController();
    final precioCtrl = TextEditingController();
    String tipo = 'Fútbol';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('🏟️ Nueva Instalación', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            _campo(nombreCtrl, 'Nombre de la pista', Icons.sports_tennis),
            const SizedBox(height: 12),
            _campo(precioCtrl, 'Precio €/hora', Icons.euro, type: TextInputType.number),
            const SizedBox(height: 12),
            _dropDeporte(tipo, (v) { if (v != null) ss(() => tipo = v); }),
          ]),
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
                if (nombreCtrl.text.trim().isEmpty) return;
                final prov = Provider.of<InstalacionesProvider>(ctx, listen: false);
                await prov.agregarPista(
                  nombre: nombreCtrl.text.trim(),
                  tipo: tipo,
                  precio: precioCtrl.text.trim().isEmpty ? '0' : precioCtrl.text.trim(),
                );
                Navigator.pop(ctx);
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
    String tipo = data['tipo'] ?? 'Fútbol';

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, ss) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text('✏️ Editar Instalación', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Column(mainAxisSize: MainAxisSize.min, children: [
            _campo(nombreCtrl, 'Nombre', Icons.sports_tennis),
            const SizedBox(height: 12),
            _campo(precioCtrl, 'Precio €/hora', Icons.euro, type: TextInputType.number),
            const SizedBox(height: 12),
            _dropDeporte(tipo, (v) { if (v != null) ss(() => tipo = v); }),
          ]),
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
                final prov = Provider.of<InstalacionesProvider>(ctx, listen: false);
                await prov.editarPista(
                  id: id,
                  nombre: nombreCtrl.text.trim(),
                  tipo: tipo,
                  precio: precioCtrl.text.trim(),
                );
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
        title: const Text('Eliminar instalación'),
        content: Text('¿Seguro que quieres eliminar "$nombre"?'),
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
              final prov = Provider.of<InstalacionesProvider>(ctx, listen: false);
              await prov.eliminarPista(id);
              Navigator.pop(ctx);
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
      decoration: BoxDecoration(border: Border.all(color: acDark), borderRadius: BorderRadius.circular(12)),
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