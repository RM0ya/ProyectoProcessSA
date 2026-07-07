import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import '../../lib/data/models/usuario_model.dart';
import '../../lib/data/providers/usuario_provider.dart';
import '../../lib/presentation/screens/dashboard/dashboard_screen.dart';

class LoginFakeScreen extends StatelessWidget {
  const LoginFakeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(body: Text('LoginScreen'));
  }
}

void main() {
  testWidgets('CP-29 Cerrar sesión limpia provider y navega a LoginScreen', (
    WidgetTester tester,
  ) async {
    final provider = UsuarioProvider();

    provider.usuarioLogueado = UsuarioModel(
      idUsuario: 1,
      nombre: 'Sebastian',
      apellidoP: 'Mardones',
      apellidoM: '',
      emailUsuario: 'test@correo.com',
      password: '',
      intentosFallidos: 0,
      bloqueado: 'N',
      ultimoLogin: '2026-06-22T10:00:00',
      fechaCreacion: '2026-06-22',
      rol: {'idRol': 1, 'nombre': 'Admin'},
      organizacion: {'idOrganizacion': 1, 'nombre': 'Process SA'},
      departamento: {'idDepartamento': 1, 'nombre': 'Gestión'},
    );

    await tester.pumpWidget(
      ChangeNotifierProvider<UsuarioProvider>.value(
        value: provider,
        child: MaterialApp(
          home: const DashboardScreen(),
          routes: {'/login': (_) => const LoginFakeScreen()},
        ),
      ),
    );

    await tester.pumpAndSettle();

    expect(provider.usuarioLogueado, isNotNull);

    await tester.tap(find.byIcon(Icons.logout));
    await tester.pumpAndSettle();

    expect(find.text('Cerrar sesión'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirmarLogoutButton')));
    await tester.pumpAndSettle();

    expect(provider.usuarioLogueado, isNull);
    expect(provider.token, isNull);
    expect(find.text('LoginScreen'), findsOneWidget);
  });
}
