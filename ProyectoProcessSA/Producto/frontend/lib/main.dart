import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'data/providers/usuario_provider.dart';
import 'data/providers/departamento_provider.dart';
import 'presentation/screens/login/login_screen.dart';
import 'presentation/screens/dashboard/dashboard_screen.dart';
import 'presentation/screens/tareas/tareas_screen.dart';
import 'presentation/screens/procesos/procesos_screen.dart';
import 'presentation/screens/perfil/perfil_screen.dart';
import 'data/providers/organizacion_provider.dart';
import 'data/providers/tarea_provider.dart';
import 'data/providers/proceso_provider.dart';
import 'presentation/screens/organizaciones/organizaciones_screen.dart';
import 'presentation/screens/admin/admin_screen.dart';
import 'presentation/screens/admin/super_admin_screen.dart';
import 'presentation/screens/departamentos/departamentos_screen.dart';
import 'data/providers/notificacion_provider.dart';

void main() async {
  // Asegura que los servicios de Flutter estén inicializados
  WidgetsFlutterBinding.ensureInitialized();

  runApp(const ProcessSAApp());
}

class ProcessSAApp extends StatelessWidget {
  const ProcessSAApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UsuarioProvider()),
        ChangeNotifierProvider(create: (_) => DepartamentoProvider()),
        ChangeNotifierProvider(create: (_) => OrganizacionProvider()),
        ChangeNotifierProvider(create: (_) => TareaProvider()),
        ChangeNotifierProvider(create: (_) => ProcesoProvider()),
         ChangeNotifierProvider(create: (_) => NotificacionProvider()),
      ],
      child: const AppInitializer(),
    );
  }
}

// Este widget auxiliar verifica la sesión guardada (token + usuario) sin
// bloquear la carga inicial, y decide a qué pantalla navegar según el rol.
class AppInitializer extends StatelessWidget {
  const AppInitializer({super.key});

  @override
  Widget build(BuildContext context) {
    // Se toma la instancia ya creada por el MultiProvider (no se crea otra),
    // y se espera su Future "inicializado" para saber cuándo ya se restauró
    // la sesión completa (token + datos de usuario) desde el storage.
    final usuarioProvider = context.read<UsuarioProvider>();

    return MaterialApp(
      title: 'Process SA',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF185FA5)),
        useMaterial3: true,
      ),
      home: FutureBuilder(
        future: usuarioProvider.inicializado,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          }

          final usuarioLogueado = usuarioProvider.usuarioLogueado;
          final token = usuarioProvider.token;

          // Sin sesión válida (no hay token o no se pudo restaurar el
          // usuario) -> a login.
          if (token == null || usuarioLogueado == null) {
            return const LoginScreen();
          }

          // Con sesión restaurada, se respeta el rol igual que en el login
          // manual: un superadmin va directo a su panel, no al dashboard.
          if (usuarioProvider.esSuperAdmin) {
            return const SuperAdminScreen();
          }

          return const DashboardScreen();
        },
      ),
      routes: {
        '/login': (context) => const LoginScreen(),
        '/dashboard': (context) => const DashboardScreen(),
        '/tareas': (context) => const TareasScreen(),
        '/procesos': (context) => const ProcesosScreen(),
        '/perfil': (context) => const PerfilScreen(),
        '/organizaciones': (context) => const OrganizacionesScreen(),
        '/usuarios': (context) => const AdminScreen(),
        '/super_admin': (context) => const SuperAdminScreen(),
        '/departamentos': (context) => const DepartamentosScreen(),
      },
    );
  }
}
