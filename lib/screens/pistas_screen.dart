import 'package:flutter/material.dart';
import 'reservas_screen.dart';

// Pantalla de pistas para usuarios
// Muestra las 4 pistas con foto, título y botón de reservar

class PistasScreen extends StatelessWidget {
  const PistasScreen({super.key});

  // Colores de la app
  static const Color morado = Color(0xFF6B4CE6);
  static const Color rosa = Color(0xFFE91E8C);
  static const Color fondo = Color(0xFFF5F0FF);

  // Las 4 pistas fijas con su foto local
  static const List<Map<String, String>> pistas = [
    {
      'nombre': 'Pista de Tenis',
      'tipo': 'Tenis',
      'imagen': 'assets/tenis.jpg',
      'precio': '15',
    },
    {
      'nombre': 'Campo de Fútbol',
      'tipo': 'Fútbol',
      'imagen': 'assets/futbol.jpg',
      'precio': '40',
    },
    {
      'nombre': 'Pista de Pádel',
      'tipo': 'Pádel',
      'imagen': 'assets/padel.png',
      'precio': '20',
    },
    {
      'nombre': 'Cancha de Baloncesto',
      'tipo': 'Baloncesto',
      'imagen': 'assets/baloncesto.png',
      'precio': '25',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text('Nuestras Pistas'),
        backgroundColor: morado,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: pistas.length,
        itemBuilder: (context, i) {
          final pista = pistas[i];
          return _PistaCard(pista: pista);
        },
      ),
    );
  }
}

// Tarjeta individual de pista
class _PistaCard extends StatelessWidget {
  final Map<String, String> pista;

  const _PistaCard({required this.pista});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4CE6).withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Foto de la pista
          ClipRRect(
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            child: Image.asset(
              pista['imagen']!,
              height: 180,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                height: 180,
                color: Colors.grey.shade200,
                child: const Icon(Icons.sports, size: 60, color: Colors.grey),
              ),
            ),
          ),

          // Info y botón
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Texto
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        pista['nombre']!,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF2D2D2D),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '€ ${pista['precio']}€/hora',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Color(0xFF6B4CE6),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

                // Botón reservar
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ReservarPistaScreen(pista: pista),
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF6B4CE6),
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Reservar',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}