import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import '../../lib/data/models/tarea_model.dart';
import '../../lib/presentation/screens/tareas/tareas_screen.dart';

void main() {
  testWidgets(
    'CP-27 Ver detalle de tarea - navega a TareaDetalleScreen con datos de tarea',
    (WidgetTester tester) async {
      final tarea = TareaModel(
        idTarea: 99,
        idProceso: 1,
        idUsuario: 1,
        idEstado: 1,
        nombreTarea: 'Revisión contrato cliente A',
        descripcionT: 'Revisar cláusulas del contrato',
        ordenT: 1,
        fechaLimiteS: '2026-06-30',
        fechaCompletada: null,
        fechaCreacionT: '2026-06-22',
        nombreProceso: 'Onboarding cliente A',
        nombreUsuario: 'Sebastian Mardones',
        nombreEstado: 'Activo',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: TareasScreen(tareasFutureOverride: Future.value([tarea])),
        ),
      );

      await tester.pumpAndSettle();

      expect(find.text('Tareas'), findsOneWidget);
      expect(find.text('Revisión contrato cliente A'), findsOneWidget);
      expect(find.text('Revisar cláusulas del contrato'), findsOneWidget);

      await tester.tap(find.byKey(const Key('tareaItem_99')));
      await tester.pumpAndSettle();

      expect(find.text('Detalle de tarea'), findsOneWidget);
      expect(find.text('Revisión contrato cliente A'), findsWidgets);
      expect(find.text('Revisar cláusulas del contrato'), findsOneWidget);
      expect(find.text('Onboarding cliente A'), findsWidgets);
      expect(find.text('Sebastian Mardones'), findsOneWidget);
      expect(find.text('2026-06-30'), findsWidgets);
      expect(find.text('Activo'), findsWidgets);
    },
  );
}
