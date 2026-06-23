import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:process_sa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CP-13 Admin crea nuevo usuario con datos válidos', (
    tester,
  ) async {
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

    // Ir a Admin
    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle(const Duration(seconds: 6));

    // Abrir formulario nuevo usuario
    await tester.tap(find.byKey(const Key('adminNuevoUsuarioButton')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Completar campos
    final emailUnico = 'nuevo_${DateTime.now().millisecondsSinceEpoch}@test.cl';

    await tester.enterText(find.byKey(const Key('adminNombreField')), 'Test');
    await tester.enterText(
      find.byKey(const Key('adminApellidoField')),
      'Usuario',
    );
    await tester.enterText(
      find.byKey(const Key('adminEmailField')),
      emailUnico,
    );
    await tester.enterText(
      find.byKey(const Key('adminPasswordField')),
      'Test123',
    );

    // Seleccionar organización
    await tester.tap(find.byKey(const Key('adminOrganizacionDropdown')));
    await tester.pumpAndSettle(const Duration(seconds: 2));

    // Elegimos la primera opción disponible que NO sea el hint
    final primeraOrg = find.text('Mi Empresa').last;
    await tester.tap(primeraOrg);
    await tester.pumpAndSettle(const Duration(seconds: 3));

    // Guardar usuario
    await tester.tap(find.byKey(const Key('adminGuardarUsuarioButton')));
    await tester.pump(const Duration(seconds: 2));

    expect(find.text('Usuario creado correctamente'), findsOneWidget);
  });
}
