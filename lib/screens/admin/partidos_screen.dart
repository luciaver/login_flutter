import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PartidosScreen extends StatelessWidget {
  const PartidosScreen({super.key});

  static const Color ac = Color(0xFFF0ABFC);
  static const Color acDark = Color(0xFFD946EF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF0FF),
      appBar: AppBar(
        title: const Text(
          'Partidos',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
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
            return const Center(
              child: CircularProgressIndicator(color: acDark),
            );
          }

          if (!snap.hasData || snap.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    'No hay partidos creados',
                    style: TextStyle(
                        color: Colors.grey.shade500, fontSize: 15),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Crea el primero',
                    style: TextStyle(
                        color: Colors.grey.shade400, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(14, 16, 14, 100),
            itemCount: snap.data!.docs.length,
            itemBuilder: (_, i) {
              final doc = snap.data!.docs[i];
              final d = doc.data() as Map<String, dynamic>;
              final estado = d['estado'] ?? 'programado';

              String fecha = '';
              String hora = '';

              try {
                final dt = DateTime.parse(d['fecha']);
                fecha = '${dt.day}/${dt.month}/${dt.year}';
                hora =
                '${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}';
              } catch (_) {}

              return Container(
                margin: const EdgeInsets.only(bottom: 14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(18),
                  boxShadow: [
                    BoxShadow(
                      color: acDark.withOpacity(0.12),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [
                            acDark.withOpacity(0.12),
                            ac.withOpacity(0.08)
                          ],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                        borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(18)),
                      ),
                      child: Row(
                        children: [
                          _estadoBadge(estado),
                          const Spacer(),
                          Expanded(
                            flex: 5,
                            child: _NombresVs(
                              localId: d['equipoLocalId'],
                              visitanteId: d['equipoVisitanteId'],
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.fromLTRB(16, 10, 16, 4),
                      child: Row(
                        children: [
                          if (fecha.isNotEmpty) ...[
                            Text(
                              fecha,
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13),
                            ),
                            const SizedBox(width: 14),
                          ],
                          if (hora.isNotEmpty && hora != '00:00')
                            Text(
                              hora,
                              style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13),
                            ),
                          const Spacer(),
                          if (d['arbitroId'] != null)
                            _ArbitroChip(
                                arbitroId: d['arbitroId']),
                        ],
                      ),
                    ),
                    Padding(
                      padding:
                      const EdgeInsets.fromLTRB(12, 4, 12, 12),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          TextButton.icon(
                            onPressed: () =>
                                _editar(context, doc.id, d),
                            icon: const Icon(Icons.edit_note,
                                size: 16),
                            label: const Text('Editar'),
                            style: TextButton.styleFrom(
                                foregroundColor: acDark),
                          ),
                          const SizedBox(width: 4),
                          TextButton.icon(
                            onPressed: () =>
                                _eliminar(context, doc.id),
                            icon: const Icon(
                                Icons.delete_outline,
                                size: 16),
                            label: const Text('Eliminar'),
                            style: TextButton.styleFrom(
                                foregroundColor: Colors.red),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _crear(context),
        backgroundColor: acDark,
        icon: const Icon(Icons.add),
        label: const Text(
          'Nuevo Partido',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _estadoBadge(String estado) {
    Color c;

    switch (estado) {
      case 'finalizado':
        c = Colors.green;
        break;
      case 'en_curso':
        c = Colors.orange;
        break;
      case 'cancelado':
        c = Colors.red;
        break;
      default:
        c = Colors.blue;
        break;
    }

    return Container(
      padding:
      const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: c.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: c.withOpacity(0.3)),
      ),
      child: Text(
        estado.replaceAll('_', ' '),
        style: TextStyle(
          color: c,
          fontSize: 11,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  void _crear(BuildContext context) {}
  void _editar(BuildContext context, String id, Map<String, dynamic> data) {}
  void _eliminar(BuildContext context, String id) {}
}

class _NombresVs extends StatelessWidget {
  final String? localId, visitanteId;
  const _NombresVs({this.localId, this.visitanteId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<List<String>>(
      future: Future.wait(
          [_nombre(localId), _nombre(visitanteId)]),
      builder: (_, snap) {
        if (!snap.hasData) {
          return const Text(
            'Cargando...',
            style:
            TextStyle(fontSize: 13, color: Colors.grey),
          );
        }

        final local = snap.data![0];
        final visitante = snap.data![1];

        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Flexible(
              child: Text(
                local,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.right,
              ),
            ),
            Container(
              margin:
              const EdgeInsets.symmetric(horizontal: 8),
              padding: const EdgeInsets.symmetric(
                  horizontal: 8, vertical: 3),
              decoration: BoxDecoration(
                color: PartidosScreen.acDark
                    .withOpacity(0.15),
                borderRadius:
                BorderRadius.circular(8),
              ),
              child: const Text(
                'VS',
                style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontSize: 13,
                  color: PartidosScreen.acDark,
                  letterSpacing: 1,
                ),
              ),
            ),
            Flexible(
              child: Text(
                visitante,
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14),
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.left,
              ),
            ),
          ],
        );
      },
    );
  }

  Future<String> _nombre(String? id) async {
    if (id == null) return '?';
    try {
      final doc = await FirebaseFirestore.instance
          .collection('equipos')
          .doc(id)
          .get();
      return (doc.data()
      as Map<String, dynamic>?)?['nombre'] ??
          id;
    } catch (_) {
      return id;
    }
  }
}

class _ArbitroChip extends StatelessWidget {
  final String arbitroId;
  const _ArbitroChip({required this.arbitroId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('usuarios')
          .doc(arbitroId)
          .get(),
      builder: (_, snap) {
        final d =
        snap.data?.data() as Map<String, dynamic>?;
        final nombre = d?['nombre'] ?? 'Árbitro';

        return Container(
          padding: const EdgeInsets.symmetric(
              horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: Colors.grey.shade100,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
                color: Colors.grey.shade300),
          ),
          child: Text(
            nombre,
            style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700),
          ),
        );
      },
    );
  }
}