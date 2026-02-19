import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'login_screen.dart';
import 'pistas_screen.dart';
import 'reservas_screen.dart';


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
  int _paginaActual = 0;

  // Colores app
  static const Color morado = Color(0xFF6B4CE6);
  static const Color rosa = Color(0xFFE91E8C);
  static const Color fondo = Color(0xFFF5F0FF);

  // Páginas del BottomNav según rol
  List<Widget> get _paginas => [
    _InicioTab(rol: widget.rol, nombre: widget.nombre, uid: widget.uid),
    const _PistasTab(),
    _ReservasTab(uid: widget.uid),
    if (widget.rol == 'entrenador' || widget.rol == 'jugador')
      _EquipoTab(uid: widget.uid, rol: widget.rol),
    _PerfilTab(nombre: widget.nombre, rol: widget.rol, uid: widget.uid),
  ];

  List<BottomNavigationBarItem> get _items => [
    const BottomNavigationBarItem(
        icon: Icon(Icons.home_outlined),
        activeIcon: Icon(Icons.home),
        label: 'Inicio'),
    const BottomNavigationBarItem(
        icon: Icon(Icons.sports_outlined),
        activeIcon: Icon(Icons.sports),
        label: 'Pistas'),
    const BottomNavigationBarItem(
        icon: Icon(Icons.calendar_today_outlined),
        activeIcon: Icon(Icons.calendar_today),
        label: 'Reservas'),
    if (widget.rol == 'entrenador' || widget.rol == 'jugador')
      const BottomNavigationBarItem(
          icon: Icon(Icons.groups_outlined),
          activeIcon: Icon(Icons.groups),
          label: 'Equipo'),
    const BottomNavigationBarItem(
        icon: Icon(Icons.person_outline),
        activeIcon: Icon(Icons.person),
        label: 'Perfil'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      body: IndexedStack(index: _paginaActual, children: _paginas),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _paginaActual,
        onTap: (i) => setState(() => _paginaActual = i),
        selectedItemColor: morado,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        type: BottomNavigationBarType.fixed,
        backgroundColor: Colors.white,
        elevation: 12,
        items: _items,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  TAB 1 — INICIO  (contenido diferente por rol)
// ─────────────────────────────────────────────────────────────

class _InicioTab extends StatelessWidget {
  final String rol;
  final String nombre;
  final String uid;

  const _InicioTab({required this.rol, required this.nombre, required this.uid});

  static const Color morado = Color(0xFF6B4CE6);
  static const Color rosa = Color(0xFFE91E8C);

  // Color e icono según deporte/rol
  Color get _colorRol {
    switch (rol) {
      case 'entrenador': return const Color(0xFFF59E0B);
      case 'arbitro':    return const Color(0xFF8B5CF6);
      default:           return morado;
    }
  }

  String get _mensajeBienvenida {
    switch (rol) {
      case 'entrenador': return '¡Listo para entrenar, ${nombre.split(' ').first}!';
      case 'arbitro':    return '¡Bienvenido árbitro, ${nombre.split(' ').first}!';
      default:           return '¡Hola, ${nombre.split(' ').first}!';
    }
  }

  String get _subtitulo {
    switch (rol) {
      case 'entrenador': return 'Gestiona tus equipos y entrenamientos';
      case 'arbitro':    return 'Consulta los partidos asignados';
      default:           return 'Consulta tus reservas y actividades';
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      slivers: [
        // AppBar con gradiente
        SliverAppBar(
          expandedHeight: 180,
          floating: false,
          pinned: true,
          automaticallyImplyLeading: false,
          backgroundColor: morado,
          actions: [
            IconButton(
              icon: const Icon(Icons.notifications_outlined, color: Colors.white),
              onPressed: () {},
            ),
            IconButton(
              icon: const Icon(Icons.logout, color: Colors.white),
              onPressed: () => _logout(context),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF6B4CE6), Color(0xFFE91E8C)],
                ),
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 40),
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 26,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            child: Text(
                              nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(_mensajeBienvenida,
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold)),
                                const SizedBox(height: 2),
                                Text(_subtitulo,
                                    style: TextStyle(
                                        color: Colors.white.withOpacity(0.85),
                                        fontSize: 12)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),

        SliverPadding(
          padding: const EdgeInsets.all(16),
          sliver: SliverList(
            delegate: SliverChildListDelegate([
              // Stats rápidas
              _StatsRow(uid: uid, rol: rol),
              const SizedBox(height: 20),

              // Sección próximas reservas
              _SeccionTitulo(
                titulo: 'Próximas reservas',
                icono: Icons.calendar_today,
                color: morado,
              ),
              const SizedBox(height: 10),
              _ProximasReservas(uid: uid),
              const SizedBox(height: 20),

              // Si es entrenador → mis equipos + incidencias
              if (rol == 'entrenador') ...[
                _SeccionTitulo(
                  titulo: 'Mis equipos',
                  icono: Icons.groups,
                  color: const Color(0xFFF59E0B),
                ),
                const SizedBox(height: 10),
                _MisEquipos(uid: uid),
                const SizedBox(height: 20),
                _SeccionTitulo(
                  titulo: 'Incidencias',
                  icono: Icons.warning_amber_outlined,
                  color: rosa,
                ),
                const SizedBox(height: 10),
                _BotonIncidencia(uid: uid, rol: rol, tipo: 'entrenamiento_cancelado'),
              ],

              // Si es jugador → mis equipos + no asistencia
              if (rol == 'jugador') ...[
                _SeccionTitulo(
                  titulo: 'Mi equipo',
                  icono: Icons.groups,
                  color: morado,
                ),
                const SizedBox(height: 10),
                _MisEquipos(uid: uid),
                const SizedBox(height: 20),
                _SeccionTitulo(
                  titulo: 'Incidencias',
                  icono: Icons.warning_amber_outlined,
                  color: rosa,
                ),
                const SizedBox(height: 10),
                _BotonIncidencia(uid: uid, rol: rol, tipo: 'no_asistencia'),
              ],

              // Si es árbitro → partidos asignados
              if (rol == 'arbitro') ...[
                _SeccionTitulo(
                  titulo: 'Partidos asignados',
                  icono: Icons.sports_soccer,
                  color: const Color(0xFF8B5CF6),
                ),
                const SizedBox(height: 10),
                _PartidosArbitro(uid: uid),
              ],

              const SizedBox(height: 80),
            ]),
          ),
        ),
      ],
    );
  }

  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
    if (!context.mounted) return;
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  TAB 2 — PISTAS
// ─────────────────────────────────────────────────────────────

class _PistasTab extends StatelessWidget {
  const _PistasTab();

  @override
  Widget build(BuildContext context) {
    // Reutilizamos PistasScreen pero sin AppBar propio
    return const PistasScreen(mostrarAppBar: false);
  }
}

// ─────────────────────────────────────────────────────────────
//  TAB 3 — MIS RESERVAS
// ─────────────────────────────────────────────────────────────

class _ReservasTab extends StatelessWidget {
  final String uid;
  const _ReservasTab({required this.uid});

  static const Color morado = Color(0xFF6B4CE6);
  static const Color fondo = Color(0xFFF5F0FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: const Text('Mis Reservas'),
        backgroundColor: morado,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('reservas')
            .where('usuarioId', isEqualTo: uid)
            .orderBy('fecha', descending: false)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.calendar_today_outlined,
                      size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text('No tienes reservas',
                      style: TextStyle(color: Colors.grey.shade500, fontSize: 16)),
                  const SizedBox(height: 8),
                  Text('Reserva una pista desde la pestaña Pistas',
                      style: TextStyle(color: Colors.grey.shade400, fontSize: 13)),
                ],
              ),
            );
          }

          final reservas = snapshot.data!.docs;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: reservas.length,
            itemBuilder: (context, i) {
              final data = reservas[i].data() as Map<String, dynamic>;
              return _ReservaCard(
                reservaId: reservas[i].id,
                data: data,
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  TAB 4 — EQUIPO (jugador y entrenador)
// ─────────────────────────────────────────────────────────────

class _EquipoTab extends StatelessWidget {
  final String uid;
  final String rol;
  const _EquipoTab({required this.uid, required this.rol});

  static const Color morado = Color(0xFF6B4CE6);
  static const Color fondo = Color(0xFFF5F0FF);

  @override
  Widget build(BuildContext context) {
    // Buscar equipos donde el uid aparece como jugador o entrenador
    final campo = rol == 'entrenador' ? 'entrenadorId' : 'jugadoresIds';
    final query = rol == 'entrenador'
        ? FirebaseFirestore.instance
        .collection('equipos')
        .where('entrenadorId', isEqualTo: uid)
        .snapshots()
        : FirebaseFirestore.instance
        .collection('equipos')
        .where('jugadoresIds', arrayContains: uid)
        .snapshots();

    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        title: Text(rol == 'entrenador' ? 'Mis Equipos' : 'Mi Equipo'),
        backgroundColor: morado,
        foregroundColor: Colors.white,
        automaticallyImplyLeading: false,
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: query,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.groups_outlined, size: 64, color: Colors.grey.shade300),
                  const SizedBox(height: 12),
                  Text('Sin equipo asignado',
                      style: TextStyle(color: Colors.grey.shade500)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: snapshot.data!.docs.length,
            itemBuilder: (context, i) {
              final doc = snapshot.data!.docs[i];
              final data = doc.data() as Map<String, dynamic>;
              return _EquipoDetalle(
                equipoId: doc.id,
                data: data,
                rol: rol,
                uid: uid,
              );
            },
          );
        },
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────
//  TAB 5 — PERFIL
// ─────────────────────────────────────────────────────────────

class _PerfilTab extends StatelessWidget {
  final String nombre;
  final String rol;
  final String uid;

  const _PerfilTab({required this.nombre, required this.rol, required this.uid});

  static const Color morado = Color(0xFF6B4CE6);
  static const Color rosa = Color(0xFFE91E8C);
  static const Color fondo = Color(0xFFF5F0FF);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      body: FutureBuilder<DocumentSnapshot>(
        future: FirebaseFirestore.instance.collection('usuarios').doc(uid).get(),
        builder: (context, snapshot) {
          final data = snapshot.data?.data() as Map<String, dynamic>? ?? {};
          final email = data['email'] ?? '';
          final telefono = data['telefono'] ?? '';
          final posicion = data['posicion'] ?? '';
          final fechaNac = data['fechaNacimiento'] ?? '';

          return CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 200,
                pinned: true,
                automaticallyImplyLeading: false,
                backgroundColor: morado,
                actions: [
                  IconButton(
                    icon: const Icon(Icons.logout, color: Colors.white),
                    onPressed: () async {
                      await FirebaseAuth.instance.signOut();
                      if (!context.mounted) return;
                      Navigator.pushReplacement(context,
                          MaterialPageRoute(builder: (_) => const LoginScreen()));
                    },
                  )
                ],
                flexibleSpace: FlexibleSpaceBar(
                  background: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [Color(0xFF6B4CE6), Color(0xFFE91E8C)],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(height: 40),
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.white.withOpacity(0.3),
                            child: Text(
                              nombre.isNotEmpty ? nombre[0].toUpperCase() : 'U',
                              style: const TextStyle(
                                  fontSize: 36,
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(nombre,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold)),
                          const SizedBox(height: 4),
                          _RolBadge(rol: rol),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: SliverList(
                  delegate: SliverChildListDelegate([
                    _TarjetaInfo(
                      items: [
                        _InfoItem(icon: Icons.email_outlined, label: 'Email', valor: email),
                        _InfoItem(icon: Icons.phone_outlined, label: 'Teléfono', valor: telefono),
                        if (fechaNac.isNotEmpty)
                          _InfoItem(icon: Icons.cake_outlined, label: 'Fecha nacimiento',
                              valor: _formatFecha(fechaNac)),
                        if (posicion.isNotEmpty)
                          _InfoItem(icon: Icons.sports_soccer_outlined,
                              label: 'Posición', valor: posicion),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Incidencias del usuario
                    const _SeccionTitulo(
                        titulo: 'Mis incidencias',
                        icono: Icons.warning_amber_outlined,
                        color: Color(0xFFE91E8C)),
                    const SizedBox(height: 10),
                    _MisIncidencias(uid: uid),
                    const SizedBox(height: 80),
                  ]),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _formatFecha(String iso) {
    try {
      final d = DateTime.parse(iso);
      return '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {
      return iso;
    }
  }
}

// ─────────────────────────────────────────────────────────────
//  WIDGETS REUTILIZABLES
// ─────────────────────────────────────────────────────────────

class _SeccionTitulo extends StatelessWidget {
  final String titulo;
  final IconData icono;
  final Color color;

  const _SeccionTitulo({
    required this.titulo,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, color: color, size: 20),
        const SizedBox(width: 8),
        Text(titulo,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: color)),
      ],
    );
  }
}

// Stats de bienvenida: reservas, equipo, partidos
class _StatsRow extends StatelessWidget {
  final String uid;
  final String rol;
  const _StatsRow({required this.uid, required this.rol});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _StatCard(
            label: 'Reservas',
            icono: Icons.calendar_today,
            color: const Color(0xFF6B4CE6),
            stream: FirebaseFirestore.instance
                .collection('reservas')
                .where('usuarioId', isEqualTo: uid)
                .snapshots(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Equipos',
            icono: Icons.groups,
            color: const Color(0xFFF59E0B),
            stream: rol == 'entrenador'
                ? FirebaseFirestore.instance
                .collection('equipos')
                .where('entrenadorId', isEqualTo: uid)
                .snapshots()
                : FirebaseFirestore.instance
                .collection('equipos')
                .where('jugadoresIds', arrayContains: uid)
                .snapshots(),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _StatCard(
            label: 'Partidos',
            icono: Icons.sports_soccer,
            color: const Color(0xFFE91E8C),
            stream: FirebaseFirestore.instance
                .collection('partidos')
                .where('arbitroId', isEqualTo: uid)
                .snapshots(),
          ),
        ),
      ],
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final IconData icono;
  final Color color;
  final Stream<QuerySnapshot> stream;

  const _StatCard({
    required this.label,
    required this.icono,
    required this.color,
    required this.stream,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: stream,
      builder: (context, snapshot) {
        final count = snapshot.data?.docs.length ?? 0;
        return Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            children: [
              Icon(icono, color: color, size: 24),
              const SizedBox(height: 6),
              Text('$count',
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: color)),
              Text(label,
                  style: TextStyle(fontSize: 11, color: color),
                  textAlign: TextAlign.center),
            ],
          ),
        );
      },
    );
  }
}

// Próximas reservas del usuario
class _ProximasReservas extends StatelessWidget {
  final String uid;
  const _ProximasReservas({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('reservas')
          .where('usuarioId', isEqualTo: uid)
          .orderBy('fecha')
          .limit(3)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _CardVacia(texto: 'No tienes reservas próximas');
        }
        return Column(
          children: snapshot.data!.docs.map((doc) {
            final data = doc.data() as Map<String, dynamic>;
            return _ReservaCard(reservaId: doc.id, data: data, compacto: true);
          }).toList(),
        );
      },
    );
  }
}

// Card de reserva
class _ReservaCard extends StatelessWidget {
  final String reservaId;
  final Map<String, dynamic> data;
  final bool compacto;

  const _ReservaCard({
    required this.reservaId,
    required this.data,
    this.compacto = false,
  });

  Color _estadoColor(String e) {
    switch (e) {
      case 'confirmada': return Colors.green;
      case 'cancelada':  return Colors.red;
      default:           return Colors.orange;
    }
  }

  @override
  Widget build(BuildContext context) {
    final estado = data['estado'] ?? 'pendiente';
    final pistaNombre = data['pistaNombre'] ?? 'Pista';
    final horaInicio = data['horaInicio'] ?? '';
    final horaFin = data['horaFin'] ?? '';
    String fechaStr = '';
    try {
      final d = DateTime.parse(data['fecha']);
      fechaStr =
      '${d.day.toString().padLeft(2, '0')}/${d.month.toString().padLeft(2, '0')}/${d.year}';
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6B4CE6).withOpacity(0.08),
            blurRadius: 10,
            offset: const Offset(0, 4),
          )
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF6B4CE6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sports_tennis,
                color: Color(0xFF6B4CE6), size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(pistaNombre,
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                Text('$fechaStr  $horaInicio - $horaFin',
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: _estadoColor(estado).withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(estado,
                style: TextStyle(
                    color: _estadoColor(estado),
                    fontSize: 11,
                    fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// Mis equipos (mini lista)
class _MisEquipos extends StatelessWidget {
  final String uid;
  const _MisEquipos({required this.uid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<QuerySnapshot>(
      future: FirebaseFirestore.instance
          .collection('equipos')
          .where('jugadoresIds', arrayContains: uid)
          .get(),
      builder: (context, snap) {
        // También buscamos por entrenador
        return FutureBuilder<QuerySnapshot>(
          future: FirebaseFirestore.instance
              .collection('equipos')
              .where('entrenadorId', isEqualTo: uid)
              .get(),
          builder: (context, snapEnt) {
            final docs = [
              ...?(snap.data?.docs),
              ...?(snapEnt.data?.docs),
            ];
            if (docs.isEmpty) {
              return _CardVacia(texto: 'Sin equipo asignado');
            }
            return Column(
              children: docs.map((doc) {
                final d = doc.data() as Map<String, dynamic>;
                return _EquipoMiniCard(nombre: d['nombre'] ?? 'Equipo');
              }).toList(),
            );
          },
        );
      },
    );
  }
}

class _EquipoMiniCard extends StatelessWidget {
  final String nombre;
  const _EquipoMiniCard({required this.nombre});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: const Color(0xFFF59E0B).withOpacity(0.2),
            child: Text(nombre[0].toUpperCase(),
                style: const TextStyle(
                    color: Color(0xFFF59E0B), fontWeight: FontWeight.bold)),
          ),
          const SizedBox(width: 12),
          Text(nombre, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}

// Equipo detalle (tab equipo)
class _EquipoDetalle extends StatelessWidget {
  final String equipoId;
  final Map<String, dynamic> data;
  final String rol;
  final String uid;

  const _EquipoDetalle({
    required this.equipoId,
    required this.data,
    required this.rol,
    required this.uid,
  });

  @override
  Widget build(BuildContext context) {
    final nombre = data['nombre'] ?? 'Equipo';
    final jugadoresIds = List<String>.from(data['jugadoresIds'] ?? []);

    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      elevation: 3,
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFFF59E0B),
          child: Text(nombre[0].toUpperCase(),
              style: const TextStyle(
                  color: Colors.white, fontWeight: FontWeight.bold)),
        ),
        title: Text(nombre,
            style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text('${jugadoresIds.length} jugadores'),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              children: [
                ...jugadoresIds.map((jid) => _NombreUsuario(uid: jid)),
                if (rol == 'entrenador') ...[
                  const Divider(),
                  ElevatedButton.icon(
                    onPressed: () => _reportarIncidencia(context, uid, nombre),
                    icon: const Icon(Icons.warning_amber),
                    label: const Text('Cancelar entrenamiento'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE91E8C),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _reportarIncidencia(
      BuildContext context, String uid, String equipoNombre) {
    _crearIncidencia(context, uid, equipoNombre, 'entrenamiento_cancelado',
        'El entrenador ha cancelado el entrenamiento de $equipoNombre.');
  }
}

class _NombreUsuario extends StatelessWidget {
  final String uid;
  const _NombreUsuario({required this.uid});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('usuarios').doc(uid).get(),
      builder: (context, snap) {
        final d = snap.data?.data() as Map<String, dynamic>?;
        final nombre = d?['nombre'] ?? 'Jugador';
        final posicion = d?['posicion'] ?? '';
        return ListTile(
          dense: true,
          leading: const CircleAvatar(
            radius: 14,
            backgroundColor: Color(0xFFE8E0FF),
            child: Icon(Icons.person, size: 16, color: Color(0xFF6B4CE6)),
          ),
          title: Text(nombre),
          subtitle: posicion.isNotEmpty ? Text(posicion) : null,
        );
      },
    );
  }
}

// Botón de incidencia
class _BotonIncidencia extends StatelessWidget {
  final String uid;
  final String rol;
  final String tipo;

  const _BotonIncidencia({
    required this.uid,
    required this.rol,
    required this.tipo,
  });

  @override
  Widget build(BuildContext context) {
    final esEntrenador = tipo == 'entrenamiento_cancelado';
    return GestureDetector(
      onTap: () => _mostrarDialogoIncidencia(context),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFFE91E8C).withOpacity(0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
              color: const Color(0xFFE91E8C).withOpacity(0.3)),
        ),
        child: Row(
          children: [
            Icon(
              esEntrenador
                  ? Icons.cancel_presentation
                  : Icons.person_off_outlined,
              color: const Color(0xFFE91E8C),
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    esEntrenador
                        ? 'Cancelar entrenamiento'
                        : 'No puedo asistir',
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFFE91E8C)),
                  ),
                  Text(
                    esEntrenador
                        ? 'Notifica la cancelación al equipo'
                        : 'Notifica que no asistirás',
                    style: const TextStyle(
                        fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }

  void _mostrarDialogoIncidencia(BuildContext context) {
    final mensajeCtrl = TextEditingController();
    final esEntrenador = tipo == 'entrenamiento_cancelado';
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(Icons.warning_amber, color: const Color(0xFFE91E8C)),
            const SizedBox(width: 8),
            Text(esEntrenador ? 'Cancelar entrenamiento' : 'No puedo asistir'),
          ],
        ),
        content: TextField(
          controller: mensajeCtrl,
          maxLines: 3,
          decoration: InputDecoration(
            hintText: 'Añade un motivo (opcional)',
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _crearIncidencia(
                context,
                uid,
                '',
                tipo,
                mensajeCtrl.text.trim().isNotEmpty
                    ? mensajeCtrl.text.trim()
                    : (esEntrenador
                    ? 'Entrenamiento cancelado'
                    : 'El jugador no puede asistir'),
              );
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFE91E8C),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text('Enviar'),
          ),
        ],
      ),
    );
  }
}

Future<void> _crearIncidencia(
    BuildContext context,
    String uid,
    String equipoNombre,
    String tipo,
    String mensaje,
    ) async {
  try {
    await FirebaseFirestore.instance.collection('incidencias').add({
      'usuarioId': uid,
      'tipo': tipo,
      'mensaje': mensaje,
      'equipo': equipoNombre,
      'fecha': DateTime.now().toIso8601String(),
      'leida': false,
    });
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Incidencia enviada'),
        backgroundColor: Colors.green,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  } catch (e) {
    if (!context.mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red),
    );
  }
}

// Partidos del árbitro
class _PartidosArbitro extends StatelessWidget {
  final String uid;
  const _PartidosArbitro({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('partidos')
          .where('arbitroId', isEqualTo: uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _CardVacia(texto: 'Sin partidos asignados');
        }
        return Column(
          children: snapshot.data!.docs.map((doc) {
            final d = doc.data() as Map<String, dynamic>;
            return _PartidoMiniCard(data: d);
          }).toList(),
        );
      },
    );
  }
}

class _PartidoMiniCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _PartidoMiniCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final estado = data['estado'] ?? 'programado';
    String fechaStr = '';
    try {
      final d = DateTime.parse(data['fecha']);
      fechaStr = '${d.day}/${d.month}/${d.year}';
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 2))
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.sports_soccer,
                color: Color(0xFF8B5CF6), size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    _NombreEquipo(id: data['equipoLocalId']),
                    const Text(' vs ',
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.grey)),
                    _NombreEquipo(id: data['equipoVisitanteId']),
                  ],
                ),
                Text(fechaStr,
                    style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          _EstadoBadge(estado: estado),
        ],
      ),
    );
  }
}

