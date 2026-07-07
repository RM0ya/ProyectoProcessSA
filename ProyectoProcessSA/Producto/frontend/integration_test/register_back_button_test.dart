import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:process_sa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CP-10 Botón volver regresa a LoginScreen', (tester) async {
    app.main();

    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.tap(find.text('¿No tienes cuenta? Crear cuenta'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Crear cuenta'), findsWidgets);

    await tester.tap(find.byIcon(Icons.arrow_back));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
