import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:process_sa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CP-23 Eliminar proceso con confirmación', (tester) async {
    app.main();

    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.enterText(
      find.byKey(const Key('emailField')),
      'admin@admin.com',
    );
    await tester.enterText(find.byKey(const Key('passwordField')), 'admin123');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle(const Duration(seconds: 8));

    await tester.tap(find.byIcon(Icons.account_tree).last);
    await tester.pumpAndSettle(const Duration(seconds: 8));

    expect(find.text('Procesos'), findsWidgets);

    await tester.tap(find.byKey(const Key('procesoEliminarButton_0')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Eliminar proceso'), findsOneWidget);

    await tester.tap(find.byKey(const Key('confirmarEliminarProcesoButton')));
    await tester.pumpAndSettle(const Duration(seconds: 6));

    expect(find.text('Eliminar proceso'), findsNothing);
    expect(find.text('Procesos'), findsWidgets);
  });
}
