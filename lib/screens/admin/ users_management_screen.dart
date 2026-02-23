import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../provider/user_provider.dart';

class UsersManagementScreen extends StatelessWidget {
  const UsersManagementScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(create: (_) => UserProvider(), child: const _Body());
  }
}

class _Body extends StatelessWidget {
  const _Body();
  static const Color ac = Color(0xFFD946EF);

  @override
  Widget build(BuildContext context) {
    final prov = Provider.of<UserProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text('Gestión de Usuarios'),
          backgroundColor: ac, foregroundColor: Colors.white),
      body: Column(children: [
        // Filtro
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          color: ac.withOpacity(0.07),
          child: Row(children: [
            const Text('Filtrar: ', style: TextStyle(fontWeight: FontWeight.bold, color: ac)),
            const SizedBox(width: 10),
            Expanded(
              child: Container(
                decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: ac)),
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: prov.filtroRol, isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down, color: ac),
                    items: const [
                      DropdownMenuItem(value: 'todos',      child: Text('Todos')),
                      DropdownMenuItem(value: 'jugador',    child: Text('Jugadores')),
                      DropdownMenuItem(value: 'entrenador', child: Text('Entrenadores')),
                      DropdownMenuItem(value: 'arbitro',    child: Text('Árbitros')),
                      DropdownMenuItem(value: 'admin',      child: Text('Admins')),
                    ],
                    onChanged: (v) { if (v != null) prov.cambiarFiltroRol(v); },
                  ),
                ),
              ),
            ),
          ]),
        ),
        // Lista
        Expanded(
          child: StreamBuilder<QuerySnapshot>(
            stream: prov.obtenerUsuarios(),
            builder: (context, snap) {
              if (snap.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator(color: ac));
              }
              if (!snap.hasData || snap.data!.docs.isEmpty) {
                return const Center(child: Text('No hay usuarios'));
              }
              return ListView.builder(
                itemCount: snap.data!.docs.length,
                itemBuilder: (context, i) {
                  final doc = snap.data!.docs[i];
                  final d = doc.data() as Map<String, dynamic>;
                  final nombre   = d['nombre'] ?? '';
                  final email    = d['email'] ?? '';
                  final rol      = d['rol'] ?? '';
                  final fecha    = d['fechaNacimiento'] ?? d['edad']?.toString() ?? '';
                  final telefono = d['telefono'] ?? '';
                  final posicion = d['posicion'] as String?;
                  final equipo   = d['equipo'] as String?;

                  return Card(
                    margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    elevation: 2,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12),
                        side: BorderSide(color: _color(rol).withOpacity(0.3))),
                    child: ExpansionTile(
                      leading: CircleAvatar(backgroundColor: _color(rol),
                          child: Icon(_icon(rol), color: Colors.white)),
                      title: Text(nombre, style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Text('$email\n${rol.toUpperCase()}',
                          style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                      trailing: Row(mainAxisSize: MainAxisSize.min, children: [
                        _iconBtn(Icons.edit, ac,
                                () => _editar(context, doc.id, nombre, email, rol, fecha, telefono, posicion, equipo)),
                        _iconBtn(Icons.delete, Colors.red,
                                () => _eliminar(context, doc.id, nombre)),
                      ]),
                      children: [
                        Container(
                          color: _color(rol).withOpacity(0.04),
                          padding: const EdgeInsets.fromLTRB(16, 4, 16, 14),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            _fila(Icons.cake, 'F. Nacimiento', _fmt(fecha), _color(rol)),
                            _fila(Icons.phone, 'Teléfono', telefono.isNotEmpty ? telefono : '-', _color(rol)),
                            if (posicion != null) _fila(Icons.sports_soccer, 'Posición', posicion, _color(rol)),
                            if (rol != 'jugador' && equipo != null)
                              _fila(Icons.groups, 'Equipo', equipo, _color(rol)),
                          ]),
                        ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _agregar(context), backgroundColor: ac,
        icon: const Icon(Icons.add), label: const Text('Nuevo'),
      ),
    );
  }

  // ── helpers ────────────────────────────────────────────────

  String _fmt(String v) {
    if (v.isEmpty) return '-';
    try {
      final d = DateTime.parse(v);
      return '${d.day.toString().padLeft(2,'0')}/${d.month.toString().padLeft(2,'0')}/${d.year}';
    } catch (_) { return v; }
  }

  Color _color(String rol) {
    switch (rol) {
      case 'jugador':    return const Color(0xFFD946EF);
      case 'entrenador': return const Color(0xFFF0ABFC);
      case 'arbitro':    return const Color(0xFFA855F7);
      case 'admin':      return const Color(0xFF7C3AED);
      default:           return Colors.grey;
    }
  }

  IconData _icon(String rol) {
    switch (rol) {
      case 'jugador':    return Icons.sports_soccer;
      case 'entrenador': return Icons.sports;
      case 'arbitro':    return Icons.sports_score;
      case 'admin':      return Icons.admin_panel_settings;
      default:           return Icons.person;
    }
  }

  Widget _iconBtn(IconData icon, Color c, VoidCallback tap) => Container(
    decoration: BoxDecoration(color: c.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
    child: IconButton(icon: Icon(icon, color: c, size: 20), onPressed: tap),
  );

  Widget _fila(IconData icon, String label, String val, Color c) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Row(children: [
      Icon(icon, size: 16, color: c),
      const SizedBox(width: 8),
      Text('$label: ', style: TextStyle(fontWeight: FontWeight.bold, color: c, fontSize: 12)),
      Expanded(child: Text(val, style: const TextStyle(fontSize: 12))),
    ]),
  );

  // ── DatePicker sin locale ──────────────────────────────────

  Future<String?> _pickDate(BuildContext context, String? actual) async {
    DateTime init = DateTime(2000);
    if (actual != null && actual.isNotEmpty) {
      try { init = DateTime.parse(actual); } catch (_) {}
    }
    final picked = await showDatePicker(
      context: context, initialDate: init,
      firstDate: DateTime(1920), lastDate: DateTime.now(),
      builder: (ctx, child) => Theme(
        data: Theme.of(ctx).copyWith(
          colorScheme: const ColorScheme.light(
              primary: Color(0xFFD946EF), onPrimary: Colors.white, onSurface: Colors.black87),
        ),
        child: child!,
      ),
    );
    return picked?.toIso8601String().substring(0, 10);
  }

  Widget _fechaBtn(String display, bool seleccionado, Color ac) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
    decoration: BoxDecoration(
        border: Border.all(color: seleccionado ? ac : Colors.grey.shade400),
        borderRadius: BorderRadius.circular(12)),
    child: Row(children: [
      Icon(Icons.cake, color: ac),
      const SizedBox(width: 10),
      Expanded(child: Text(display,
          style: TextStyle(color: seleccionado ? Colors.black87 : Colors.grey.shade500))),
      Icon(Icons.calendar_today, size: 16, color: ac),
    ]),
  );

  Widget _campo(TextEditingController ctrl, String label, IconData icon,
      {TextInputType type = TextInputType.text, bool obscure = false, Color ac = const Color(0xFFD946EF)}) {
    return TextField(
      controller: ctrl, keyboardType: type, obscureText: obscure,
      decoration: InputDecoration(
        labelText: label, prefixIcon: Icon(icon, color: ac),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: ac, width: 2)),
      ),
    );
  }

  Widget _drop<T>({required T? value, required List<DropdownMenuItem<T>> items,
    required ValueChanged<T?> onChanged, Color ac = const Color(0xFFD946EF)}) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: ac), borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(value: value, isExpanded: true,
            icon: Icon(Icons.arrow_drop_down, color: ac), items: items, onChanged: onChanged),
      ),
    );
  }

  void _snack(BuildContext ctx, String m, Color c) {
    ScaffoldMessenger.of(ctx).showSnackBar(SnackBar(content: Text(m), backgroundColor: c,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))));
  }

  // ── AGREGAR ───────────────────────────────────────────────

  void _agregar(BuildContext context) {
    final nc = TextEditingController(), ec = TextEditingController(),
        pc = TextEditingController(), tc = TextEditingController(), eqc = TextEditingController();
    String rol = 'jugador', pos = 'Portero';
    String? fecha; String fechaDisp = 'Seleccionar fecha';

    showDialog(context: context, builder: (dCtx) => StatefulBuilder(
      builder: (ctx, ss) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Agregar Usuario'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          _campo(nc, 'Nombre', Icons.person),                     const SizedBox(height: 10),
          _campo(ec, 'Email', Icons.email, type: TextInputType.emailAddress), const SizedBox(height: 10),
          _campo(tc, 'Teléfono', Icons.phone, type: TextInputType.phone),     const SizedBox(height: 10),
          _campo(pc, 'Contraseña', Icons.lock, obscure: true),    const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final f = await _pickDate(ctx, fecha);
              if (f != null) ss(() { fecha = f; fechaDisp = _fmt(f); });
            },
            child: _fechaBtn(fechaDisp, fecha != null, const Color(0xFFD946EF)),
          ),
          const SizedBox(height: 10),
          _drop<String>(
            value: rol,
            items: const [
              DropdownMenuItem(value: 'jugador',    child: Text('Jugador')),
              DropdownMenuItem(value: 'entrenador', child: Text('Entrenador')),
              DropdownMenuItem(value: 'arbitro',    child: Text('Árbitro')),
              DropdownMenuItem(value: 'admin',      child: Text('Admin')),
            ],
            onChanged: (v) => ss(() => rol = v!),
          ),
          if (rol == 'jugador') ...[
            const SizedBox(height: 10),
            _drop<String>(
              value: pos,
              items: const [
                DropdownMenuItem(value: 'Portero',        child: Text('Portero')),
                DropdownMenuItem(value: 'Defensa',        child: Text('Defensa')),
                DropdownMenuItem(value: 'Centrocampista', child: Text('Centrocampista')),
                DropdownMenuItem(value: 'Delantero',      child: Text('Delantero')),
              ],
              onChanged: (v) => ss(() => pos = v!),
            ),
          ],
          if (rol != 'jugador') ...[
            const SizedBox(height: 10),
            _campo(eqc, 'Equipo (opcional)', Icons.groups),
          ],
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dCtx),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD946EF),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              if (fecha == null) { _snack(ctx, 'Selecciona fecha de nacimiento', Colors.orange); return; }
              final prov = Provider.of<UserProvider>(ctx, listen: false);
              final ok = await prov.agregarUsuario(
                nombre: nc.text.trim(), email: ec.text.trim(), password: pc.text, rol: rol,
                fechaNacimiento: fecha!, telefono: tc.text.trim(),
                posicion: rol == 'jugador' ? pos : null,
                equipo: rol != 'jugador' && eqc.text.trim().isNotEmpty ? eqc.text.trim() : null,
              );
              Navigator.pop(dCtx);
              _snack(context, ok ? 'Usuario agregado' : 'Error al agregar',
                  ok ? const Color(0xFFD946EF) : Colors.red);
            },
            child: const Text('Agregar'),
          ),
        ],
      ),
    ));
  }

  // ── EDITAR ────────────────────────────────────────────────

  void _editar(BuildContext context, String uid, String nombre, String email,
      String rol, String fecha, String telefono, String? posicion, String? equipo) {
    final nc = TextEditingController(text: nombre);
    final tc = TextEditingController(text: telefono);
    final eqc = TextEditingController(text: equipo ?? '');
    String sRol = rol, sPos = posicion ?? 'Portero';
    String? sFecha = fecha.isNotEmpty ? fecha : null;
    String fechaDisp = sFecha != null ? _fmt(sFecha) : 'Seleccionar fecha';
    const ac2 = Color(0xFFA855F7);

    showDialog(context: context, builder: (dCtx) => StatefulBuilder(
      builder: (ctx, ss) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Editar Usuario'),
        content: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
          _campo(nc, 'Nombre', Icons.person, ac: ac2),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(12)),
            child: Row(children: [
              const Icon(Icons.email, color: ac2),
              const SizedBox(width: 10),
              Text(email, style: const TextStyle(fontWeight: FontWeight.w500)),
            ]),
          ),
          const SizedBox(height: 10),
          _campo(tc, 'Teléfono', Icons.phone, type: TextInputType.phone, ac: ac2),
          const SizedBox(height: 10),
          GestureDetector(
            onTap: () async {
              final f = await _pickDate(ctx, sFecha);
              if (f != null) ss(() { sFecha = f; fechaDisp = _fmt(f); });
            },
            child: _fechaBtn(fechaDisp, sFecha != null, ac2),
          ),
          const SizedBox(height: 10),
          _drop<String>(
            value: sRol, ac: ac2,
            items: const [
              DropdownMenuItem(value: 'jugador',    child: Text('Jugador')),
              DropdownMenuItem(value: 'entrenador', child: Text('Entrenador')),
              DropdownMenuItem(value: 'arbitro',    child: Text('Árbitro')),
              DropdownMenuItem(value: 'admin',      child: Text('Admin')),
            ],
            onChanged: (v) => ss(() => sRol = v!),
          ),
          if (sRol == 'jugador') ...[
            const SizedBox(height: 10),
            _drop<String>(
              value: sPos, ac: ac2,
              items: const [
                DropdownMenuItem(value: 'Portero',        child: Text('Portero')),
                DropdownMenuItem(value: 'Defensa',        child: Text('Defensa')),
                DropdownMenuItem(value: 'Centrocampista', child: Text('Centrocampista')),
                DropdownMenuItem(value: 'Delantero',      child: Text('Delantero')),
              ],
              onChanged: (v) => ss(() => sPos = v!),
            ),
          ],
          if (sRol != 'jugador') ...[
            const SizedBox(height: 10),
            _campo(eqc, 'Equipo (opcional)', Icons.groups, ac: ac2),
          ],
        ])),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dCtx),
              child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: ac2, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              if (sFecha == null) { _snack(ctx, 'Selecciona fecha de nacimiento', Colors.orange); return; }
              final prov = Provider.of<UserProvider>(ctx, listen: false);
              final ok = await prov.editarUsuario(
                userId: uid, nombre: nc.text.trim(), rol: sRol,
                fechaNacimiento: sFecha!, telefono: tc.text.trim(),
                posicion: sRol == 'jugador' ? sPos : null,
                equipo: sRol != 'jugador' && eqc.text.trim().isNotEmpty ? eqc.text.trim() : null,
              );
              Navigator.pop(dCtx);
              _snack(context, ok ? 'Actualizado correctamente' : 'Error al actualizar',
                  ok ? ac2 : Colors.red);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    ));
  }

  // ── ELIMINAR ─────────────────────────────────────────────

  void _eliminar(BuildContext context, String uid, String nombre) {
    showDialog(context: context, builder: (dCtx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Eliminar Usuario'),
      content: Text('¿Eliminar a "$nombre"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(dCtx),
            child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
          onPressed: () async {
            final prov = Provider.of<UserProvider>(context, listen: false);
            final ok = await prov.eliminarUsuario(uid);
            Navigator.pop(dCtx);
            _snack(context, ok ? 'Usuario eliminado' : 'Error', ok ? const Color(0xFFD946EF) : Colors.red);
          },
          child: const Text('Eliminar'),
        ),
      ],
    ));
  }
}