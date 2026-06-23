import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:process_sa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CP-07 Registrar con contraseñas no coincidentes', (tester) async {
    app.main();

    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Ir a registro
    await tester.tap(find.text('¿No tienes cuenta? Crear cuenta'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Completar datos válidos
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
      'juan_mismatch_test@correo.com',
    );

    await tester.enterText(
      find.byKey(const Key('registroPasswordField')),
      'Prueba123',
    );

    await tester.enterText(
      find.byKey(const Key('registroConfirmarField')),
      'Otra456',
    );

    // Aceptar términos
    await tester.tap(find.byKey(const Key('registroTerminosCheck')));
    await tester.pumpAndSettle();

    // Crear cuenta
    await tester.tap(find.byKey(const Key('registroCrearCuentaButton')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Validaciones
    expect(find.byType(SnackBar), findsOneWidget);
    expect(find.text('Las contraseñas no coinciden'), findsOneWidget);
    expect(find.text('Crear cuenta'), findsWidgets);
  });
}
