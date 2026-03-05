import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PartidosScreen extends StatelessWidget {
  const PartidosScreen({super.key});

  static const Color ac     = Color(0xFFF0ABFC);
  static const Color acDark = Color(0xFFD946EF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF0FF),
      appBar: AppBar(
        title: const Text('Partidos', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: acDark,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('partidos')
            .orderBy('fecha', descending: true)
            .snapshots(),
        builder: (_, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator(color: acDark));
          }

          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return Center(
              child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                const Text('⚽', style: TextStyle(fontSize: 56)),
                const SizedBox(height: 12),
                Text('No hay partidos creados',
                    style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
                const SizedBox(height: 4),
                Text('Pulsa + para crear el primero',
                    style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
              ]),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 100),
            itemCount: snap.data!.docs.length,
            itemBuilder: (_, i) {
              final doc   = snap.data!.docs[i];
              final d     = doc.data() as Map<String, dynamic>;
              final estado = d['estado'] ?? 'programado';

              String fecha = '';
              String hora  = '';
              try {
                final dt = DateTime.parse(d['fecha']);
                fecha = '${dt.day.toString().padLeft(2,'0')}/${dt.month.toString().padLeft(2,'0')}/${dt.year}';
                hora  = '${dt.hour.toString().padLeft(2,'0')}:${dt.minute.toString().padLeft(2,'0')}';
              } catch (_) {}

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(color: acDark.withOpacity(0.12), blurRadius: 10, offset: const Offset(0, 4)),
                  ],
                ),
                child: Column(children: [
                  // Cabecera con degradado
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [acDark.withOpacity(0.12), ac.withOpacity(0.08)],
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                      ),
                      borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
                    ),
                    child: Row(children: [
                      _estadoBadge(estado),
                      const Spacer(),
                      Expanded(
                        flex: 5,
                        child: _NombresVs(
                          localId:     d['equipoLocalId'],
                          visitanteId: d['equipoVisitanteId'],
                        ),
                      ),
                      const Spacer(),
                    ]),
                  ),
                  // Fecha, hora, árbitro
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 10, 16, 4),
                    child: Row(children: [
                      if (fecha.isNotEmpty) ...[
                        const Icon(Icons.calendar_today, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(fecha, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                        const SizedBox(width: 14),
                      ],
                      if (hora.isNotEmpty && hora != '00:00') ...[
                        const Icon(Icons.access_time, size: 13, color: Colors.grey),
                        const SizedBox(width: 4),
                        Text(hora, style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                      ],
                      const Spacer(),
                      if (d['arbitroId'] != null) _ArbitroChip(arbitroId: d['arbitroId']),
                    ]),
                  ),
                  // Resultado si existe
                  if (d['golLocal'] != null && d['golVisitante'] != null)
                    Padding(
                      padding: const EdgeInsets.fromLTRB(16, 4, 16, 4),
                      child: Row(children: [
                        const Icon(Icons.sports_score, size: 15, color: acDark),
                        const SizedBox(width: 6),
                        Text(
                          'Resultado: ${d['golLocal']} - ${d['golVisitante']}',
                          style: const TextStyle(
                              fontSize: 13, fontWeight: FontWeight.bold, color: acDark),
                        ),
                      ]),
                    ),
                  // Botones editar / eliminar
                  Padding(
                    padding: const EdgeInsets.fromLTRB(12, 4, 12, 12),
                    child: Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                      TextButton.icon(
                        onPressed: () => _editar(context, doc.id, d),
                        icon: const Icon(Icons.edit_note, size: 16),
                        label: const Text('Editar'),
                        style: TextButton.styleFrom(foregroundColor: acDark),
                      ),
                      const SizedBox(width: 4),
                      TextButton.icon(
                        onPressed: () => _eliminar(context, doc.id),
                        icon: const Icon(Icons.delete_outline, size: 16),
                        label: const Text('Eliminar'),
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
        onPressed: () => _crear(context),
        backgroundColor: acDark,
        icon: const Icon(Icons.add),
        label: const Text('Nuevo Partido', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
    );
  }

  // estado de partidos

  Widget _estadoBadge(String estado) {
    Color c;
    switch (estado) {
      case 'finalizado': c = Colors.green;  break;
      case 'en_curso':   c = Colors.orange; break;
      case 'cancelado':  c = Colors.red;    break;
      default:           c = Colors.blue;   break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Text(
        estado.replaceAll('_', ' '),
        style: TextStyle(color: c, fontSize: 11, fontWeight: FontWeight.bold),
      ),
    );
  }

  // snaclbar

  void _snack(BuildContext ctx, String msg, Color color) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(
      content: Text(msg),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  //crear

  void _crear(BuildContext context) {
    _mostrarFormulario(context, null, null);
  }

  // editae

  void _editar(BuildContext context, String id, Map<String, dynamic> data) {
    _mostrarFormulario(context, id, data);
  }

  // CREAR / EDITAR

  void _mostrarFormulario(BuildContext context, String? docId, Map<String, dynamic>? data) {
    // Valores iniciales
    String? equipoLocalId     = data?['equipoLocalId']     as String?;
    String? equipoVisitanteId = data?['equipoVisitanteId'] as String?;
    String? arbitroId         = data?['arbitroId']         as String?;
    String  estado            = data?['estado']            as String? ?? 'programado';
    DateTime? fechaHora;
    String  golLocal          = data?['golLocal']?.toString()     ?? '';
    String  golVisitante      = data?['golVisitante']?.toString() ?? '';

    // Parsear fecha si existe
    if (data?['fecha'] != null) {
      try { fechaHora = DateTime.parse(data!['fecha']); } catch (_) {}
    }

    final golLocalCtrl     = TextEditingController(text: golLocal);
    final golVisitanteCtrl = TextEditingController(text: golVisitante);

    final esEdicion = docId != null;

    showDialog(
      context: context,
      builder: (dCtx) => StatefulBuilder(
        builder: (ctx, ss) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: Row(children: [
            Icon(esEdicion ? Icons.edit : Icons.add_circle, color: acDark),
            const SizedBox(width: 8),
            Text(esEdicion ? 'Editar Partido' : 'Nuevo Partido',
                style: const TextStyle(fontWeight: FontWeight.bold)),
          ]),
          content: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [

              // Equipo local
              _labelSeccion('Equipo Local', Icons.home, acDark),
              const SizedBox(height: 6),
              _SelectorEquipo(
                selectedId: equipoLocalId,
                hint: 'Seleccionar equipo local',
                onChanged: (v) => ss(() => equipoLocalId = v),
              ),
              const SizedBox(height: 12),

              // Equipo visitante
              _labelSeccion('Equipo Visitante', Icons.flight_land, acDark),
              const SizedBox(height: 6),
              _SelectorEquipo(
                selectedId: equipoVisitanteId,
                hint: 'Seleccionar equipo visitante',
                onChanged: (v) => ss(() => equipoVisitanteId = v),
              ),
              const SizedBox(height: 12),

              //Árbitro
              _labelSeccion('Árbitro', Icons.sports, acDark),
              const SizedBox(height: 6),
              _SelectorArbitro(
                selectedId: arbitroId,
                onChanged: (v) => ss(() => arbitroId = v),
              ),
              const SizedBox(height: 12),

              // ── Fecha y hora
              _labelSeccion('Fecha y Hora', Icons.calendar_today, acDark),
              const SizedBox(height: 6),
              GestureDetector(
                onTap: () async {
                  final fecha = await showDatePicker(
                    context: ctx,
                    initialDate: fechaHora ?? DateTime.now(),
                    firstDate: DateTime(2020),
                    lastDate: DateTime(2030),
                    builder: (c, child) => Theme(
                      data: Theme.of(c).copyWith(
                        colorScheme: const ColorScheme.light(
                            primary: acDark, onPrimary: Colors.white),
                      ),
                      child: child!,
                    ),
                  );
                  if (fecha == null) return;
                  final hora = await showTimePicker(
                    context: ctx,
                    initialTime: fechaHora != null
                        ? TimeOfDay(hour: fechaHora!.hour, minute: fechaHora!.minute)
                        : const TimeOfDay(hour: 18, minute: 0),
                    builder: (c, child) => Theme(
                      data: Theme.of(c).copyWith(
                        colorScheme: const ColorScheme.light(
                            primary: acDark, onPrimary: Colors.white),
                      ),
                      child: child!,
                    ),
                  );
                  if (hora == null) return;
                  ss(() {
                    fechaHora = DateTime(fecha.year, fecha.month, fecha.day, hora.hour, hora.minute);
                  });
                },
                child: Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    border: Border.all(color: fechaHora != null ? acDark : Colors.grey.shade400),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(children: [
                    Icon(Icons.calendar_today, color: acDark, size: 18),
                    const SizedBox(width: 10),
                    Text(
                      fechaHora != null
                          ? '${fechaHora!.day.toString().padLeft(2,'0')}/${fechaHora!.month.toString().padLeft(2,'0')}/${fechaHora!.year}  '
                          '${fechaHora!.hour.toString().padLeft(2,'0')}:${fechaHora!.minute.toString().padLeft(2,'0')}'
                          : 'Seleccionar fecha y hora',
                      style: TextStyle(
                        color: fechaHora != null ? Colors.black87 : Colors.grey.shade500,
                      ),
                    ),
                  ]),
                ),
              ),
              const SizedBox(height: 12),

              // Estado
              _labelSeccion('Estado', Icons.flag, acDark),
              const SizedBox(height: 6),
              _dropEstado(
                value: estado,
                onChanged: (v) => ss(() => estado = v!),
              ),
              const SizedBox(height: 12),

              // Resultado
              _labelSeccion('Resultado (opcional)', Icons.sports_score, acDark),
              const SizedBox(height: 6),
              Row(children: [
                Expanded(
                  child: _campoGol(golLocalCtrl, 'Goles local'),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8),
                  child: Text('–', style: TextStyle(fontSize: 20, color: Colors.grey.shade500)),
                ),
                Expanded(
                  child: _campoGol(golVisitanteCtrl, 'Goles visit.'),
                ),
              ]),
            ]),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dCtx),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
            ),
            ElevatedButton.icon(
              icon: Icon(esEdicion ? Icons.save : Icons.add, size: 16),
              label: Text(esEdicion ? 'Guardar' : 'Crear'),
              style: ElevatedButton.styleFrom(
                backgroundColor: acDark,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () async {
                if (equipoLocalId == null || equipoVisitanteId == null) {
                  _snack(ctx, 'Selecciona ambos equipos', Colors.orange);
                  return;
                }
                if (equipoLocalId == equipoVisitanteId) {
                  _snack(ctx, 'Los equipos no pueden ser el mismo', Colors.orange);
                  return;
                }
                if (fechaHora == null) {
                  _snack(ctx, 'Selecciona fecha y hora', Colors.orange);
                  return;
                }

                final payload = <String, dynamic>{
                  'equipoLocalId':     equipoLocalId,
                  'equipoVisitanteId': equipoVisitanteId,
                  'fecha':             fechaHora!.toIso8601String(),
                  'estado':            estado,
                  if (arbitroId != null) 'arbitroId': arbitroId,
                  if (golLocalCtrl.text.trim().isNotEmpty)
                    'golLocal': int.tryParse(golLocalCtrl.text.trim()) ?? 0,
                  if (golVisitanteCtrl.text.trim().isNotEmpty)
                    'golVisitante': int.tryParse(golVisitanteCtrl.text.trim()) ?? 0,
                };

                try {
                  if (esEdicion) {
                    await FirebaseFirestore.instance
                        .collection('partidos')
                        .doc(docId)
                        .update(payload);
                  } else {
                    await FirebaseFirestore.instance
                        .collection('partidos')
                        .add(payload);
                  }
                  Navigator.pop(dCtx);
                  _snack(
                    context,
                    esEdicion ? 'Partido actualizado' : '¡Partido creado!',
                    acDark,
                  );
                } catch (e) {
                  _snack(ctx, 'Error: $e', Colors.red);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  //ELIMINAR

  void _eliminar(BuildContext context, String id) {
    showDialog(
      context: context,
      builder: (dCtx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Eliminar Partido'),
        content: const Text('¿Estás seguro de que quieres eliminar este partido? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dCtx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            icon: const Icon(Icons.delete, size: 16),
            label: const Text('Eliminar'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            onPressed: () async {
              try {
                await FirebaseFirestore.instance.collection('partidos').doc(id).delete();
                Navigator.pop(dCtx);
                _snack(context, 'Partido eliminado', Colors.red.shade700);
              } catch (e) {
                Navigator.pop(dCtx);
                _snack(context, 'Error al eliminar: $e', Colors.red);
              }
            },
          ),
        ],
      ),
    );
  }


  Widget _labelSeccion(String label, IconData icon, Color color) {
    return Row(children: [
      Icon(icon, size: 15, color: color),
      const SizedBox(width: 6),
      Text(label, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: color)),
    ]);
  }

  Widget _dropEstado({required String value, required ValueChanged<String?> onChanged}) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: acDark),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          isExpanded: true,
          icon: const Icon(Icons.arrow_drop_down, color: acDark),
          items: const [
            DropdownMenuItem(value: 'programado',  child: Text('  Programado')),
            DropdownMenuItem(value: 'en_curso',    child: Text('  En curso')),
            DropdownMenuItem(value: 'finalizado',  child: Text('  Finalizado')),
            DropdownMenuItem(value: 'cancelado',   child: Text('  Cancelado')),
          ],
          onChanged: onChanged,
        ),
      ),
    );
  }

  Widget _campoGol(TextEditingController ctrl, String label) {
    return TextField(
      controller: ctrl,
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 11),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: acDark, width: 2),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
      ),
    );
  }
}

