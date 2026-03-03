import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ReservarPistaScreen extends StatefulWidget {
  final String pistaId, pistaNombre, tipo, precio;

  const ReservarPistaScreen({
    super.key,
    required this.pistaId,
    required this.pistaNombre,
    required this.tipo,
    required this.precio,
  });

  @override
  State<ReservarPistaScreen> createState() => _ReservarPistaScreenState();
}

class _ReservarPistaScreenState extends State<ReservarPistaScreen> {
  static const Color morado = Color(0xFF8B5CF6);

  DateTime? _fecha;
  String? _horaInicio, _horaFin;
  bool _loading = false;

  static const _horas = [
    '08:00','09:00','10:00','11:00','12:00','13:00',
    '14:00','15:00','16:00','17:00','18:00','19:00',
    '20:00','21:00'
  ];

  int _horaToMin(String hora) {
    final parts = hora.split(':');
    return int.parse(parts[0]) * 60 + int.parse(parts[1]);
  }

  Future<void> _reservar() async {
    if (_fecha == null || _horaInicio == null || _horaFin == null) {
      _msg('Selecciona fecha y horario', Colors.orange);
      return;
    }

    if (_horaToMin(_horaInicio!) >= _horaToMin(_horaFin!)) {
      _msg('La hora de fin debe ser posterior al inicio', Colors.orange);
      return;
    }

    setState(() => _loading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        _msg('Usuario no autenticado', Colors.red);
        setState(() => _loading = false);
        return;
      }

      final fechaStr = _fecha!.toIso8601String().substring(0, 10);

      final snapshot = await FirebaseFirestore.instance
          .collection('reservas')
          .where('pistaId', isEqualTo: widget.pistaId)
          .where('fecha', isEqualTo: fechaStr)
          .get();

      final ocupadas = snapshot.docs.where((doc) {
        final d = doc.data();
        return (d['estado'] ?? '') != 'cancelada';
      }).toList();

      final conflicto = ocupadas.any((doc) {
        final d = doc.data();
        final ini = d['horaInicio'] as String? ?? '';
        final fin = d['horaFin'] as String? ?? '';
        if (ini.isEmpty || fin.isEmpty) return false;
        return _horaToMin(_horaInicio!) < _horaToMin(fin) &&
            _horaToMin(_horaFin!) > _horaToMin(ini);
      });

      if (conflicto) {
        _msg('Ese horario ya está ocupado', Colors.red);
        setState(() => _loading = false);
        return;
      }

      await FirebaseFirestore.instance.collection('reservas').add({
        'pistaId': widget.pistaId,
        'pistaNombre': widget.pistaNombre,
        'usuarioId': user.uid,
        'fecha': fechaStr,
        'horaInicio': _horaInicio,
        'horaFin': _horaFin,
        'estado': 'confirmada',
        'createdAt': FieldValue.serverTimestamp(),
      });

      _msg('¡Reserva realizada!', Colors.green);
      await Future.delayed(const Duration(milliseconds: 800));
      if (mounted) Navigator.pop(context);

    } catch (e) {
      _msg('Error al reservar: $e', Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _msg(String m, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(m), backgroundColor: c, behavior: SnackBarBehavior.floating),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3EEFF),
      appBar: AppBar(
        title: Text('Reservar ${widget.pistaNombre}'),
        backgroundColor: morado,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Info pista
            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              elevation: 3,
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: morado.withOpacity(0.15),
                  child: const Icon(Icons.sports, color: morado),
                ),
                title: Text(widget.pistaNombre,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text('${widget.tipo} · €${widget.precio}/h'),
              ),
            ),

            const SizedBox(height: 20),

            // Fecha
            const Text('Fecha',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: morado)),
            const SizedBox(height: 8),

            GestureDetector(
              onTap: () async {
                final p = await showDatePicker(
                  context: context,
                  initialDate: DateTime.now(),
                  firstDate: DateTime.now(),
                  lastDate: DateTime.now().add(const Duration(days: 60)),
                  builder: (ctx, child) => Theme(
                    data: Theme.of(ctx).copyWith(
                      colorScheme: const ColorScheme.light(
                          primary: morado, onPrimary: Colors.white),
                    ),
                    child: child!,
                  ),
                );
                if (p != null) setState(() => _fecha = p);
              },
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: Colors.white,
                  border: Border.all(color: _fecha != null ? morado : Colors.grey.shade300),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.calendar_today, color: morado),
                    const SizedBox(width: 12),
                    Text(
                      _fecha != null
                          ? '${_fecha!.day.toString().padLeft(2, '0')}/${_fecha!.month.toString().padLeft(2, '0')}/${_fecha!.year}'
                          : 'Seleccionar fecha',
                      style: TextStyle(
                        color: _fecha != null ? Colors.black87 : Colors.grey.shade500,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 20),

            // Hora inicio
            const Text('Hora inicio',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: morado)),
            const SizedBox(height: 8),
            _dropHora(_horaInicio, 'Seleccionar hora de inicio',
                    (v) => setState(() => _horaInicio = v)),

            const SizedBox(height: 14),

            // Hora fin
            const Text('Hora fin',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: morado)),
            const SizedBox(height: 8),
            _dropHora(_horaFin, 'Seleccionar hora de fin',
                    (v) => setState(() => _horaFin = v)),

            const SizedBox(height: 30),

            // Botón reservar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _loading ? null : _reservar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: morado,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                child: _loading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Confirmar Reserva',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _dropHora(String? value, String hint, ValueChanged<String?> onChanged) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: value != null ? morado : Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: value,
          hint: Text(hint),
          isExpanded: true,
          icon: const Icon(Icons.access_time, color: morado),
          items: _horas.map((h) => DropdownMenuItem(value: h, child: Text(h))).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}