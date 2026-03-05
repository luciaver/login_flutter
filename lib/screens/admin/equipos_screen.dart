import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class EquiposScreen extends StatelessWidget {
  const EquiposScreen({super.key});

  static const Color ac     = Color(0xFFF0ABFC);
  static const Color acDark = Color(0xFFD946EF);
  static const Color fondo  = Color(0xFFFAF0FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text('Equipos'),
        backgroundColor: acDark,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('equipos').snapshots(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: acDark));
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return Center(child: Text('No hay equipos',
                style: TextStyle(color: Colors.grey.shade500, fontSize: 16)));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: snap.data!.docs.length,
            itemBuilder: (_, i) {
              final doc = snap.data!.docs[i];
              final d = doc.data() as Map<String, dynamic>;
              final nombre       = d['nombre'] ?? 'Equipo';
              final deporte      = d['deporte'] ?? '';
              final jugadorIds   = List<String>.from(d['jugadoresIds'] ?? []);
              final entrenadorId = d['entrenadorId'] as String?;

              return Card(
                color: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                elevation: 3,
                margin: const EdgeInsets.only(bottom: 14),
                child: Column(children: [
                  // Cabecera
                  Container(
                    decoration: BoxDecoration(
                      color: acDark.withOpacity(0.85),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                    ),
                    padding: const EdgeInsets.all(14),
                    child: Row(children: [
                      CircleAvatar(
                        backgroundColor: Colors.white.withOpacity(0.3),
                        child: Text(nombre[0].toUpperCase(),
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 18)),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          Text(nombre,
                              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                          Text('$deporte · ${jugadorIds.length} jugadores',
                              style: TextStyle(color: Colors.white.withOpacity(0.85), fontSize: 12)),
                        ]),
                      ),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
                        child: IconButton(
                          icon: const Icon(Icons.edit, color: Colors.white, size: 20),
                          onPressed: () => _editar(context, doc.id, d),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        decoration: BoxDecoration(
                            color: Colors.red.withOpacity(0.3), borderRadius: BorderRadius.circular(8)),
                        child: IconButton(
                          icon: const Icon(Icons.delete, color: Colors.white, size: 20),
                          onPressed: () => _eliminar(context, doc.id, nombre),
                        ),
                      ),
                    ]),
                  ),
                  // Entrenador
                  if (entrenadorId != null)
                    _EntrenadorTile(entrenadorId: entrenadorId)
                  else
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                      child: Row(children: [
                        Icon(Icons.sports, color: Colors.grey.shade400, size: 18),
                        const SizedBox(width: 8),
                        Text('Sin entrenador asignado',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontStyle: FontStyle.italic)),
                      ]),
                    ),
                  if (jugadorIds.isNotEmpty) ...[
                    Divider(height: 1, color: Colors.grey.shade200),
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 10, 14, 4),
                      child: Row(children: [
                        Icon(Icons.people, color: acDark, size: 16),
                        const SizedBox(width: 6),
                        Text('Jugadores (${jugadorIds.length})',
                            style: TextStyle(fontWeight: FontWeight.bold, color: acDark, fontSize: 13)),
                      ]),
                    ),
                    ...jugadorIds.map((jid) => _JugadorTile(uid: jid)),
                  ] else
                    Padding(
                      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
                      child: Row(children: [
                        Icon(Icons.person_off_outlined, color: Colors.grey.shade400, size: 18),
                        const SizedBox(width: 8),
                        Text('Sin jugadores',
                            style: TextStyle(color: Colors.grey.shade500, fontSize: 13, fontStyle: FontStyle.italic)),
                      ]),
                    ),
                  const SizedBox(height: 8),
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
        label: const Text('Nuevo Equipo'),
      ),
    );
  }

  static const _deportes = ['Fútbol', 'Baloncesto', 'Pádel', 'Tenis'];

  void _agregar(BuildContext context) {
    final nc = TextEditingController();
    String deporte = 'Fútbol';
    String? entrenadorId;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, ss) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.group_add, color: acDark),
          SizedBox(width: 8),
          Text('Nuevo Equipo'),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _campo(nc, 'Nombre del equipo', Icons.groups),
          const SizedBox(height: 12),
          _dropDeporte(deporte, (v) => ss(() => deporte = v!)),
          const SizedBox(height: 12),
          _SelectorEntrenador(selectedId: entrenadorId, onChanged: (v) => ss(() => entrenadorId = v)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: acDark, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              if (nc.text.trim().isEmpty) return;
              await FirebaseFirestore.instance.collection('equipos').add({
                'nombre': nc.text.trim(), 'deporte': deporte, 'jugadoresIds': [],
                if (entrenadorId != null) 'entrenadorId': entrenadorId,
              });
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
    String? entrenadorId = data['entrenadorId'] as String?;

    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, ss) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(children: [
          Icon(Icons.edit, color: acDark),
          SizedBox(width: 8),
          Text('Editar Equipo'),
        ]),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          _campo(nc, 'Nombre', Icons.groups),
          const SizedBox(height: 12),
          _dropDeporte(deporte, (v) => ss(() => deporte = v!)),
          const SizedBox(height: 12),
          _SelectorEntrenador(selectedId: entrenadorId, onChanged: (v) => ss(() => entrenadorId = v)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
                backgroundColor: acDark, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              final updateData = <String, dynamic>{'nombre': nc.text.trim(), 'deporte': deporte};
              if (entrenadorId != null) updateData['entrenadorId'] = entrenadorId;
              else updateData['entrenadorId'] = FieldValue.delete();
              await FirebaseFirestore.instance.collection('equipos').doc(id).update(updateData);
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
    decoration: InputDecoration(
      labelText: label, prefixIcon: Icon(icon, color: acDark),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: acDark, width: 2)),
    ),
  );

  Widget _dropDeporte(String value, ValueChanged<String?> onChanged) => Container(
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

class _EntrenadorTile extends StatelessWidget {
  final String entrenadorId;
  const _EntrenadorTile({required this.entrenadorId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('usuarios').doc(entrenadorId).get(),
      builder: (_, snap) {
        final d = snap.data?.data() as Map<String, dynamic>?;
        final nombre = d?['nombre'] ?? 'Entrenador';
        return Container(
          margin: const EdgeInsets.fromLTRB(14, 10, 14, 0),
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: const Color(0xFFD946EF).withOpacity(0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: const Color(0xFFD946EF).withOpacity(0.3)),
          ),
          child: Row(children: [
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFD946EF),
              child: Icon(Icons.sports, color: Colors.white, size: 16),
            ),
            const SizedBox(width: 10),
            Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('ENTRENADOR',
                  style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold,
                      color: Color(0xFFD946EF), letterSpacing: 1)),
              Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            ]),
          ]),
        );
      },
    );
  }
}