//Selector de equipo

class _SelectorEquipo extends StatelessWidget {
  final String? selectedId;
  final String  hint;
  final ValueChanged<String?> onChanged;

  const _SelectorEquipo({
    required this.selectedId,
    required this.hint,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('equipos').get(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: PartidosScreen.acDark),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const LinearProgressIndicator(color: PartidosScreen.acDark),
          );
        }

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: PartidosScreen.acDark),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedId,
              isExpanded: true,
              hint: Text(hint, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              icon: const Icon(Icons.arrow_drop_down, color: PartidosScreen.acDark),
              items: snap.data!.docs.map((doc) {
                final d = doc.data() as Map<String, dynamic>;
                return DropdownMenuItem<String>(
                  value: doc.id,
                  child: Row(children: [
                    const Icon(Icons.groups, size: 16, color: PartidosScreen.acDark),
                    const SizedBox(width: 8),
                    Text(d['nombre'] ?? doc.id),
                  ]),
                );
              }).toList(),
              onChanged: onChanged,
            ),
          ),
        );
      },
    );
  }
}

//Selector de árbitro

class _SelectorArbitro extends StatelessWidget {
  final String? selectedId;
  final ValueChanged<String?> onChanged;

  const _SelectorArbitro({required this.selectedId, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('usuarios')
          .where('rol', isEqualTo: 'arbitro')
          .get(),
      builder: (_, snap) {
        if (!snap.hasData) {
          return Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: PartidosScreen.acDark),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const LinearProgressIndicator(color: PartidosScreen.acDark),
          );
        }

        return Container(
          decoration: BoxDecoration(
            border: Border.all(color: PartidosScreen.acDark),
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: selectedId,
              isExpanded: true,
              hint: Row(children: [
                const Icon(Icons.sports, size: 16, color: PartidosScreen.acDark),
                const SizedBox(width: 8),
                Text('Árbitro (opcional)', style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
              ]),
              icon: const Icon(Icons.arrow_drop_down, color: PartidosScreen.acDark),
              items: [
                const DropdownMenuItem<String>(value: null, child: Text('Sin árbitro')),
                ...snap.data!.docs.map((doc) {
                  final d = doc.data() as Map<String, dynamic>;
                  return DropdownMenuItem<String>(
                    value: doc.id,
                    child: Row(children: [
                      const Icon(Icons.sports, size: 16, color: PartidosScreen.acDark),
                      const SizedBox(width: 8),
                      Text(d['nombre'] ?? doc.id),
                    ]),
                  );
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

// VS con nombres de equipos

class _NombresVs extends StatelessWidget {
  final String? localId, visitanteId;
  const _NombresVs({this.localId, this.visitanteId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: Future.wait([_nombre(localId), _nombre(visitanteId)]),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Text('Cargando...', style: TextStyle(fontSize: 13, color: Colors.grey));
        }
        final local     = snap.data![0];
        final visitante = snap.data![1];
        return Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          Flexible(
            child: Text(local,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right),
          ),
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: PartidosScreen.acDark.withOpacity(0.15),
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Text('VS',
                style: TextStyle(
                    fontWeight: FontWeight.w900, fontSize: 13,
                    color: PartidosScreen.acDark, letterSpacing: 1)),
          ),
          Flexible(
            child: Text(visitante,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left),
          ),
        ]);
      },
    );
  }

  Future<String> _nombre(String? id) async {
    if (id == null) return '?';
    try {
      final doc = await FirebaseFirestore.instance.collection('equipos').doc(id).get();
      return (doc.data() as Map<String, dynamic>?)?['nombre'] ?? id;
    } catch (_) {
      return id;
    }
  }
}

// Chip de árbitro

class _ArbitroChip extends StatelessWidget {
  final String arbitroId;
  const _ArbitroChip({required this.arbitroId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('usuarios').doc(arbitroId).get(),
      builder: (_, snap) {
        final d      = snap.data?.data() as Map<String, dynamic>?;
        final nombre = d?['nombre'] ?? 'Árbitro';
        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            Icon(Icons.sports, size: 12, color: Colors.grey.shade600),
            const SizedBox(width: 4),
            Text(nombre, style: TextStyle(fontSize: 11, color: Colors.grey.shade700)),
          ]),
        );
      },
    );
  }
}