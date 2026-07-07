import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/providers/usuario_provider.dart';
import 'data/providers/departamento_provider.dart'; // NUEVO
import 'presentation/screens/login/login_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/tareas/tareas_screen.dart';
import 'presentation/screens/procesos/procesos_screen.dart';
import 'presentation/screens/perfil/perfil_screen.dart';
import 'data/providers/organizacion_provider.dart';

void main() {
  runApp(const ProcessSAApp());
}

class ProcessSAApp extends StatelessWidget {
  const ProcessSAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsuarioProvider()),
        ChangeNotifierProvider(create: (_) => DepartamentoProvider()), // NUEVO
        ChangeNotifierProvider(create: (_) => OrganizacionProvider()),
      ],
      child: MaterialApp(
        title: 'Process SA',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF185FA5)),
          useMaterial3: true,
        ),
        initialRoute: '/login',
        routes: {
          '/login': (context) => const LoginScreen(),
          '/dashboard': (context) => const DashboardScreen(),
          '/tareas': (context) => const TareasScreen(),
          '/procesos': (context) => const ProcesosScreen(),
          '/perfil': (context) => const PerfilScreen(),
        },
      ),
    );
  }
}
