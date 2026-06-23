import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:process_sa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CP-04 Mostrar/ocultar contraseña en Login', (tester) async {
    app.main();

    await tester.pumpAndSettle(const Duration(seconds: 3));

    final passwordField = find.byKey(const Key('passwordField'));

    expect(passwordField, findsOneWidget);

    await tester.enterText(passwordField, 'Admin123');
    await tester.pumpAndSettle();

    TextField campoPassword = tester.widget<TextField>(passwordField);
    expect(campoPassword.obscureText, isTrue);

    final Offset centroPassword = tester.getCenter(passwordField);

    await tester.tapAt(Offset(centroPassword.dx + 130, centroPassword.dy));
    await tester.pumpAndSettle();

    campoPassword = tester.widget<TextField>(passwordField);
    expect(campoPassword.obscureText, isFalse);

    await tester.tapAt(Offset(centroPassword.dx + 130, centroPassword.dy));
    await tester.pumpAndSettle();

    campoPassword = tester.widget<TextField>(passwordField);
    expect(campoPassword.obscureText, isTrue);
  });
}
