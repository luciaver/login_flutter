import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home/HomeScreen.dart';
import 'login_screen.dart';
import 'admin/admin_screen.dart';


class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});
  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nombreCtrl   = TextEditingController();
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl  = TextEditingController();
  final _telCtrl      = TextEditingController();
  bool  _obscure = true, _obscureC = true, _loading = false;
  String _rol = 'jugador', _posicion = 'Portero';

  @override
  void dispose() {
    _nombreCtrl.dispose(); _emailCtrl.dispose(); _passwordCtrl.dispose();
    _confirmCtrl.dispose(); _telCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    final nombre = _nombreCtrl.text.trim();
    final email  = _emailCtrl.text.trim();
    final pass   = _passwordCtrl.text;
    final tel    = _telCtrl.text.trim();
    if (nombre.isEmpty || email.isEmpty || pass.isEmpty || tel.isEmpty) {
      _msg('Completa todos los campos', Colors.orange); return;
    }
    if (pass.length < 6) { _msg('La contraseña debe tener al menos 6 caracteres', Colors.orange); return; }
    if (pass != _confirmCtrl.text) { _msg('Las contraseñas no coinciden', Colors.orange); return; }
    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: pass);
      final data = <String, dynamic>{
        'nombre': nombre, 'email': email, 'rol': _rol, 'telefono': tel,
      };
      if (_rol == 'jugador') data['posicion'] = _posicion;
      await FirebaseFirestore.instance.collection('usuarios').doc(cred.user!.uid).set(data);
      if (!mounted) return;
      if (_rol == 'admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (_) => HomeScreen(rol: _rol, nombre: nombre, uid: cred.user!.uid)));
      }
    } on FirebaseAuthException catch (e) {
      final msgs = {
        'email-already-in-use': 'Este correo ya está registrado',
        'weak-password': 'Contraseña muy débil', 'invalid-email': 'Correo no válido',
      };
      _msg(msgs[e.code] ?? 'Error al registrar', Colors.red);
    } finally { if (mounted) setState(() => _loading = false); }
  }

  void _msg(String m, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m), backgroundColor: c,
        behavior: SnackBarBehavior.floating));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (_) => const LoginScreen()))),
        title: const Text('Registro'), backgroundColor: const Color(0xFFD946EF), foregroundColor: Colors.white,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter,
              colors: [Color(0xFFD946EF), Color(0xFFF0ABFC)]),
        ),
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Card(
              elevation: 8,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  const Icon(Icons.sports_basketball, size: 64, color: Color(0xFFD946EF)),
                  const SizedBox(height: 10),
                  const Text('Crear Cuenta', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold,
                      color: Color(0xFFD946EF))),
                  const SizedBox(height: 20),
                  _campo(_nombreCtrl, 'Nombre completo', Icons.person),
                  const SizedBox(height: 10),
                  _campo(_emailCtrl, 'Correo electrónico', Icons.email, type: TextInputType.emailAddress),
                  const SizedBox(height: 10),
                  _campo(_telCtrl, 'Teléfono', Icons.phone, type: TextInputType.phone),
                  const SizedBox(height: 10),
                  _campoPass(_passwordCtrl, 'Contraseña', _obscure, () => setState(() => _obscure = !_obscure)),
                  const SizedBox(height: 10),
                  _campoPass(_confirmCtrl, 'Confirmar contraseña', _obscureC, () => setState(() => _obscureC = !_obscureC)),
                  const SizedBox(height: 10),
                  _dropBox<String>(
                    value: _rol,
                    items: const [
                      DropdownMenuItem(value: 'jugador', child: Text('Jugador')),
                      DropdownMenuItem(value: 'entrenador', child: Text('Entrenador')),
                      DropdownMenuItem(value: 'arbitro', child: Text('Árbitro')),
                      DropdownMenuItem(value: 'admin', child: Text('Administrador')),
                    ],
                    onChanged: (v) => setState(() => _rol = v!),
                  ),
                  if (_rol == 'jugador') ...[
                    const SizedBox(height: 10),
                    _dropBox<String>(
                      value: _posicion,
                      items: const [
                        DropdownMenuItem(value: 'Portero', child: Text('Portero')),
                        DropdownMenuItem(value: 'Defensa', child: Text('Defensa')),
                        DropdownMenuItem(value: 'Centrocampista', child: Text('Centrocampista')),
                        DropdownMenuItem(value: 'Delantero', child: Text('Delantero')),
                      ],
                      onChanged: (v) => setState(() => _posicion = v!),
                    ),
                  ],
                  const SizedBox(height: 20),
                  SizedBox(
                    width: double.infinity, height: 48,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _register,
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD946EF),
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
                      child: _loading
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Registrarse', style: TextStyle(fontSize: 16)),
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                    const Text('¿Ya tienes cuenta? '),
                    TextButton(
                      onPressed: () => Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const LoginScreen())),
                      child: const Text('Inicia Sesión',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD946EF))),
                    ),
                  ]),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _campo(TextEditingController ctrl, String label, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return TextField(controller: ctrl, keyboardType: type,
        decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))));
  }

  Widget _campoPass(TextEditingController ctrl, String label, bool obscure, VoidCallback toggle) {
    return TextField(controller: ctrl, obscureText: obscure,
        decoration: InputDecoration(labelText: label, prefixIcon: const Icon(Icons.lock),
            suffixIcon: IconButton(icon: Icon(obscure ? Icons.visibility : Icons.visibility_off), onPressed: toggle),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12))));
  }

  Widget _dropBox<T>({required T value, required List<DropdownMenuItem<T>> items, required ValueChanged<T?> onChanged}) {
    return Container(
      decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400),
          borderRadius: BorderRadius.circular(12)),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(value: value, isExpanded: true,
            icon: const Icon(Icons.arrow_drop_down, color: Color(0xFFD946EF)),
            items: items, onChanged: onChanged),
      ),
    );
  }
}