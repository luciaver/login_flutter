import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class InstalacionesScreen extends StatelessWidget {
  const InstalacionesScreen({super.key});
  static const Color ac = Color(0xFFEC4899);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Instalaciones'), backgroundColor: ac, foregroundColor: Colors.white),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('pistas').snapshots(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: ac));
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text('No hay instalaciones'));
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
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                elevation: 3, margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: ac.withOpacity(0.15),
                    child: Icon(_icono(tipo), color: ac),
                  ),
                  title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$tipo · €$precio/h'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                    Switch(
                      value: disponible, activeColor: ac,
                      onChanged: (v) => FirebaseFirestore.instance.collection('pistas')
                          .doc(doc.id).update({'disponible': v}),
                    ),
                    IconButton(icon: const Icon(Icons.edit, color: ac),
                        onPressed: () => _editar(context, doc.id, d)),
                    IconButton(icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () => _eliminar(context, doc.id, nombre)),
                  ]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _agregar(context), backgroundColor: ac,
        icon: const Icon(Icons.add), label: const Text('Nueva Pista'),
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

  void _agregar(BuildContext context) {
    final nc = TextEditingController(), pc = TextEditingController();
    String tipo = 'Fútbol';
    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, ss) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nueva Instalación'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _campo(nc, 'Nombre de la pista', Icons.sports_tennis),
          const SizedBox(height: 10),
          _campo(pc, 'Precio €/h', Icons.euro, type: TextInputType.number),
          const SizedBox(height: 10),
          _dropDeporte(tipo, (v) => ss(() => tipo = v!)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ac, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              if (nc.text.trim().isEmpty) return;
              await FirebaseFirestore.instance.collection('pistas').add(
                  {'nombre': nc.text.trim(), 'tipo': tipo, 'precio': pc.text.trim(), 'disponible': true});
              Navigator.pop(ctx);
            },
            child: const Text('Crear'),
          ),
        ],
      ),
    ));
  }

  void _editar(BuildContext context, String id, Map<String, dynamic> data) {
    final nc = TextEditingController(text: data['nombre']);
    final pc = TextEditingController(text: data['precio']?.toString() ?? '');
    String tipo = data['tipo'] ?? 'Fútbol';
    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, ss) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Editar Instalación'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _campo(nc, 'Nombre', Icons.sports_tennis),
          const SizedBox(height: 10),
          _campo(pc, 'Precio €/h', Icons.euro, type: TextInputType.number),
          const SizedBox(height: 10),
          _dropDeporte(tipo, (v) => ss(() => tipo = v!)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ac, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('pistas').doc(id)
                  .update({'nombre': nc.text.trim(), 'tipo': tipo, 'precio': pc.text.trim()});
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    ));
  }

  void _eliminar(BuildContext context, String id, String nombre) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Eliminar instalación'),
      content: Text('¿Eliminar "$nombre"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          onPressed: () async {
            await FirebaseFirestore.instance.collection('pistas').doc(id).delete();
            Navigator.pop(ctx);
          },
          child: const Text('Eliminar'),
        ),
      ],
    ));
  }

  Widget _campo(TextEditingController ctrl, String label, IconData icon,
      {TextInputType type = TextInputType.text}) => TextField(
    controller: ctrl, keyboardType: type,
    decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon, color: ac),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: ac, width: 2))),
  );

  Widget _dropDeporte(String value, ValueChanged<String?> onChanged) => Container(
    decoration: BoxDecoration(border: Border.all(color: ac), borderRadius: BorderRadius.circular(12)),
    padding: const EdgeInsets.symmetric(horizontal: 12),
    child: DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: value, isExpanded: true,
        icon: const Icon(Icons.arrow_drop_down, color: ac),
        items: _deportes.map((d) => DropdownMenuItem(value: d, child: Text(d))).toList(),
        onChanged: onChanged,
      ),
    ),
  );
}