import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EquiposScreen extends StatelessWidget {
  const EquiposScreen({super.key});
  static const Color ac = Color(0xFF7C3AED);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Equipos'), backgroundColor: ac, foregroundColor: Colors.white),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('equipos').snapshots(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: ac));
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text('No hay equipos'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: snap.data!.docs.length,
            itemBuilder: (_, i) {
              final doc = snap.data!.docs[i];
              final d = doc.data() as Map<String, dynamic>;
              final nombre   = d['nombre'] ?? 'Equipo';
              final deporte  = d['deporte'] ?? '';
              final jugadores = List.from(d['jugadoresIds'] ?? []);
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 3, margin: const EdgeInsets.only(bottom: 10),
                child: ListTile(
                  leading: CircleAvatar(backgroundColor: ac,
                      child: Text(nombre[0].toUpperCase(),
                          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                  title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text('$deporte · ${jugadores.length} jugadores'),
                  trailing: Row(mainAxisSize: MainAxisSize.min, children: [
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
        icon: const Icon(Icons.add), label: const Text('Nuevo Equipo'),
      ),
    );
  }

  static const _deportes = ['Fútbol', 'Baloncesto', 'Pádel', 'Tenis'];

  void _agregar(BuildContext context) {
    final nc = TextEditingController();
    String deporte = 'Fútbol';
    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, ss) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nuevo Equipo'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _campo(nc, 'Nombre del equipo', Icons.groups),
          const SizedBox(height: 12),
          _dropDeporte(deporte, (v) => ss(() => deporte = v!)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ac, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              if (nc.text.trim().isEmpty) return;
              await FirebaseFirestore.instance.collection('equipos').add(
                  {'nombre': nc.text.trim(), 'deporte': deporte, 'jugadoresIds': []});
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
    String deporte = data['deporte'] ?? 'Fútbol';
    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, ss) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Editar Equipo'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _campo(nc, 'Nombre', Icons.groups),
          const SizedBox(height: 12),
          _dropDeporte(deporte, (v) => ss(() => deporte = v!)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ac, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('equipos').doc(id)
                  .update({'nombre': nc.text.trim(), 'deporte': deporte});
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
      title: const Text('Eliminar equipo'),
      content: Text('¿Eliminar "$nombre"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          onPressed: () async {
            await FirebaseFirestore.instance.collection('equipos').doc(id).delete();
            Navigator.pop(ctx);
          },
          child: const Text('Eliminar'),
        ),
      ],
    ));
  }

  Widget _campo(TextEditingController ctrl, String label, IconData icon) => TextField(
    controller: ctrl,
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