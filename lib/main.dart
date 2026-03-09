import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:login_flutter/provider/equipos_provider.dart';
import 'package:login_flutter/provider/instalaciones_provider.dart';
import 'package:login_flutter/provider/partidos_provider.dart';
import 'package:login_flutter/provider/reservas_provider.dart';
import 'package:login_flutter/provider/user_provider.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProvider(create: (_) => InstalacionesProvider()),
        ChangeNotifierProvider(create: (_) => EquiposProvider()),
        ChangeNotifierProvider(create: (_) => PartidosProvider()),
        ChangeNotifierProvider(create: (_) => ReservasProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'GesSport',
        theme: ThemeData(
          primarySwatch: Colors.green,
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}