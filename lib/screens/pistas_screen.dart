import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'reservar_pista_screen.dart';

class PistasScreen extends StatefulWidget {
  final bool mostrarAppBar;
  final String? uid;
  final String? rol;

  const PistasScreen({
    super.key,
    this.mostrarAppBar = true,
    this.uid,
    this.rol,
  });

  @override
  State<PistasScreen> createState() => _PistasScreenState();
}

class _PistasScreenState extends State<PistasScreen> {
  static const Color ac     = Color(0xFFF0ABFC);
  static const Color acDark = Color(0xFFD946EF);
  static const Color fondo  = Color(0xFFFAF0FF);

  String _filtro = 'Todas';
  static const _deportes = ['Todas', 'Fútbol', 'Baloncesto', 'Pádel', 'Tenis'];

  Stream<QuerySnapshot> get _stream {
    final base = FirebaseFirestore.instance
        .collection('pistas').where('disponible', isEqualTo: true);
    if (_filtro == 'Todas') return base.snapshots();
    return base.where('tipo', isEqualTo: _filtro).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      appBar: widget.mostrarAppBar
          ? AppBar(
        title: const Text('Nuestras Pistas'),
        backgroundColor: acDark,
        foregroundColor: Colors.white,
      )
          : PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFD946EF), Color(0xFFF0ABFC)],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                const Text('Pistas Disponibles',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
        ),
      ),
      body: Column(children: [
        // Filtrar por deporte
        Container(
          color: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: _deportes.map((d) {
                final sel = _filtro == d;
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(d),
                    selected: sel,
                    selectedColor: acDark,
                    backgroundColor: Colors.grey.shade100,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: sel ? Colors.white : Colors.black87,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(color: sel ? acDark : Colors.grey.shade300),
                    onSelected: (_) => setState(() => _filtro = d),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
        // Lista de pistas
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: _stream,
            builder: (_, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: acDark));
              }
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Text('No hay pistas disponibles',
                        style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                    const SizedBox(height: 6),
                    Text('Vuelve a intentarlo más tarde',
                        style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                  ]),
                );
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
                    uid: widget.uid,
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
  final String? uid;

  const _PistaCard({
    required this.pistaId, required this.nombre,
    required this.tipo, required this.precio, this.uid,
  });

  static const Color acDark = Color(0xFFD946EF);
  static const Color ac     = Color(0xFFF0ABFC);

  IconData get _icono {
    switch (tipo) {
      case 'Tenis':      return Icons.sports_tennis;
      case 'Fútbol':     return Icons.sports_soccer;
      case 'Pádel':      return Icons.sports_tennis;
      case 'Baloncesto': return Icons.sports_basketball;
      default:           return Icons.sports_tennis;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white, borderRadius: BorderRadius.circular(20),
        boxShadow: [BoxShadow(color: acDark.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 6))],
      ),
      child: Column(children: [
        // Cabecera con gradiente
        Container(
          width: double.infinity, height: 120,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            gradient: LinearGradient(
              colors: [acDark.withOpacity(0.7), acDark],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
          child: Stack(children: [
            Center(child: Icon(_icono, size: 64, color: Colors.white.withOpacity(0.9))),
            Positioned(
              top: 12, right: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.25), borderRadius: BorderRadius.circular(12)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(Icons.check_circle, color: Colors.white, size: 14),
                  SizedBox(width: 4),
                  Text('Disponible',
                      style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
          ]),
        ),
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.sports_tennis, size: 14, color: acDark),
                  const SizedBox(width: 4),
                  Text(tipo, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(width: 12),
                  Icon(Icons.euro, size: 14, color: acDark),
                  Text('$precio / hora',
                      style: TextStyle(fontSize: 13, color: acDark, fontWeight: FontWeight.w600)),
                ]),
              ]),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => ReservarPistaScreen(
                    pistaId: pistaId, pistaNombre: nombre, tipo: tipo, precio: precio)),
              ),
              icon: const Icon(Icons.add_circle_outline, size: 16),
              label: const Text('Reservar', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: acDark, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              ),
            ),
          ]),
        ),
      ]),
    );
  }
}