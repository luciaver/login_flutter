import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PartidosScreen extends StatelessWidget {
  const PartidosScreen({super.key});
  static const Color ac = Color(0xFFF0ABFC);
  static const Color acDark = Color(0xFFD946EF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Partidos'), backgroundColor: acDark, foregroundColor: Colors.white),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance.collection('partidos').orderBy('fecha', descending: true).snapshots(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: acDark));
          }
          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return const Center(child: Text('No hay partidos'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: snap.data!.docs.length,
            itemBuilder: (_, i) {
              final doc = snap.data!.docs[i];
              final d = doc.data() as Map<String, dynamic>;
              final estado = d['estado'] ?? 'programado';
              String fecha = '';
              try {
                final dt = DateTime.parse(d['fecha']);
                fecha = '${dt.day}/${dt.month}/${dt.year}  ${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
              } catch (_) {}
              return Card(
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                elevation: 3, margin: const EdgeInsets.only(bottom: 10),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(color: acDark.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(10)),
                        child: const Icon(Icons.sports_soccer, color: acDark, size: 20),
                      ),
                      const SizedBox(width: 10),
                      Expanded(child: _NombresVs(localId: d['equipoLocalId'], visitanteId: d['equipoVisitanteId'])),
                      _estadoBadge(estado),
                    ]),
                    if (fecha.isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text('📅 $fecha', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                    ],
                    Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      TextButton(onPressed: () => _editar(context, doc.id, d),
                          child: const Text('Editar', style: TextStyle(color: acDark))),
                      TextButton(onPressed: () => _eliminar(context, doc.id),
                          child: const Text('Eliminar', style: TextStyle(color: Colors.red))),
                    ]),
                  ]),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _crear(context), backgroundColor: acDark,
        icon: const Icon(Icons.add), label: const Text('Nuevo Partido'),
      ),
    );
  }

  Widget _estadoBadge(String estado) {
    Color c; switch (estado) {
      case 'finalizado': c = Colors.green; break;
      case 'en_curso':   c = Colors.orange; break;
      case 'cancelado':  c = Colors.red; break;
      default:           c = Colors.blue;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(color: c.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
      child: Text(estado.replaceAll('_', ' '),
          style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.bold)),
    );
  }

  void _crear(BuildContext context) {
    String? localId, visitanteId, arbitroId;
    DateTime fecha = DateTime.now();
    String fechaDisp = '${fecha.day}/${fecha.month}/${fecha.year}';
    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, ss) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Nuevo Partido'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          _SelectorEquipo(label: 'Equipo Local', selectedId: localId, onChanged: (v) => ss(() => localId = v)),
          const SizedBox(height: 10),
          _SelectorEquipo(label: 'Equipo Visitante', selectedId: visitanteId, onChanged: (v) => ss(() => visitanteId = v)),
          const SizedBox(height: 10),
          _SelectorArbitro(selectedId: arbitroId, onChanged: (v) => ss(() => arbitroId = v)),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final p = await showDatePicker(context: ctx, initialDate: fecha,
                firstDate: DateTime.now(), lastDate: DateTime.now().add(const Duration(days: 365)),
                builder: (c, child) => Theme(
                  data: Theme.of(c).copyWith(
                      colorScheme: const ColorScheme.light(primary: acDark, onPrimary: Colors.white)),
                  child: child!,
                ),
              );
              if (p != null) ss(() { fecha = p; fechaDisp = '${p.day}/${p.month}/${p.year}'; });
            },
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(border: Border.all(color: acDark),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(children: [
                const Icon(Icons.calendar_today, color: acDark),
                const SizedBox(width: 10),
                Text(fechaDisp),
              ]),
            ),
          ),
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: acDark, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              if (localId == null || visitanteId == null) {
                ScaffoldMessenger.of(ctx).showSnackBar(const SnackBar(
                    content: Text('Selecciona ambos equipos'), backgroundColor: Colors.orange));
                return;
              }
              await FirebaseFirestore.instance.collection('partidos').add({
                'equipoLocalId': localId, 'equipoVisitanteId': visitanteId,
                'arbitroId': arbitroId, 'fecha': fecha.toIso8601String(), 'estado': 'programado',
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
    String estado = data['estado'] ?? 'programado';
    showDialog(context: context, builder: (ctx) => StatefulBuilder(
      builder: (ctx, ss) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Cambiar estado'),
        content: Container(
          decoration: BoxDecoration(border: Border.all(color: acDark), borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: estado, isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: acDark),
              items: const [
                DropdownMenuItem(value: 'programado', child: Text('Programado')),
                DropdownMenuItem(value: 'en_curso',   child: Text('En curso')),
                DropdownMenuItem(value: 'finalizado', child: Text('Finalizado')),
                DropdownMenuItem(value: 'cancelado',  child: Text('Cancelado')),
              ],
              onChanged: (v) => ss(() => estado = v!),
            ),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: acDark, foregroundColor: Colors.white),
            onPressed: () async {
              await FirebaseFirestore.instance.collection('partidos').doc(id).update({'estado': estado});
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    ));
  }

  void _eliminar(BuildContext context, String id) {
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      title: const Text('Eliminar partido'),
      content: const Text('¿Segura que quieres eliminar este partido?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('No')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
          onPressed: () async {
            await FirebaseFirestore.instance.collection('partidos').doc(id).delete();
            Navigator.pop(ctx);
          },
          child: const Text('Sí, eliminar'),
        ),
      ],
    ));
  }
}

class _NombresVs extends StatelessWidget {
  final String? localId, visitanteId;
  const _NombresVs({this.localId, this.visitanteId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: Future.wait([
        _nombre(localId), _nombre(visitanteId),
      ]),
      builder: (_, snap) {
        final local = snap.data?[0] ?? '...';
        final visitante = snap.data?[1] ?? '...';
        return Text('$local  vs  $visitante',
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14));
      },
    );
  }

  Future<String> _nombre(String? id) async {
    if (id == null) return '?';
    try {
      final doc = await FirebaseFirestore.instance.collection('equipos').doc(id).get();
      return (doc.data() as Map<String, dynamic>?)?['nombre'] ?? id;
    } catch (_) { return id; }
  }
}

class _SelectorEquipo extends StatelessWidget {
  final String label;
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  const _SelectorEquipo({required this.label, required this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('equipos').get(),
      builder: (_, snap) {
        if (!snap.hasData) return const LinearProgressIndicator();
        return Container(
          decoration: BoxDecoration(border: Border.all(color: PartidosScreen.acDark),
              borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              hint: Text(label), value: selectedId, isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: PartidosScreen.acDark),
              items: snap.data!.docs.map((doc) {
                final d = doc.data() as Map<String, dynamic>;
                return DropdownMenuItem(value: doc.id, child: Text(d['nombre'] ?? doc.id));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        );
      },
    );
  }
}

class _SelectorArbitro extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<String?> onChanged;
  const _SelectorArbitro({required this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('usuarios').where('rol', isEqualTo: 'arbitro').get(),
      builder: (_, snap) {
        if (!snap.hasData) return const LinearProgressIndicator();
        return Container(
          decoration: BoxDecoration(border: Border.all(color: PartidosScreen.acDark),
              borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              hint: const Text('Árbitro (opcional)'), value: selectedId, isExpanded: true,
              icon: const Icon(Icons.arrow_drop_down, color: PartidosScreen.acDark),
              items: snap.data!.docs.map((doc) {
                final d = doc.data() as Map<String, dynamic>;
                return DropdownMenuItem(value: doc.id, child: Text(d['nombre'] ?? doc.id));
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        );
      },
    );
  }
}