class _JugadorTile extends StatelessWidget {
  final String uid;
  const _JugadorTile({required this.uid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('usuarios').doc(uid).get(),
      builder: (_, snap) {
        final d = snap.data?.data() as Map<String, dynamic>?;
        final nombre   = d?['nombre'] ?? 'Jugador';
        final posicion = d?['posicion'] as String? ?? '';
        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
          child: Row(children: [
            CircleAvatar(
              radius: 14,
              backgroundColor: const Color(0xFFD946EF).withOpacity(0.15),
              child: const Icon(Icons.person, size: 14, color: Color(0xFFD946EF)),
            ),
            const SizedBox(width: 10),
            Expanded(child: Text(nombre,
                style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500))),
            if (posicion.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: const Color(0xFFD946EF).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(posicion,
                    style: const TextStyle(fontSize: 11, color: Color(0xFFD946EF))),
              ),
          ]),
        );
      },
    );
  }
}

class _SelectorEntrenador extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  const _SelectorEntrenador({required this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('usuarios').where('rol', isEqualTo: 'entrenador').get(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const LinearProgressIndicator(color: Color(0xFFD946EF));
        }
        return Container(
          decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFD946EF)),
              borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              hint: const Row(children: [
                Icon(Icons.sports, color: Color(0xFFD946EF), size: 18),
                SizedBox(width: 8),
                Text('Entrenador (opcional)'),
              ]),
              value: selectedId, isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD946EF)),
              items: [
                const DropdownMenuItem<String>(value: null, child: Text('Sin entrenador')),
                ...snap.data!.docs.map((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  return DropdownMenuItem<String>(
                      value: doc.id, child: Text(d['nombre'] ?? doc.id));
                }),
              ],
              onChanged: onChanged,
            ),
          ),
        );
      },
    );
  }
}