import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:process_sa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CP-24 Listar tareas vista admin', (tester) async {
    app.main();

    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.enterText(
      find.byKey(const Key('emailField')),
      'admin@admin.com',
    );

    await tester.enterText(find.byKey(const Key('passwordField')), 'admin123');

    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle(const Duration(seconds: 8));

    await tester.tap(find.byIcon(Icons.task).last);
    await tester.pumpAndSettle(const Duration(seconds: 8));

    expect(find.text('Tareas'), findsWidgets);

    expect(
      find.textContaining('Activo').evaluate().isNotEmpty ||
          find.textContaining('Inactivo').evaluate().isNotEmpty ||
          find.textContaining('Completada').evaluate().isNotEmpty ||
          find.textContaining('Pendiente').evaluate().isNotEmpty,
      true,
    );

    expect(find.byIcon(Icons.delete_outline), findsWidgets);
  });
}
