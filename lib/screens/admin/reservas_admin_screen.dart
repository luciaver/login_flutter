import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservasAdminScreen extends StatefulWidget {
  const ReservasAdminScreen({super.key});
  @override
  State<ReservasAdminScreen> createState() => _ReservasAdminScreenState();
}

class _ReservasAdminScreenState extends State<ReservasAdminScreen> {
  static const Color ac = Color(0xFFD946EF);

  final Map<String, String> _estadosLocales = {};

  Color _estadoColor(String e) {
    switch (e) {
      case 'confirmada': return Colors.green;
      case 'cancelada':  return Colors.red;
      default:           return Colors.orange;
    }
  }

  IconData _estadoIcon(String e) {
    switch (e) {
      case 'confirmada': return Icons.check_circle_outline;
      case 'cancelada':  return Icons.cancel_outlined;
      default:           return Icons.hourglass_empty;
    }
  }

  Future<void> _cambiarEstado(String docId, String nuevoEstado) async {
    setState(() => _estadosLocales[docId] = nuevoEstado);

    try {
      await FirebaseFirestore.instance
          .collection('reservas')
          .doc(docId)
          .update({'estado': nuevoEstado});
    } catch (e) {

      setState(() => _estadosLocales.remove(docId));
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Error al cambiar estado: $e'),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final stream = FirebaseFirestore.instance
        .collection('reservas')
        .orderBy('fecha', descending: true)
        .snapshots();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF0FF),
      appBar: AppBar(
        title: const Text('Reservas', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: ac,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: Column(children: [
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: ac));
              }
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('🗓️', style: TextStyle(fontSize: 52)),
                    const SizedBox(height: 10),
                    Text('No hay reservas aquí',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 15)),
                  ]),
                );
              }
              return ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: snap.data!.docs.length,
                itemBuilder: (_, i) {
                  final doc = snap.data!.docs[i];
                  final d = doc.data() as Map<String, dynamic>;

                  // Usar estado local si existe, si no el de Firestore
                  final estado = _estadosLocales[doc.id] ?? d['estado'] ?? 'pendiente';

                  final pista    = d['pistaNombre'] ?? 'Pista';
                  final horaIni  = d['horaInicio'] ?? '';
                  final horaFin  = d['horaFin'] ?? '';
                  final usuarioId = d['usuarioId'] as String?;
                  String fecha = '';
                  try {
                    final dt = DateTime.parse(d['fecha']);
                    fecha = '${dt.day}/${dt.month}/${dt.year}';
                  } catch (_) {}

                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    elevation: 2,
                    margin: const EdgeInsets.only(bottom: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                        // Pista y estado
                        Row(children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: ac.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(Icons.sports_tennis, color: ac, size: 20),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              pista,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: _estadoColor(estado).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                  color: _estadoColor(estado).withOpacity(0.3)),
                            ),
                            child: Row(mainAxisSize: MainAxisSize.min, children: [
                              Icon(_estadoIcon(estado),
                                  size: 13, color: _estadoColor(estado)),
                              const SizedBox(width: 4),
                              Text(
                                estado,
                                style: TextStyle(
                                  color: _estadoColor(estado),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ]),
                          ),
                        ]),
                        const SizedBox(height: 10),
                        // Fecha y hora
                        Row(children: [
                          Icon(Icons.today, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 5),
                          Text(fecha,
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                          const SizedBox(width: 14),
                          Icon(Icons.access_time, size: 14, color: Colors.grey.shade500),
                          const SizedBox(width: 5),
                          Text('$horaIni - $horaFin',
                              style: TextStyle(fontSize: 13, color: Colors.grey.shade700)),
                        ]),
                        const SizedBox(height: 6),
                        if (usuarioId != null) _NombreUsuario(uid: usuarioId),
                        const SizedBox(height: 10),
                        // Cambiar estado
                        Row(mainAxisAlignment: MainAxisAlignment.end, children: [
                          PopupMenuButton<String>(
                            onSelected: (val) => _cambiarEstado(doc.id, val),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12)),
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: ac.withOpacity(0.1),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(color: ac.withOpacity(0.3)),
                              ),
                              child: Row(mainAxisSize: MainAxisSize.min, children: [
                                Icon(Icons.edit_note, color: ac, size: 16),
                                const SizedBox(width: 5),
                                Text('Cambiar estado',
                                    style: TextStyle(
                                        color: ac,
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold)),
                                Icon(Icons.arrow_drop_down, color: ac, size: 18),
                              ]),
                            ),
                            itemBuilder: (_) => const [
                              PopupMenuItem(value: 'confirmada', child: Text(' Confirmar')),
                              PopupMenuItem(value: 'pendiente',  child: Text(' Pendiente')),
                              PopupMenuItem(value: 'cancelada',  child: Text(' Cancelar')),
                            ],
                          ),
                        ]),
                      ]),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ]),
    );
  }
}

class _NombreUsuario extends StatelessWidget {
  final String uid;
  const _NombreUsuario({required this.uid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('usuarios').doc(uid).get(),
      builder: (_, snap) {
        final d = snap.data?.data() as Map<String, dynamic>?;
        final nombre = d?['nombre'] ?? 'Usuario';
        return Row(children: [
          Icon(Icons.person_outline, size: 14, color: Colors.pink.shade300),
          const SizedBox(width: 5),
          Text(
            nombre,
            style: TextStyle(
                fontSize: 13,
                color: Colors.pink.shade400,
                fontWeight: FontWeight.w500),
          ),
        ]);
      },
    );
  }
}