import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../lib/presentation/screens/notificaciones/notificaciones_config_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('CP-28 Usuario configura preferencias de notificación', (
    WidgetTester tester,
  ) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      const MaterialApp(home: NotificacionesConfigScreen()),
    );

    await tester.pumpAndSettle();

    expect(find.text('Notificaciones'), findsWidgets);
    expect(find.text('Notificaciones push'), findsOneWidget);
    expect(find.text('Correo electrónico'), findsOneWidget);
    expect(find.text('Tarea asignada'), findsOneWidget);

    await tester.tap(find.byKey(const Key('notificacionesPushSwitch')));
    await tester.pumpAndSettle();

    await tester.tap(find.byKey(const Key('notificacionesCorreoSwitch')));
    await tester.pumpAndSettle();

    await tester.tap(
      find.byKey(const Key('notificacionesTareaAsignadaSwitch')),
    );
    await tester.pumpAndSettle();

    final guardarButton = find.byKey(const Key('guardarNotificacionesButton'));

    await tester.ensureVisible(guardarButton);
    await tester.pumpAndSettle();

    await tester.tap(guardarButton);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));

    expect(find.text('Configuración guardada correctamente'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();

    expect(prefs.getBool('notif_push'), false);
    expect(prefs.getBool('notif_correo'), false);
    expect(prefs.getBool('notif_tarea_asignada'), false);
  });
}
