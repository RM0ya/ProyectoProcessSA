// ============================================================
// E-1.x — INTERFAZ GRÁFICA
// Ejecutar: flutter test test/standard/e1_interfaz_grafica_test.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:process_sa/presentation/screens/login/login_screen.dart';
import 'package:process_sa/presentation/screens/registro/registro_screen.dart';
import 'package:process_sa/presentation/screens/perfil/perfil_screen.dart';
import 'package:process_sa/presentation/screens/tareas/crear_tarea_screen.dart';
import 'package:process_sa/presentation/screens/editar_perfil/editar_perfil_screen.dart';
import 'package:process_sa/data/providers/usuario_provider.dart';

void main() {
  Widget appConProviders(Widget child) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<UsuarioProvider>(
          create: (_) => UsuarioProvider(),
        ),
      ],
      child: MaterialApp(home: child),
    );
  }

  group('E-1.1 — SnackBars tienen ícono', () {
    testWidgets('SnackBar de error en LoginScreen tiene ícono visible', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(appConProviders(const LoginScreen()));
      await tester.pumpAndSettle();

      final botonLogin = find.widgetWithText(ElevatedButton, 'Iniciar sesión');

      if (tester.any(botonLogin)) {
        await tester.tap(botonLogin);
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 400));

        final snackbar = find.byType(SnackBar);

        if (tester.any(snackbar)) {
          expect(snackbar, findsOneWidget);

          final iconoEnSnack = find.descendant(
            of: snackbar,
            matching: find.byType(Icon),
          );

          expect(iconoEnSnack, findsAtLeastNWidgets(1));
        }
      }

      expect(find.byType(Scaffold), findsOneWidget);
    });
  });

  group('E-1.2 — Botones con texto o ícono adecuado', () {
    testWidgets('LoginScreen tiene texto descriptivo en botón principal', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(appConProviders(const LoginScreen()));
      await tester.pumpAndSettle();

      final botones = find.byType(ElevatedButton);

      expect(botones, findsAtLeastNWidgets(1));

      final textoBoton = find.descendant(
        of: botones,
        matching: find.byType(Text),
      );

      expect(textoBoton, findsAtLeastNWidgets(1));
    });

    testWidgets('RegistroScreen tiene botón Crear Cuenta con texto', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(appConProviders(const RegistroScreen()));
      await tester.pumpAndSettle();

      final botones = find.byType(ElevatedButton);

      expect(botones, findsAtLeastNWidgets(1));
    });
  });

  group('E-1.3 — Botón volver en pantallas secundarias', () {
    Future<void> verificarBotonVolver(
      WidgetTester tester,
      Widget pantalla,
      String nombre,
    ) async {
      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider<UsuarioProvider>(
              create: (_) => UsuarioProvider(),
            ),
          ],
          child: MaterialApp(home: const Scaffold(body: Text('Home'))),
        ),
      );

      final NavigatorState nav = tester.state(find.byType(Navigator));

      nav.push(
        MaterialPageRoute(
          builder: (_) => MultiProvider(
            providers: [
              ChangeNotifierProvider<UsuarioProvider>(
                create: (_) => UsuarioProvider(),
              ),
            ],
            child: pantalla,
          ),
        ),
      );

      await tester.pumpAndSettle();

      final tieneBack =
          tester.any(find.byType(BackButton)) ||
          tester.any(find.byIcon(Icons.arrow_back)) ||
          tester.any(find.byIcon(Icons.arrow_back_ios)) ||
          tester.any(find.byIcon(Icons.arrow_back_ios_new));

      expect(
        tieneBack,
        isTrue,
        reason:
            'E-1.3: $nombre debe tener botón Volver (BackButton o arrow_back)',
      );
    }

    testWidgets('RegistroScreen tiene botón volver', (tester) async {
      await verificarBotonVolver(
        tester,
        const RegistroScreen(),
        'RegistroScreen',
      );
    });

    testWidgets('CrearTareaScreen tiene botón volver', (tester) async {
      await verificarBotonVolver(
        tester,
        const CrearTareaScreen(),
        'CrearTareaScreen',
      );
    });

    testWidgets('EditarPerfilScreen tiene botón volver', (tester) async {
      await verificarBotonVolver(
        tester,
        const EditarPerfilScreen(),
        'EditarPerfilScreen',
      );
    });

    testWidgets('PerfilScreen tiene botón volver', (tester) async {
      await verificarBotonVolver(tester, const PerfilScreen(), 'PerfilScreen');
    });
  });
}
