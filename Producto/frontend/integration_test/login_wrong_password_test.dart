import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:process_sa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CP-02 Login con contraseña incorrecta', (tester) async {
    app.main();

    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Correo válido
    await tester.enterText(
      find.byKey(const Key('emailField')),
      'admin@admin.com',
    );

    // Contraseña incorrecta
    await tester.enterText(
      find.byKey(const Key('passwordField')),
      'clave_incorrecta_123',
    );

    // Tap login
    await tester.tap(find.byKey(const Key('loginButton')));

    // Esperar respuesta del backend y SnackBar
    await tester.pumpAndSettle(const Duration(seconds: 8));

    // Debe mostrar mensaje de error
    expect(find.text('Correo o contraseña incorrectos'), findsOneWidget);

    // Y debe seguir en login
    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}
