import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:process_sa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CP-09 Validación visual requisitos contraseña', (tester) async {
    app.main();

    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.tap(find.text('¿No tienes cuenta? Crear cuenta'));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Mínimo 8 caracteres'), findsOneWidget);
    expect(find.text('Al menos una mayúscula'), findsOneWidget);
    expect(find.text('Al menos un número'), findsOneWidget);

    await tester.enterText(find.byKey(const Key('registroPasswordField')), 'a');
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('registroPasswordField')),
      'aA',
    );
    await tester.pumpAndSettle();

    await tester.enterText(
      find.byKey(const Key('registroPasswordField')),
      'aA123456',
    );
    await tester.pumpAndSettle();

    expect(find.text('Mínimo 8 caracteres'), findsOneWidget);
    expect(find.text('Al menos una mayúscula'), findsOneWidget);
    expect(find.text('Al menos un número'), findsOneWidget);
  });
}