class _NombreEquipo extends StatelessWidget {
  final String? id;
  const _NombreEquipo({this.id});

  @override
  Widget build(BuildContext context) {
    if (id == null) return const Text('?');
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance.collection('equipos').doc(id).get(),
      builder: (ctx, snap) {
        final d = snap.data?.data() as Map<String, dynamic>?;
        return Text(d?['nombre'] ?? id!,
            style: const TextStyle(
                fontWeight: FontWeight.bold, fontSize: 13));
      },
    );
  }
}

class _EstadoBadge extends StatelessWidget {
  final String estado;
  const _EstadoBadge({required this.estado});

  Color get _color {
    switch (estado) {
      case 'finalizado': return Colors.green;
      case 'en_curso':   return Colors.orange;
      case 'cancelado':  return Colors.red;
      default:           return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(estado.replaceAll('_', ' '),
          style: TextStyle(
              color: _color, fontSize: 10, fontWeight: FontWeight.bold)),
    );
  }
}

// Mis incidencias
class _MisIncidencias extends StatelessWidget {
  final String uid;
  const _MisIncidencias({required this.uid});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('incidencias')
          .where('usuarioId', isEqualTo: uid)
          .orderBy('fecha', descending: true)
          .limit(5)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return _CardVacia(texto: 'Sin incidencias registradas');
        }
        return Column(
          children: snapshot.data!.docs.map((doc) {
            final d = doc.data() as Map<String, dynamic>;
            return _IncidenciaCard(data: d);
          }).toList(),
        );
      },
    );
  }
}

