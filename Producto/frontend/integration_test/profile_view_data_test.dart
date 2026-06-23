import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:process_sa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CP-19 Usuario ve sus datos de perfil correctamente', (
    tester,
  ) async {
    app.main();

    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.enterText(
      find.byKey(const Key('emailField')),
      'admin@admin.com',
    );

    await tester.enterText(find.byKey(const Key('passwordField')), 'admin123');

    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle(const Duration(seconds: 8));

    await tester.tap(find.text('Perfil'));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    expect(find.text('Perfil'), findsWidgets);
    expect(find.text('Administrador Sistema'), findsOneWidget);
    expect(find.text('admin@admin.com'), findsWidgets);
    expect(find.text('Admin'), findsWidgets);
    expect(find.text('Mi Empresa'), findsOneWidget);
    expect(find.text('Gestión de Proyectos'), findsOneWidget);
  });
}
