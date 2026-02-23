import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'home/HomeScreen.dart';
import 'register_screen.dart';
import 'admin/admin_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  final _emailCtrl    = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscure = true, _remember = false, _loading = false;
  late AnimationController _animCtrl;
  late Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _loadCredentials();
    _animCtrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 1200));
    _fade = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _animCtrl, curve: Curves.easeIn));
    _animCtrl.forward();
  }

  @override
  void dispose() {
    _emailCtrl.dispose(); _passwordCtrl.dispose(); _animCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getBool('remember') ?? false) {
      setState(() { _emailCtrl.text = prefs.getString('saved_email') ?? ''; _remember = true; });
    }
  }

  Future<void> _saveCredentials() async {
    final prefs = await SharedPreferences.getInstance();
    if (_remember) {
      await prefs.setString('saved_email', _emailCtrl.text.trim());
      await prefs.setBool('remember', true);
    } else {
      await prefs.remove('saved_email');
      await prefs.setBool('remember', false);
    }
  }

  Future<void> _login() async {
    final email = _emailCtrl.text.trim();
    final pass  = _passwordCtrl.text;
    if (email.isEmpty || pass.isEmpty) { _msg('Completa todos los campos', Colors.orange); return; }
    setState(() => _loading = true);
    try {
      final cred = await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: pass);
      final doc  = await FirebaseFirestore.instance.collection('usuarios').doc(cred.user!.uid).get();
      await _saveCredentials();
      if (!doc.exists || !mounted) return;
      final data   = doc.data()!;
      final rol    = data['rol'] ?? 'jugador';
      final nombre = data['nombre'] ?? '';
      _msg('¡Bienvenido a GesSport!', const Color(0xFFD946EF));
      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      if (rol == 'admin') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const AdminScreen()));
      } else {
        Navigator.pushReplacement(context, MaterialPageRoute(
            builder: (_) => HomeScreen(rol: rol, nombre: nombre, uid: cred.user!.uid)));
      }
    } on FirebaseAuthException catch (e) {
      final msgs = {
        'user-not-found': 'No existe cuenta con este correo',
        'wrong-password': 'Contraseña incorrecta',
        'invalid-email':  'Correo no válido',
        'invalid-credential': 'Credenciales inválidas',
      };
      _msg(msgs[e.code] ?? 'Error al iniciar sesión', Colors.red);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _forgotPassword() {
    final ctrl = TextEditingController();
    showDialog(context: context, builder: (ctx) => AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      title: const Text('Recuperar contraseña'),
      content: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('Ingresa tu correo y te enviamos un enlace'),
        const SizedBox(height: 12),
        TextField(
          controller: ctrl, keyboardType: TextInputType.emailAddress,
          decoration: InputDecoration(
            labelText: 'Correo', prefixIcon: const Icon(Icons.email_outlined),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),
      ]),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
        ElevatedButton(
          style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFD946EF), foregroundColor: Colors.white),
          onPressed: () async {
            try {
              await FirebaseAuth.instance.sendPasswordResetEmail(email: ctrl.text.trim());
              Navigator.pop(ctx);
              _msg('Correo de recuperación enviado', const Color(0xFFD946EF));
            } on FirebaseAuthException { _msg('No existe esa cuenta', Colors.red); }
          },
          child: const Text('Enviar'),
        ),
      ],
    ));
  }

  void _msg(String m, Color c) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
      content: Text(m), backgroundColor: c, behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [Color(0xFFD946EF), Color(0xFFF0ABFC), Color(0xFFFAE8FF)],
          ),
        ),
        child: SafeArea(
          child: FadeTransition(
            opacity: _fade,
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.3), shape: BoxShape.circle),
                    child: const Icon(Icons.sports_soccer, size: 72, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  const Text('GesSport',
                      style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: Colors.white,
                          letterSpacing: 2, shadows: [Shadow(blurRadius: 10, color: Colors.black26)])),
                  const SizedBox(height: 4),
                  Text('Tu app de gestión deportiva',
                      style: TextStyle(fontSize: 14, color: Colors.white.withOpacity(0.9))),
                  const SizedBox(height: 32),
                  Container(
                    decoration: BoxDecoration(color: Colors.white.withOpacity(0.95),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 20, offset: const Offset(0, 10))]),
                    padding: const EdgeInsets.all(24),
                    child: Column(children: [
                      _input(_emailCtrl, 'Correo electrónico', Icons.email_outlined, type: TextInputType.emailAddress),
                      const SizedBox(height: 12),
                      _inputPass(),
                      const SizedBox(height: 8),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        Row(children: [
                          SizedBox(width: 22, height: 22,
                            child: Checkbox(value: _remember, activeColor: const Color(0xFFD946EF),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
                                onChanged: (v) => setState(() => _remember = v ?? false)),
                          ),
                          const SizedBox(width: 6),
                          Text('Recordar', style: TextStyle(color: Colors.grey.shade700, fontSize: 13)),
                        ]),
                        TextButton(onPressed: _forgotPassword,
                            child: const Text('¿Olvidaste tu contraseña?',
                                style: TextStyle(color: Color(0xFFD946EF), fontSize: 12))),
                      ]),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity, height: 50,
                        child: ElevatedButton(
                          onPressed: _loading ? null : _login,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFFD946EF), foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                          ),
                          child: _loading
                              ? const SizedBox(width: 22, height: 22,
                              child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5))
                              : const Text('Iniciar Sesión',
                              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        Text('¿No tienes cuenta? ', style: TextStyle(color: Colors.grey.shade700)),
                        TextButton(
                          onPressed: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const RegisterScreen())),
                          child: const Text('Regístrate',
                              style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFFD946EF))),
                        ),
                      ]),
                    ]),
                  ),
                ]),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _input(TextEditingController ctrl, String label, IconData icon,
      {TextInputType type = TextInputType.text}) {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
      child: TextField(
        controller: ctrl, keyboardType: type,
        decoration: InputDecoration(
          labelText: label, labelStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: Icon(icon, color: const Color(0xFFD946EF)),
          border: InputBorder.none, contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }

  Widget _inputPass() {
    return Container(
      decoration: BoxDecoration(color: Colors.grey.shade50, borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
      child: TextField(
        controller: _passwordCtrl, obscureText: _obscure,
        decoration: InputDecoration(
          labelText: 'Contraseña', labelStyle: TextStyle(color: Colors.grey.shade600),
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFFD946EF)),
          suffixIcon: IconButton(
            icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined,
                color: Colors.grey.shade500),
            onPressed: () => setState(() => _obscure = !_obscure),
          ),
          border: InputBorder.none, contentPadding: const EdgeInsets.all(14),
        ),
      ),
    );
  }
}