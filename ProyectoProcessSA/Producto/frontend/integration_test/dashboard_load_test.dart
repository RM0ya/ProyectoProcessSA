import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:process_sa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CP-11 Dashboard carga correctamente post-login', (tester) async {
    app.main();

    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.enterText(
      find.byKey(const Key('emailField')),
      'admin@admin.com',
    );

    await tester.enterText(find.byKey(const Key('passwordField')), 'admin123');

    await tester.tap(find.byKey(const Key('loginButton')));

    await tester.pumpAndSettle(const Duration(seconds: 8));

    expect(find.text('Process SA'), findsOneWidget);
    expect(find.text('Hola, Administrador'), findsOneWidget);
    expect(find.text('Admin · Process SA'), findsOneWidget);
    expect(find.text('Acceso administrador'), findsOneWidget);

    expect(find.text('Tareas activas'), findsOneWidget);
    expect(find.text('Cumplimiento'), findsOneWidget);
    expect(find.text('Procesos'), findsWidgets);
    expect(find.text('Completadas'), findsOneWidget);

    expect(find.text('Tareas recientes'), findsOneWidget);
  });
}
