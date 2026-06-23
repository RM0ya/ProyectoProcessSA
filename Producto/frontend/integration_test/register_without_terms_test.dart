import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:process_sa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CP-08 Registrar sin aceptar términos', (tester) async {
    app.main();

    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.tap(find.text('¿No tienes cuenta? Crear cuenta'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    final emailUnico =
        'sin_terminos_${DateTime.now().millisecondsSinceEpoch}@correo.com';

    await tester.enterText(
      find.byKey(const Key('registroNombreField')),
      'Juan',
    );

    await tester.enterText(
      find.byKey(const Key('registroApellidoField')),
      'Perez',
    );

    await tester.enterText(
      find.byKey(const Key('registroCorreoField')),
      emailUnico,
    );

    await tester.enterText(
      find.byKey(const Key('registroPasswordField')),
      'Prueba123',
    );

    await tester.enterText(
      find.byKey(const Key('registroConfirmarField')),
      'Prueba123',
    );

    // NO aceptamos términos

    await tester.tap(find.byKey(const Key('registroCrearCuentaButton')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.byType(SnackBar), findsOneWidget);
    expect(
      find.text('Debes aceptar los términos y condiciones'),
      findsOneWidget,
    );
    expect(find.text('Crear cuenta'), findsWidgets);
  });
}
