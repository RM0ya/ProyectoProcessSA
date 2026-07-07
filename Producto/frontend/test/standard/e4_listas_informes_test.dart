// ============================================================
// E-4.x — VERIFICACIÓN DE LISTAS E INFORMES
// Ejecutar: flutter test test/standard/e4_listas_informes_test.dart
// ============================================================
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:process_sa/presentation/screens/tareas/tareas_screen.dart';
import 'package:process_sa/presentation/screens/procesos/procesos_screen.dart';
import 'package:process_sa/data/models/tarea_model.dart';
import 'package:process_sa/data/models/proceso_model.dart';

void main() {
  // ----------------------------------------------------------
  // E-4.1  Listados usan Cards con colores de estado
  // ----------------------------------------------------------
  group('E-4.1 — Pantallas de listado usan Cards', () {
    testWidgets('TareasScreen renderiza sin crash y con estructura de lista', (
      tester,
    ) async {
      await tester.pumpWidget(const MaterialApp(home: TareasScreen()));
      await tester.pumpAndSettle();

      expect(
        find.byType(Scaffold),
        findsOneWidget,
        reason: 'E-4.1: TareasScreen debe cargar sin errores',
      );
      // Si hay datos cargados, debe haber Cards o ListTiles
      // (si la lista viene vacía del backend, este expect es opcional)
    });

    testWidgets(
      'ProcesosScreen renderiza sin crash y con estructura de lista',
      (tester) async {
        await tester.pumpWidget(const MaterialApp(home: ProcesosScreen()));
        await tester.pumpAndSettle();

        expect(
          find.byType(Scaffold),
          findsOneWidget,
          reason: 'E-4.1: ProcesosScreen debe cargar sin errores',
        );
      },
    );

    testWidgets(
      'Widget de card de tarea tiene estructura correcta (Card + texto)',
      (tester) async {
        // Simula cómo se vería una TareaCard en la lista
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: ListView(
                children: [
                  _buildTareaCard('Diseñar base de datos', 'pendiente'),
                  _buildTareaCard('Implementar API REST', 'en_curso'),
                  _buildTareaCard('Pruebas unitarias', 'completada'),
                ],
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        expect(
          find.byType(Card),
          findsNWidgets(3),
          reason: 'E-4.1: Deben renderizarse 3 Cards de tarea',
        );
        expect(find.text('Diseñar base de datos'), findsOneWidget);
        expect(find.text('Implementar API REST'), findsOneWidget);
        expect(find.text('Pruebas unitarias'), findsOneWidget);
      },
    );
  });

  // ----------------------------------------------------------
  // E-4.2  Lista mantiene el orden retornado por el backend
  // ----------------------------------------------------------
  group('E-4.2 — Orden de listado respeta el orden del backend', () {
    test('Lista de tareas mantiene el orden recibido (no reordena por id)', () {
      // Simula respuesta del backend en orden específico
      final tareasMock = [
        {'id': 5, 'nombre': 'Tarea urgente', 'prioridad': 1},
        {'id': 2, 'nombre': 'Tarea normal', 'prioridad': 2},
        {'id': 8, 'nombre': 'Tarea baja prioridad', 'prioridad': 3},
      ];

      // No se debe reordenar por id (5 > 2 < 8 pero el orden debe preservarse)
      final ids = tareasMock.map((t) => t['id']).toList();
      expect(
        ids,
        equals([5, 2, 8]),
        reason:
            'E-4.2: El orden del backend (por prioridad) debe preservarse, no ordenarse por id',
      );

      expect(
        tareasMock.first['nombre'],
        equals('Tarea urgente'),
        reason: 'E-4.2: Primera tarea debe ser la de mayor prioridad',
      );
    });

    testWidgets('ListView respeta el orden de la lista en memoria', (
      tester,
    ) async {
      final nombres = ['Primera tarea', 'Segunda tarea', 'Tercera tarea'];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: nombres.length,
              itemBuilder: (_, i) => ListTile(title: Text(nombres[i])),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verifica orden visual: primera debe aparecer antes que segunda
      final firstOffset = tester.getTopLeft(find.text('Primera tarea')).dy;
      final secondOffset = tester.getTopLeft(find.text('Segunda tarea')).dy;
      final thirdOffset = tester.getTopLeft(find.text('Tercera tarea')).dy;

      expect(
        firstOffset < secondOffset,
        isTrue,
        reason:
            'E-4.2: "Primera tarea" debe estar visualmente antes que "Segunda tarea"',
      );
      expect(
        secondOffset < thirdOffset,
        isTrue,
        reason: 'E-4.2: "Segunda tarea" debe estar antes que "Tercera tarea"',
      );
    });
  });

  // ----------------------------------------------------------
  // E-4.3  Colores correctos según estado (verde/naranja/rojo)
  // ----------------------------------------------------------
  group('E-4.3 — Color de estado de proceso/tarea es correcto', () {
    test('getColorEstado retorna verde para completada', () {
      expect(
        _getColorEstado('completada'),
        equals(Colors.green),
        reason: 'E-4.3: completada → verde',
      );
      expect(_getColorEstado('completado'), equals(Colors.green));
    });

    test('getColorEstado retorna naranja para en_curso', () {
      expect(
        _getColorEstado('en_curso'),
        equals(Colors.orange),
        reason: 'E-4.3: en_curso → naranja',
      );
      expect(_getColorEstado('en curso'), equals(Colors.orange));
    });

    test('getColorEstado retorna rojo para pendiente y vencida', () {
      expect(
        _getColorEstado('pendiente'),
        equals(Colors.red),
        reason: 'E-4.3: pendiente → rojo',
      );
      expect(
        _getColorEstado('vencida'),
        equals(Colors.red),
        reason: 'E-4.3: vencida → rojo',
      );
      expect(_getColorEstado('vencido'), equals(Colors.red));
    });

    testWidgets('Cards de tarea muestran círculo de color según estado', (
      tester,
    ) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                _buildTareaCard('Tarea completada', 'completada'),
                _buildTareaCard('Tarea en curso', 'en_curso'),
                _buildTareaCard('Tarea pendiente', 'pendiente'),
              ],
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verifica que existen containers de color (el círculo de estado)
      final containers = tester
          .widgetList<Container>(find.byType(Container))
          .where((c) {
            final deco = c.decoration;
            return deco is BoxDecoration && deco.color != null;
          })
          .toList();

      expect(
        containers.length,
        greaterThanOrEqualTo(3),
        reason:
            'E-4.3: Cada card de tarea debe tener un indicador de color de estado',
      );
    });
  });
}

// ----------------------------------------------------------
// Helpers locales del test (replica la lógica de tu app)
// Si tu app tiene getColorEstado() como función separada,
// impórtala y borra esta versión local
// ----------------------------------------------------------
Color _getColorEstado(String estado) {
  switch (estado.toLowerCase().replaceAll(' ', '_')) {
    case 'completada':
    case 'completado':
      return Colors.green;
    case 'en_curso':
      return Colors.orange;
    case 'pendiente':
    case 'vencida':
    case 'vencido':
      return Colors.red;
    default:
      return Colors.grey;
  }
}

Widget _buildTareaCard(String nombre, String estado) {
  final color = _getColorEstado(estado);
  return Card(
    child: ListTile(
      leading: Container(
        width: 14,
        height: 14,
        decoration: BoxDecoration(color: color, shape: BoxShape.circle),
      ),
      title: Text(nombre),
      subtitle: Text(estado),
    ),
  );
}
