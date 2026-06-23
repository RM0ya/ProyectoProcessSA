import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:process_sa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CP-16 Admin cancela eliminación de usuario', (tester) async {
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

    final popupMenus = find.byIcon(Icons.more_vert);
    expect(popupMenus, findsWidgets);

    bool eliminadoAbierto = false;
    final cantidad = popupMenus.evaluate().length;

    for (int i = 0; i < cantidad; i++) {
      await tester.tap(popupMenus.at(i));
      await tester.pumpAndSettle(const Duration(seconds: 2));

      final eliminarFinder = find.text('Eliminar');

      if (eliminarFinder.evaluate().isNotEmpty) {
        await tester.tap(eliminarFinder.last);
        await tester.pumpAndSettle(const Duration(seconds: 2));
        eliminadoAbierto = true;
        break;
      }

      await tester.tapAt(const Offset(10, 10));
      await tester.pumpAndSettle(const Duration(seconds: 1));
    }

    expect(
      eliminadoAbierto,
      isTrue,
      reason: 'No se encontró ningún usuario eliminable',
    );

    expect(find.text('Eliminar usuario'), findsOneWidget);

    await tester.tap(find.byKey(const Key('adminCancelarEliminarButton')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Eliminar usuario'), findsNothing);
    expect(find.text('Usuario eliminado'), findsNothing);
  });
}
