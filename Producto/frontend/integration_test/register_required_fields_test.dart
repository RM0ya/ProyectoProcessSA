import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:process_sa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CP-06 Registrar usuario con campos obligatorios', (tester) async {
    app.main();

    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.tap(find.text('¿No tienes cuenta? Crear cuenta'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final emailUnico =
        'test${DateTime.now().millisecondsSinceEpoch}@correo.com';

    await tester.enterText(
      find.byKey(const Key('registroNombreField')),
      'Sebastian',
    );

    await tester.enterText(
      find.byKey(const Key('registroApellidoField')),
      'Mardones',
    );

    await tester.enterText(
      find.byKey(const Key('registroCorreoField')),
      emailUnico,
    );

    await tester.enterText(
      find.byKey(const Key('registroPasswordField')),
      'Password123',
    );

    await tester.enterText(
      find.byKey(const Key('registroConfirmarField')),
      'Password123',
    );

    await tester.tap(find.byKey(const Key('registroTerminosCheck')));

    await tester.tap(find.byKey(const Key('registroCrearCuentaButton')));

    await tester.pumpAndSettle(const Duration(seconds: 8));

    expect(find.text('Iniciar sesión'), findsOneWidget);
  });
}