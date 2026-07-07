import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:process_sa/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CP-21 Listar procesos desde el backend', (tester) async {
    app.main();

    await tester.pumpAndSettle(const Duration(seconds: 3));

    await tester.enterText(
      find.byKey(const Key('emailField')),
      'admin@admin.com',
    );
    await tester.enterText(find.byKey(const Key('passwordField')), 'admin123');
    await tester.tap(find.byKey(const Key('loginButton')));
    await tester.pumpAndSettle(const Duration(seconds: 8));

    await tester.tap(find.byIcon(Icons.account_tree).last);
    await tester.pumpAndSettle(const Duration(seconds: 8));

    expect(find.text('Procesos'), findsWidgets);
    expect(find.text('Total'), findsOneWidget);
    expect(find.text('Activos'), findsOneWidget);
    expect(find.text('Riesgo'), findsOneWidget);

    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Text && widget.data != null && widget.data!.contains('→'),
      ),
      findsWidgets,
    );

    expect(
      find.textContaining('En curso').evaluate().isNotEmpty ||
          find.textContaining('En riesgo').evaluate().isNotEmpty ||
          find.textContaining('Vencido').evaluate().isNotEmpty,
      true,
    );
  });
}

