import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:process_sa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CP-26 Crear nueva tarea', (tester) async {
    app.main();

    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.enterText(
      find.byKey(const Key('emailField')),
      'admin@admin.com',
    );

    await tester.enterText(find.byKey(const Key('passwordField')), 'admin123');

    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle(const Duration(seconds: 8));

    await tester.tap(find.byIcon(Icons.task).last);
    await tester.pumpAndSettle(const Duration(seconds: 8));

    final nombreTarea = 'TareaTest${DateTime.now().millisecondsSinceEpoch}';

    await tester.tap(find.byType(FloatingActionButton));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    await tester.enterText(
      find.byKey(const Key('crearTareaTituloField')),
      nombreTarea,
    );

    await tester.enterText(
      find.byKey(const Key('crearTareaDescripcionField')),
      'Descripción automática CP-26',
    );

    await tester.tap(find.byKey(const Key('crearTareaFechaField')));
    await tester.pumpAndSettle();

    await tester.tap(find.text('OK'));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('crearTareaButton')));
    await tester.pumpAndSettle(const Duration(seconds: 8));

    if (find.byKey(const Key('crearTareaTituloField')).evaluate().isNotEmpty) {
      await tester.pageBack();
      await tester.pumpAndSettle(const Duration(seconds: 5));
    }

    await tester.drag(find.byType(Scrollable).first, const Offset(0, 500));
    await tester.pumpAndSettle(const Duration(seconds: 5));

    await tester.scrollUntilVisible(
      find.text(nombreTarea),
      300,
      scrollable: find.byType(Scrollable).first,
    );

    expect(find.text(nombreTarea), findsOneWidget);
  });
}
