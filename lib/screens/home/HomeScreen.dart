import 'package:flutter/material.dart';
import '../admin/partidos_screen.dart';
import '../pistas_screen.dart';
import 'equipo_tab.dart';
import 'inicio_tab.dart';
import 'reservas_tab.dart';
import 'perfil_tab.dart';

class HomeScreen extends StatefulWidget {
  final String rol;
  final String nombre;
  final String uid;

  const HomeScreen({
    super.key,
    required this.rol,
    required this.nombre,
    required this.uid,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _pagina = 0;

  List<Widget> get _paginas {
    if (widget.rol == 'arbitro') {
      return [
        InicioTab(rol: widget.rol, nombre: widget.nombre, uid: widget.uid),
        PartidosScreen(uid: widget.uid, rol: widget.rol),
        PerfilTab(nombre: widget.nombre, rol: widget.rol, uid: widget.uid),
      ];
    }
    return [
      InicioTab(rol: widget.rol, nombre: widget.nombre, uid: widget.uid),
      PistasScreen(mostrarAppBar: false, uid: widget.uid, rol: widget.rol),
      ReservasTab(uid: widget.uid),
      if (widget.rol == 'entrenador' || widget.rol == 'jugador')
        EquipoTab(uid: widget.uid, rol: widget.rol),
      PerfilTab(nombre: widget.nombre, rol: widget.rol, uid: widget.uid),
    ];
  }

  List<BottomNavigationBarItem> get _items {
    if (widget.rol == 'arbitro') {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
        BottomNavigationBarItem(icon: Icon(Icons.sports_soccer_outlined), activeIcon: Icon(Icons.sports_soccer), label: 'Partidos'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
      ];
    }
    // ✅ La lista NO puede ser const cuando contiene un `if` condicional
    return [
      const BottomNavigationBarItem(icon: Icon(Icons.home_outlined), activeIcon: Icon(Icons.home), label: 'Inicio'),
      const BottomNavigationBarItem(icon: Icon(Icons.sports_outlined), activeIcon: Icon(Icons.sports), label: 'Pistas'),
      const BottomNavigationBarItem(icon: Icon(Icons.calendar_today_outlined), activeIcon: Icon(Icons.calendar_today), label: 'Reservas'),
      if (widget.rol == 'entrenador' || widget.rol == 'jugador')
        const BottomNavigationBarItem(icon: Icon(Icons.groups_outlined), activeIcon: Icon(Icons.groups), label: 'Equipo'),
      const BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Perfil'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final paginas = _paginas;
    final items = _items;

    if (_pagina >= paginas.length) _pagina = 0;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F0FF),
      body: IndexedStack(index: _pagina, children: paginas),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _pagina,
        onTap: (i) => setState(() => _pagina = i),
        selectedItemColor: const Color(0xFF6B4CE6),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 12,
        items: items,
      ),
    );
  }
}