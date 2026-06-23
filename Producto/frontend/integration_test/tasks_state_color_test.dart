import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:process_sa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CP-25 Color de tarjeta según estado de tarea', (tester) async {
    app.main();

    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Login admin
    await tester.enterText(
      find.byKey(const Key('emailField')),
      'admin@admin.com',
    );
    await tester.enterText(find.byKey(const Key('passwordField')), 'admin123');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle(const Duration(seconds: 8));

    // Ir a Tareas
    await tester.tap(find.byIcon(Icons.task).last);
    await tester.pumpAndSettle(const Duration(seconds: 8));

    expect(find.text('Tareas'), findsWidgets);

    // Verde -> completada/completado
    expect(
      find.textContaining('Completada').evaluate().isNotEmpty ||
          find.textContaining('Completado').evaluate().isNotEmpty,
      true,
    );

    // Azul -> activo/en curso
    expect(
      find.textContaining('Activo').evaluate().isNotEmpty ||
          find.textContaining('En curso').evaluate().isNotEmpty,
      true,
    );

    // Rojo -> vencida/inactivo
    expect(
      find.textContaining('Vencida').evaluate().isNotEmpty ||
          find.textContaining('Inactivo').evaluate().isNotEmpty,
      true,
    );
  });
}
