import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:process_sa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CP-20 Usuario edita su perfil', (tester) async {
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

    await tester.tap(find.text('Editar perfil'));
    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.enterText(
      find.byKey(const Key('editarPerfilTelefonoField')),
      '+56912345678',
    );

    await tester.ensureVisible(
      find.byKey(const Key('editarPerfilGuardarButton')),
    );
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('editarPerfilGuardarButton')));
    await tester.pumpAndSettle(const Duration(seconds: 6));

    expect(find.text('Perfil actualizado correctamente'), findsOneWidget);
    expect(find.text('+56912345678'), findsOneWidget);
  });
}
