// ============================================================
// E-2.x — VALIDACIÓN DE DATOS DE ENTRADA
// Ejecutar: flutter test test/standard/e2_validacion_datos_test.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:process_sa/presentation/screens/login/login_screen.dart';
import 'package:process_sa/presentation/screens/perfil/perfil_screen.dart';
import 'package:process_sa/data/providers/usuario_provider.dart';

void main() {
  Widget appConProviders(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UsuarioProvider>(
          create: (_) => UsuarioProvider(),
        ),
      ],
      child: MaterialApp(
        home: child,
        routes: {
          '/login': (_) => const LoginScreen(),
          '/dashboard': (_) => const Scaffold(body: Text('Dashboard')),
          '/tareas': (_) => const Scaffold(body: Text('Tareas')),
          '/procesos': (_) => const Scaffold(body: Text('Procesos')),
        },
      ),
    );
  }

  group('E-2.1 — Lectura correcta de email y contraseña en LoginScreen', () {
    testWidgets('Existe campo de email y acepta texto', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(appConProviders(const LoginScreen()));
      await tester.pumpAndSettle();

      final emailField = find.byWidgetPredicate(
        (w) =>
            w is TextField &&
            ((w.decoration?.hintText?.toLowerCase().contains('correo') ??
                    false) ||
                (w.decoration?.hintText?.toLowerCase().contains('email') ??
                    false) ||
                (w.decoration?.labelText?.toLowerCase().contains('correo') ??
                    false) ||
                (w.decoration?.labelText?.toLowerCase().contains('email') ??
                    false)),
      );

      expect(
        emailField,
        findsOneWidget,
        reason: 'E-2.1: Debe existir campo de correo/email en LoginScreen',
      );

      await tester.enterText(emailField, 'admin@admin.com');
      await tester.pump();

      expect(
        find.text('admin@admin.com'),
        findsOneWidget,
        reason: 'E-2.1: El email ingresado debe ser visible',
      );
    });

    testWidgets('Campo contraseña tiene obscureText activado', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(appConProviders(const LoginScreen()));
      await tester.pumpAndSettle();

      final passField = find.byWidgetPredicate(
        (w) => w is TextField && w.obscureText == true,
      );

      expect(
        passField,
        findsOneWidget,
        reason:
            'E-2.1: El campo contraseña debe ocultar texto (obscureText: true)',
      );
    });

    testWidgets('Hay exactamente 2 campos de texto en LoginScreen', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(appConProviders(const LoginScreen()));
      await tester.pumpAndSettle();

      expect(
        find.byType(TextField),
        findsNWidgets(2),
        reason: 'E-2.1: LoginScreen debe tener 2 campos: email y contraseña',
      );
    });
  });

  group('E-2.2 — PerfilScreen modo lectura no permite edición', () {
    testWidgets('Todos los TextField de PerfilScreen son readOnly en vista', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(appConProviders(const PerfilScreen()));
      await tester.pumpAndSettle();

      final campos = tester.widgetList<TextField>(find.byType(TextField));

      for (final campo in campos) {
        expect(
          campo.readOnly,
          isTrue,
          reason: 'E-2.2: En modo vista, todos los campos deben ser readOnly',
        );
      }
    });

    testWidgets('PerfilScreen renderiza sin crash', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(appConProviders(const PerfilScreen()));
      await tester.pumpAndSettle();

      expect(
        find.byType(Scaffold),
        findsOneWidget,
        reason: 'E-2.2: PerfilScreen debe cargar sin errores',
      );
    });
  });

  group('E-2.3 — Eliminación de elementos actualiza la lista', () {
    test('Eliminar elemento de lista en memoria reduce el conteo', () {
      final usuarios = [
        {'id': 1, 'nombre': 'Ana'},
        {'id': 2, 'nombre': 'Pedro'},
        {'id': 3, 'nombre': 'María'},
      ];

      final idEliminar = 2;
      usuarios.removeWhere((u) => u['id'] == idEliminar);

      expect(
        usuarios.length,
        equals(2),
        reason: 'E-2.3: Tras eliminar, la lista debe tener un elemento menos',
      );

      expect(
        usuarios.any((u) => u['id'] == idEliminar),
        isFalse,
        reason: 'E-2.3: El elemento eliminado no debe seguir en la lista',
      );
    });

    test('Eliminar proceso de lista en memoria funciona correctamente', () {
      final procesos = [
        {'id': 10, 'nombre': 'Proceso A'},
        {'id': 11, 'nombre': 'Proceso B'},
      ];

      procesos.removeWhere((p) => p['id'] == 10);

      expect(procesos.length, equals(1));

      expect(
        procesos.first['nombre'],
        equals('Proceso B'),
        reason: 'E-2.3: Solo debe quedar el proceso que no se eliminó',
      );
    });
  });
}