class _IncidenciaCard extends StatelessWidget {
  final Map<String, dynamic> data;
  const _IncidenciaCard({required this.data});

  @override
  Widget build(BuildContext context) {
    final tipo = data['tipo'] ?? '';
    final mensaje = data['mensaje'] ?? '';
    String fechaStr = '';
    try {
      final d = DateTime.parse(data['fecha']);
      fechaStr = '${d.day}/${d.month}/${d.year}';
    } catch (_) {}

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFFE91E8C).withOpacity(0.06),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
            color: const Color(0xFFE91E8C).withOpacity(0.2)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber, color: Color(0xFFE91E8C), size: 18),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(tipo.replaceAll('_', ' '),
                    style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 13,
                        color: Color(0xFFE91E8C))),
                if (mensaje.isNotEmpty)
                  Text(mensaje,
                      style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          Text(fechaStr,
              style: const TextStyle(fontSize: 11, color: Colors.grey)),
        ],
      ),
    );
  }
}

// Tarjeta info perfil
class _TarjetaInfo extends StatelessWidget {
  final List<_InfoItem> items;
  const _TarjetaInfo({required this.items});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: const Color(0xFF6B4CE6).withOpacity(0.08),
              blurRadius: 12,
              offset: const Offset(0, 4))
        ],
      ),
      child: Column(
        children: items.asMap().entries.map((e) {
          final item = e.value;
          final isLast = e.key == items.length - 1;
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF6B4CE6).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Icon(item.icon,
                          color: const Color(0xFF6B4CE6), size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(item.label,
                              style: const TextStyle(
                                  fontSize: 11, color: Colors.grey)),
                          Text(item.valor.isNotEmpty ? item.valor : '-',
                              style: const TextStyle(
                                  fontWeight: FontWeight.w600)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (!isLast) Divider(height: 1, color: Colors.grey.shade100),
            ],
          );
        }).toList(),
      ),
    );
  }
}

class _InfoItem {
  final IconData icon;
  final String label;
  final String valor;
  const _InfoItem({required this.icon, required this.label, required this.valor});
}

class _CardVacia extends StatelessWidget {
  final String texto;
  const _CardVacia({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, color: Colors.grey.shade400, size: 18),
          const SizedBox(width: 10),
          Text(texto,
              style: TextStyle(color: Colors.grey.shade500, fontSize: 13)),
        ],
      ),
    );
  }
}

class _RolBadge extends StatelessWidget {
  final String rol;
  const _RolBadge({required this.rol});

  Color get _color {
    switch (rol) {
      case 'entrenador': return const Color(0xFFF59E0B);
      case 'arbitro':    return const Color(0xFF8B5CF6);
      default:           return Colors.white;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        rol.toUpperCase(),
        style: const TextStyle(
            color: Colors.white,
            fontSize: 12,
            fontWeight: FontWeight.bold,
            letterSpacing: 1),
      ),
    );
  }
}