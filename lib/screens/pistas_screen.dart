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
  static const Color rosa   = Color(0xFFEC4899);
  static const Color rosaDark = Color(0xFFDB2777);

  String _filtro = 'Todas';
  static const _deportes = ['Todas', 'Fútbol', 'Baloncesto', 'Pádel', 'Tenis'];

  Stream<QuerySnapshot> get _stream {
    final base = FirebaseFirestore.instance
        .collection('pistas')
        .where('disponible', isEqualTo: true);
    if (_filtro == 'Todas') return base.snapshots();
    return base.where('tipo', isEqualTo: _filtro).snapshots();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF0F6),
      appBar: widget.mostrarAppBar
          ? AppBar(
        title: const Text('Nuestras Pistas'),
        backgroundColor: rosaDark,
        foregroundColor: Colors.white,
      )
          : PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [rosaDark, rosa],
              begin: Alignment.topLeft, end: Alignment.bottomRight,
            ),
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(children: [
                const Icon(Icons.sports, color: Colors.white, size: 22),
                const SizedBox(width: 10),
                const Text('Pistas Disponibles',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
              ]),
            ),
          ),
        ),
      ),
      body: Column(children: [
        // Filtro por deporte
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
                    selectedColor: rosa,
                    backgroundColor: Colors.grey.shade100,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: sel ? Colors.white : Colors.black87,
                      fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                    ),
                    side: BorderSide(color: sel ? rosa : Colors.grey.shade300),
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
                return const Center(child: CircularProgressIndicator(color: rosa));
              }
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return Center(
                  child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                    Icon(Icons.sports, size: 64, color: Colors.grey.shade300),
                    const SizedBox(height: 12),
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
    required this.pistaId,
    required this.nombre,
    required this.tipo,
    required this.precio,
    this.uid,
  });

  Color get _colorTipo {
    switch (tipo) {
      case 'Tenis':      return const Color(0xFFEC4899);
      case 'Fútbol':     return const Color(0xFFDB2777);
      case 'Pádel':      return const Color(0xFFF472B6);
      case 'Baloncesto': return const Color(0xFFBE185D);
      default:           return const Color(0xFFEC4899);
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
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(color: _colorTipo.withOpacity(0.15), blurRadius: 16, offset: const Offset(0, 6)),
        ],
      ),
      child: Column(children: [
        // Cabecera con gradiente rosa
        Container(
          width: double.infinity,
          height: 120,
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            gradient: LinearGradient(
              colors: [_colorTipo.withOpacity(0.7), _colorTipo],
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
                  color: Colors.white.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.check_circle, color: Colors.white, size: 14),
                  const SizedBox(width: 4),
                  const Text('Disponible', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold)),
                ]),
              ),
            ),
          ]),
        ),
        // Info y botón
        Padding(
          padding: const EdgeInsets.all(14),
          child: Row(children: [
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Row(children: [
                  Icon(Icons.sports, size: 14, color: _colorTipo),
                  const SizedBox(width: 4),
                  Text(tipo, style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                  const SizedBox(width: 12),
                  Icon(Icons.euro, size: 14, color: _colorTipo),
                  Text('$precio / hora',
                      style: TextStyle(fontSize: 13, color: _colorTipo, fontWeight: FontWeight.w600)),
                ]),
              ]),
            ),
            ElevatedButton.icon(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => ReservarPistaScreen(
                    pistaId: pistaId,
                    pistaNombre: nombre,
                    tipo: tipo,
                    precio: precio,
                  ),
                ),
              ),
              icon: const Icon(Icons.add_circle_outline, size: 16),
              label: const Text('Reservar', style: TextStyle(fontWeight: FontWeight.bold)),
              style: ElevatedButton.styleFrom(
                backgroundColor: _colorTipo,
                foregroundColor: Colors.white,
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