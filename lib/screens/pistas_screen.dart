import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'reservar_pista_screen.dart';

class PistasScreen extends StatefulWidget {
  final bool mostrarAppBar;
  const PistasScreen({super.key, this.mostrarAppBar = true});

  @override
  State<PistasScreen> createState() => _PistasScreenState();
}

class _PistasScreenState extends State<PistasScreen> {
  static const Color morado = Color(0xFF6B4CE6);
  String _filtro = 'Todas';
  static const _deportes = ['Todas', 'Fútbol', 'Baloncesto', 'Pádel', 'Tenis'];

  Stream<QuerySnapshot> get _stream {
    final base = FirebaseFirestore.instance.collection('pistas').where('disponible', isEqualTo: true);
    if (_filtro == 'Todas') return base.snapshots();
    return base.where('tipo', isEqualTo: _filtro).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      appBar: widget.mostrarAppBar
          ? AppBar(title: const Text('Nuestras Pistas'),
          backgroundColor: morado, foregroundColor: Colors.white)
          : null,
      body: Column(children: [
        // Filtro por deporte
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 14),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _deportes.map((d) {
                final sel = _filtro == d;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(d), selected: sel, selectedColor: morado,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                        color: sel ? Colors.white : Colors.black87,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal),
                    onSelected: (_) => setState(() => _filtro = d),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Lista
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _stream,
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: morado));
              }
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return Center(child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Icon(Icons.sports, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('No hay pistas disponibles', style: TextStyle(color: Colors.grey.shade500)),
                ]));
              }
              return ListView.builder(
                padding: const EdgeInsets.all(14),
                itemCount: snap.data!.docs.length,
                itemBuilder: (_, i) {
                  final doc = snap.data!.docs[i];
                  final d = doc.data() as Map<String, dynamic>;
                  return _PistaCard(
                    pistaId: doc.id,
                    nombre: d['nombre'] ?? 'Pista',
                    tipo: d['tipo'] ?? '',
                    precio: d['precio']?.toString() ?? '0',
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

class _PistaCard extends StatelessWidget {
  final String pistaId, nombre, tipo, precio;
  const _PistaCard({required this.pistaId, required this.nombre, required this.tipo, required this.precio});

  Color get _color {
    switch (tipo) {
      case 'Tenis':      return const Color(0xFF6B4CE6);
      case 'Fútbol':     return const Color(0xFFE91E8C);
      case 'Pádel':      return const Color(0xFF8B5CF6);
      case 'Baloncesto': return const Color(0xFFF59E0B);
      default:           return const Color(0xFF6B4CE6);
    }
  }

  IconData get _icono {
    switch (tipo) {
      case 'Tenis':      return Icons.sports_tennis;
      case 'Fútbol':     return Icons.sports_soccer;
      case 'Pádel':      return Icons.sports;
      case 'Baloncesto': return Icons.sports_basketball;
      default:           return Icons.sports;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [BoxShadow(color: _color.withOpacity(0.12), blurRadius: 14, offset: const Offset(0, 5))],
      ),
      child: Column(children: [
        // Cabecera de color con icono
        Container(
          width: double.infinity, height: 110,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(18)),
            gradient: LinearGradient(
              colors: [_color.withOpacity(0.6), _color],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
          child: Center(child: Icon(_icono, size: 60, color: Colors.white)),
        ),
        // Info y botón reservar
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(nombre, style: const TextStyle(fontSize: 17, fontWeight: FontWeight.bold)),
              const SizedBox(height: 2),
              Text('€$precio / hora',
                  style: TextStyle(fontSize: 13, color: _color, fontWeight: FontWeight.w600)),
            ])),
            ElevatedButton(
              onPressed: () => Navigator.push(context, MaterialPageRoute(
                builder: (_) => ReservarPistaScreen(
                    pistaId: pistaId, pistaNombre: nombre, tipo: tipo, precio: precio),
              )),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF6B4CE6), foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
              ),
              child: const Text('Reservar', style: TextStyle(fontWeight: FontWeight.bold)),
            ),
          ]),
        ),
      ]),
    );
  }
}