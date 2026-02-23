import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// ─── Sección título ───────────────────────────────────────────
class SeccionTitulo extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Color color;
  const SeccionTitulo({super.key, required this.titulo, required this.icono, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: color, size: 20),
        const SizedBox(width: 8),
        Text(titulo, style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}

// ─── Card vacía ───────────────────────────────────────────────
class CardVacia extends StatelessWidget {
  final String texto;
  const CardVacia({super.key, required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade400, size: 18),
          const SizedBox(width: 10),
          Text(texto, style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        ],
      ),
    );
  }
}

// ─── Stats row ────────────────────────────────────────────────
class StatsRow extends StatelessWidget {
  final String uid;
  final String rol;
  const StatsRow({super.key, required this.uid, required this.rol});

  @override
  Widget build(BuildContext context) {
    if (rol == 'arbitro') {
      return _StatCard(
        label: 'Partidos',
        icono: Icons.sports_soccer,
        color: const Color(0xFF8B5CF6),
        stream: FirebaseFirestore.instance.collection('partidos').where('arbitroId', isEqualTo: uid).snapshots(),
      );
    }
    return Row(
      children: [
        Expanded(child: _StatCard(
          label: 'Reservas', icono: Icons.calendar_today, color: const Color(0xFF6B4CE6),
          stream: FirebaseFirestore.instance.collection('reservas').where('usuarioId', isEqualTo: uid).snapshots(),
        )),
        const SizedBox(width: 12),
        Expanded(child: _StatCard(
          label: 'Equipos', icono: Icons.groups, color: const Color(0xFFF59E0B),
          stream: rol == 'entrenador'
              ? FirebaseFirestore.instance.collection('equipos').where('entrenadorId', isEqualTo: uid).snapshots()
              : FirebaseFirestore.instance.collection('equipos').where('jugadoresIds', arrayContains: uid).snapshots(),
        )),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final IconData icono;
  final Color color;
  final Stream<QuerySnapshot> stream;
  const _StatCard({required this.label, required this.icono, required this.color, required this.stream});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icono, color: color, size: 24),
              const SizedBox(height: 6),
              Text('$count', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
              Text(label, style: TextStyle(fontSize: 11, color: color), textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
  }
}

// ─── Reserva card ─────────────────────────────────────────────
class ReservaCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const ReservaCard({super.key, required this.data});

  Color _color(String e) {
    switch (e) {
      case 'confirmada': return Colors.green;
      case 'cancelada':  return Colors.red;
      default:           return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = data['estado'] ?? 'pendiente';
    final pistaNombre = data['pistaNombre'] ?? 'Pista';
    final horaInicio = data['horaInicio'] ?? '';
    final horaFin = data['horaFin'] ?? '';
    String fecha = data['fecha'] ?? '';
    try {
      final d = DateTime.parse(fecha);
      fecha = '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: const Color(0xFF6B4CE6).withOpacity(0.08), blurRadius: 10, offset: const Offset(0, 4))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF6B4CE6).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.sports_tennis, color: Color(0xFF6B4CE6), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pistaNombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('$fecha  $horaInicio - $horaFin', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: _color(estado).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(estado, style: TextStyle(color: _color(estado), fontSize: 11, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─── Próximas reservas ────────────────────────────────────────
class ProximasReservas extends StatelessWidget {
  final String uid;
  const ProximasReservas({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('reservas').where('usuarioId', isEqualTo: uid).orderBy('fecha').limit(3).snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const CardVacia(texto: 'No tienes reservas próximas');
        return Column(
          children: docs.map((d) => ReservaCard(data: d.data() as Map<String, dynamic>)).toList(),
        );
      },
    );
  }
}

// ─── Partidos list ────────────────────────────────────────────
class PartidosList extends StatelessWidget {
  final String uid;
  final bool soloArbitro;
  const PartidosList({super.key, required this.uid, this.soloArbitro = false});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('partidos').where('arbitroId', isEqualTo: uid).snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const CardVacia(texto: 'Sin partidos asignados');
        return Column(
          children: docs.map((d) => PartidoCard(data: d.data() as Map<String, dynamic>)).toList(),
        );
      },
    );
  }
}

// ─── Partidos del entrenador ──────────────────────────────────
class PartidosEntrenador extends StatelessWidget {
  final String uid;
  const PartidosEntrenador({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance.collection('equipos').where('entrenadorId', isEqualTo: uid).get(),
      builder: (ctx, snap) {
        final ids = snap.data?.docs.map((d) => d.id).toList() ?? [];
        if (ids.isEmpty) return const CardVacia(texto: 'Sin partidos pendientes');
        return StreamBuilder<QuerySnapshot>(
          stream: FirebaseFirestore.instance.collection('partidos').where('equipoLocalId', whereIn: ids).snapshots(),
          builder: (ctx2, snap2) {
            final docs = snap2.data?.docs ?? [];
            if (docs.isEmpty) return const CardVacia(texto: 'Sin partidos pendientes');
            return Column(
              children: docs.take(3).map((d) => PartidoCard(data: d.data() as Map<String, dynamic>)).toList(),
            );
          },
        );
      },
    );
  }
}

// ─── Partido card ─────────────────────────────────────────────
class PartidoCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const PartidoCard({super.key, required this.data});

  Color _color(String e) {
    switch (e) {
      case 'finalizado': return Colors.green;
      case 'en_curso':   return Colors.orange;
      case 'cancelado':  return Colors.red;
      default:           return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = data['estado'] ?? 'programado';
    String fecha = data['fecha'] ?? '';
    try {
      final d = DateTime.parse(fecha);
      fecha = '${d.day}/${d.month}/${d.year}';
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(color: const Color(0xFF8B5CF6).withOpacity(0.1), borderRadius: BorderRadius.circular(12)),
            child: const Icon(Icons.sports_soccer, color: Color(0xFF8B5CF6), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _NombreEquipo(id: data['equipoLocalId']),
                    const Text(' vs ', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
                    _NombreEquipo(id: data['equipoVisitanteId']),
                  ],
                ),
                Text('$fecha  ${data['horaInicio'] ?? ''}', style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(color: _color(estado).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
            child: Text(estado.replaceAll('_', ' '), style: TextStyle(color: _color(estado), fontSize: 10, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

class _NombreEquipo extends StatelessWidget {
  final String? id;
  const _NombreEquipo({this.id});

  @override
  Widget build(BuildContext context) {
    if (id == null) return const Text('?');
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('equipos').doc(id).get(),
      builder: (ctx, snap) {
        final d = snap.data?.data() as Map<String, dynamic>?;
        return Text(d?['nombre'] ?? id!, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13), overflow: TextOverflow.ellipsis);
      },
    );
  }
}

// ─── Equipo detalle card ──────────────────────────────────────
class EquipoDetalleCard extends StatelessWidget {
  final String equipoId;
  final Map<String, dynamic> data;
  final String rol;
  final String uid;
  const EquipoDetalleCard({super.key, required this.equipoId, required this.data, required this.rol, required this.uid});

  @override
  Widget build(BuildContext context) {
    final nombre = data['nombre'] ?? 'Equipo';
    final jugadoresIds = List<String>.from(data['jugadoresIds'] ?? []);

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF59E0B),
          child: Text(nombre[0].toUpperCase(), style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${jugadoresIds.length} jugadores'),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                ...jugadoresIds.map((jid) => _UsuarioTile(uid: jid)),
                if (rol == 'entrenador') ...[
                  const Divider(),
                  ElevatedButton.icon(
                    onPressed: () => _cancelarEntrenamiento(context),
                    icon: const Icon(Icons.warning_amber),
                    label: const Text('Cancelar entrenamiento'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E8C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _cancelarEntrenamiento(BuildContext context) {
    crearIncidencia(context, uid, data['nombre'] ?? '', 'entrenamiento_cancelado', 'Entrenamiento cancelado');
  }
}

class _UsuarioTile extends StatelessWidget {
  final String uid;
  const _UsuarioTile({required this.uid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('usuarios').doc(uid).get(),
      builder: (ctx, snap) {
        final d = snap.data?.data() as Map<String, dynamic>?;
        return ListTile(
          dense: true,
          leading: const CircleAvatar(radius: 14, backgroundColor: Color(0xFFE8E0FF), child: Icon(Icons.person, size: 16, color: Color(0xFF6B4CE6))),
          title: Text(d?['nombre'] ?? 'Jugador'),
          subtitle: (d?['posicion'] ?? '').isNotEmpty ? Text(d!['posicion']) : null,
        );
      },
    );
  }
}

// ─── Botón incidencia ─────────────────────────────────────────
class BotonIncidencia extends StatelessWidget {
  final String uid;
  final String tipo;
  const BotonIncidencia({super.key, required this.uid, required this.tipo});

  bool get _esEntrenador => tipo == 'entrenamiento_cancelado';

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _mostrarDialogo(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE91E8C).withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: const Color(0xFFE91E8C).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(_esEntrenador ? Icons.cancel_presentation : Icons.person_off_outlined, color: const Color(0xFFE91E8C), size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_esEntrenador ? 'Cancelar entrenamiento' : 'No puedo asistir',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFE91E8C))),
                  Text(_esEntrenador ? 'Notifica la cancelación' : 'Notifica que no asistirás',
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogo(BuildContext context) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(_esEntrenador ? 'Cancelar entrenamiento' : 'No puedo asistir'),
        content: TextField(
          controller: ctrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Motivo (opcional)',
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          ElevatedButton(
            onPressed: () async {
              await crearIncidencia(context, uid, '', tipo,
                  ctrl.text.trim().isNotEmpty ? ctrl.text.trim() : (_esEntrenador ? 'Entrenamiento cancelado' : 'El jugador no puede asistir'));
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFE91E8C), foregroundColor: Colors.white),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}

// ─── Lista incidencias ────────────────────────────────────────
class IncidenciasList extends StatelessWidget {
  final String uid;
  const IncidenciasList({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('incidencias').where('usuarioId', isEqualTo: uid).orderBy('fecha', descending: true).limit(5).snapshots(),
      builder: (context, snapshot) {
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const CardVacia(texto: 'Sin incidencias registradas');
        return Column(
          children: docs.map((d) {
            final data = d.data() as Map<String, dynamic>;
            final tipo = data['tipo'] ?? '';
            final mensaje = data['mensaje'] ?? '';
            String fecha = '';
            try { final dt = DateTime.parse(data['fecha']); fecha = '${dt.day}/${dt.month}/${dt.year}'; } catch (_) {}
            return Container(
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE91E8C).withOpacity(0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFFE91E8C).withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.warning_amber, color: Color(0xFFE91E8C), size: 18),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(tipo.replaceAll('_', ' '), style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: Color(0xFFE91E8C))),
                        if (mensaje.isNotEmpty) Text(mensaje, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                      ],
                    ),
                  ),
                  Text(fecha, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                ],
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ─── Perfil info card ─────────────────────────────────────────
class PerfilInfoCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const PerfilInfoCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    final items = <Map<String, dynamic>>[
      {'icon': Icons.email_outlined, 'label': 'Email', 'valor': data['email'] ?? ''},
      {'icon': Icons.phone_outlined, 'label': 'Teléfono', 'valor': data['telefono'] ?? ''},
      if ((data['edad'] ?? '').toString().isNotEmpty)
        {'icon': Icons.cake_outlined, 'label': 'Edad', 'valor': '${data['edad']} años'},
      if ((data['posicion'] ?? '').isNotEmpty)
        {'icon': Icons.sports_soccer_outlined, 'label': 'Posición', 'valor': data['posicion']},
    ];

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [BoxShadow(color: const Color(0xFF6B4CE6).withOpacity(0.08), blurRadius: 12, offset: const Offset(0, 4))],
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final item = e.value;
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(color: const Color(0xFF6B4CE6).withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                      child: Icon(item['icon'] as IconData, color: const Color(0xFF6B4CE6), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(item['label'], style: const TextStyle(fontSize: 11, color: Colors.grey)),
                        Text(item['valor']?.toString().isNotEmpty == true ? item['valor'] : '-',
                            style: const TextStyle(fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              ),
              if (!isLast) Divider(height: 1, color: Colors.grey.shade100),
            ],
          );
        }).toList(),
      ),
    );
  }
}

// ─── Función helper incidencia ────────────────────────────────
Future<void> crearIncidencia(BuildContext context, String uid, String equipo, String tipo, String mensaje) async {
  try {
    await FirebaseFirestore.instance.collection('incidencias').add({
      'usuarioId': uid,
      'tipo': tipo,
      'mensaje': mensaje,
      'equipo': equipo,
      'fecha': DateTime.now().toIso8601String(),
      'leida': false,
    });
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: const Text('Incidencia enviada'),
      backgroundColor: Colors.green,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ));
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
  }
}