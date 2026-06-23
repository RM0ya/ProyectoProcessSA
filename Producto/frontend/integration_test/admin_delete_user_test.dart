import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:process_sa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CP-15 Admin elimina usuario con confirmación', (tester) async {
    app.main();
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.enterText(
      find.byKey(const Key('emailField')),
      'admin@admin.com',
    );

    await tester.enterText(find.byKey(const Key('passwordField')), 'admin123');

    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle(const Duration(seconds: 12));

    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle(const Duration(seconds: 6));

    expect(find.text('Administración'), findsOneWidget);

    const emailObjetivo = 'usuario@test.cl';

    expect(find.text(emailObjetivo), findsOneWidget);

    // Mover un poco hacia arriba para que el menú no quede tapado por el botón flotante.
    final scrollables = find.byType(Scrollable);
    if (scrollables.evaluate().isNotEmpty) {
      await tester.drag(scrollables.last, const Offset(0, -180));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    expect(find.text(emailObjetivo), findsOneWidget);

    // Como el usuario es el último visible, usamos el último menú de tres puntos visible.
    final menus = find.byIcon(Icons.more_vert);
    expect(menus, findsWidgets);

    await tester.tap(menus.last, warnIfMissed: false);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Eliminar'), findsOneWidget);

    await tester.tap(find.text('Eliminar').last);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Eliminar usuario'), findsOneWidget);

    await tester.tap(find.byKey(const Key('adminConfirmarEliminarButton')));
    await tester.pump(const Duration(seconds: 1));

    expect(
      find.text(emailObjetivo),
      findsNothing,
      reason: 'El usuario debe desaparecer de la lista después de eliminarse',
    );
  });
}
