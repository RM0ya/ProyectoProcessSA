import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:process_sa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CP-14 Admin edita usuario existente', (tester) async {
    app.main();

    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.enterText(
      find.byKey(const Key('emailField')),
      'admin@admin.com',
    );
    await tester.enterText(find.byKey(const Key('passwordField')), 'admin123');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle(const Duration(seconds: 8));

    await tester.tap(find.text('Admin'));
    await tester.pumpAndSettle(const Duration(seconds: 6));

    final menuButtons = find.byIcon(Icons.more_vert);
    expect(menuButtons, findsWidgets);

    await tester.tap(menuButtons.last);
    await tester.pumpAndSettle(const Duration(seconds: 1));

    await tester.tap(find.text('Editar').last);
    await tester.pumpAndSettle(const Duration(seconds: 2));

    expect(find.text('Editar usuario'), findsOneWidget);

    await tester.enterText(
      find.byKey(const Key('adminNombreField')),
      'UsuarioEditado',
    );

    await tester.tap(find.byKey(const Key('adminGuardarUsuarioButton')));
    await tester.pump(const Duration(seconds: 3));

    expect(find.text('Usuario actualizado correctamente'), findsOneWidget);
  });
}
