// lib/main.dart
import 'package:draft1/database/database_helper.dart';
import 'package:draft1/screens/deudas_screen.dart';
import 'package:draft1/screens/eventos_screen.dart';
import 'package:draft1/screens/horario_screen.dart';
import 'package:draft1/screens/noticias_screen.dart';
import 'package:draft1/screens/preseleccion_screen.dart';
import 'package:draft1/screens/solicitudes_screen.dart';
import 'package:draft1/screens/tareas_screen.dart';
import 'package:draft1/screens/videos_screen.dart';
import 'package:draft1/services/api_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'screens/landing_page.dart';
import 'screens/login_page.dart';
import 'screens/home_page.dart';

import 'providers/auth_provider.dart';
import 'providers/user_provider.dart';

void main() async {
  // Ensure Flutter bindings are initialized
  WidgetsFlutterBinding.ensureInitialized();
  initializeDateFormatting("es_ES", null);

  // Initialize database
  await DatabaseHelper.initializeDatabase();
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        Provider(create: (_) => ApiService())
      ],
      child: MaterialApp(
        title: 'UASD App',
        theme: ThemeData(
          primarySwatch: Colors.blue,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          // UASD colors
          primaryColor: const Color(0xFF003DA6), // UASD Blue
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF003DA6),
            secondary: const Color(0xFFE31837), // UASD Red
          ),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const LandingPage(),
          '/login': (context) => const LoginPage(),
          '/home': (context) => const HomePage(),
          '/noticias': (context) => const NoticiasScreen(),
          '/eventos': (context) => const EventosScreen(),
          '/videos': (context) => const VideosScreen(),
          '/deuda': (context) => const DeudasScreen(),
          '/tareas': (context) => const TareasScreen(),
          '/preseleccion': (context) => const PreseleccionScreen(),
          '/solicitudes': (context) => const SolicitudesScreen(),
          '/horarios': (context) => const HorarioScreen(),
        },
      ),
    );
  }
}
