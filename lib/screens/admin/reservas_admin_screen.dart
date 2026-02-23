import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservasAdminScreen extends StatefulWidget {
  const ReservasAdminScreen({super.key});
  @override
  State<ReservasAdminScreen> createState() => _ReservasAdminScreenState();
}

class _ReservasAdminScreenState extends State<ReservasAdminScreen> {
  static const Color ac = Color(0xFFA855F7);
  String _filtro = 'todas';

  Color _estadoColor(String e) {
    switch (e) {
      case 'confirmada': return Colors.green;
      case 'cancelada':  return Colors.red;
      default:           return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final stream = _filtro == 'todas'
        ? FirebaseFirestore.instance.collection('reservas').orderBy('fecha', descending: true).snapshots()
        : FirebaseFirestore.instance.collection('reservas')
        .where('estado', isEqualTo: _filtro).orderBy('fecha', descending: true).snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Reservas'), backgroundColor: ac, foregroundColor: Colors.white),
      body: Column(children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          color: ac.withOpacity(0.07),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['todas', 'confirmada', 'pendiente', 'cancelada'].map((e) => Padding(
                padding: const EdgeInsets.only(right: 8),
                child: ChoiceChip(
                  label: Text(e[0].toUpperCase() + e.substring(1)),
                  selected: _filtro == e,
                  selectedColor: ac,
                  labelStyle: TextStyle(color: _filtro == e ? Colors.white : Colors.black87),
                  onSelected: (_) => setState(() => _filtro = e),
                ),
              )).toList(),
            ),
          ),
        ),
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: stream,
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: ac));
              }
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return const Center(child: Text('No hay reservas'));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: snap.data!.docs.length,
                itemBuilder: (_, i) {
                  final doc = snap.data!.docs[i];
                  final d = doc.data() as Map<String, dynamic>;
                  final estado = d['estado'] ?? 'pendiente';
                  final pista  = d['pistaNombre'] ?? 'Pista';
                  final hora   = '${d['horaInicio'] ?? ''} - ${d['horaFin'] ?? ''}';
                  String fecha = '';
                  try {
                    final dt = DateTime.parse(d['fecha']);
                    fecha = '${dt.day}/${dt.month}/${dt.year}';
                  } catch (_) {}
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 2, margin: const EdgeInsets.only(bottom: 10),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: _estadoColor(estado).withOpacity(0.15),
                        child: Icon(Icons.calendar_today, color: _estadoColor(estado), size: 20),
                      ),
                      title: Text(pista, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('$fecha  $hora\n${d['usuarioId'] ?? ''}',
                          style: const TextStyle(fontSize: 12)),
                      isThreeLine: true,
                      trailing: PopupMenuButton<String>(
                        onSelected: (val) async {
                          await FirebaseFirestore.instance.collection('reservas')
                              .doc(doc.id).update({'estado': val});
                        },
                        itemBuilder: (_) => const [
                          PopupMenuItem(value: 'confirmada', child: Text('✅ Confirmar')),
                          PopupMenuItem(value: 'pendiente',  child: Text('⏳ Pendiente')),
                          PopupMenuItem(value: 'cancelada',  child: Text('❌ Cancelar')),
                        ],
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                              color: _estadoColor(estado).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8)),
                          child: Text(estado,
                              style: TextStyle(color: _estadoColor(estado),
                                  fontWeight: FontWeight.bold, fontSize: 12)),
                        ),
                      ),
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