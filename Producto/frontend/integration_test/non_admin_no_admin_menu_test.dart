import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:process_sa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CP-18 Usuario sin rol admin NO ve AdminScreen', (tester) async {
    app.main();

    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.enterText(
      find.byKey(const Key('emailField')),
      'usuario@test.cl',
    );

    await tester.enterText(find.byKey(const Key('passwordField')), 'Prueba123');

    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle(const Duration(seconds: 12));

    // Verifica que llegó al Dashboard — texto fijo del AppBar
    expect(find.text('Process SA'), findsOneWidget);

    // Nav bar usuario normal tiene 5 items — findsWidgets porque
    // algunos textos como 'Procesos' aparecen también en el body
    expect(find.text('Inicio'), findsWidgets);
    expect(find.text('Tareas'), findsWidgets);
    expect(find.text('Procesos'), findsWidgets);
    expect(find.text('Perfil'), findsWidgets);
    expect(find.text('Reportes'), findsWidgets);

    // Lo más importante: NO existe ninguna referencia a admin
    expect(find.text('Admin'), findsNothing);
    expect(find.text('Administración'), findsNothing);
    expect(find.text('Acceso administrador'), findsNothing);
  });
}
