import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:process_sa/core/constants.dart';
import '../models/tarea_model.dart';

class TareaProvider extends ChangeNotifier {
  List<TareaModel> tareas = [];
  bool isLoading = false;
  String? error;

  Dio _dio(String? token) {
    return Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ),
    );
  }

  Future<void> cargarTareas({
    required bool esAdmin,
    required int? idUsuario,
    required int? idOrganizacion,
    required String? token,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final path = esAdmin
          ? '/tareas/organizacion/$idOrganizacion'
          : '/tareas/usuario/$idUsuario';
      final response = await _dio(token).get(path);

      tareas = (response.data as List)
          .map((e) => TareaModel.fromJson(e))
          .toList();

      error = null;
    } catch (e) {
      print('ERROR CARGAR TAREAS: $e');
      error = 'Error al cargar tareas';
    }

    isLoading = false;
    notifyListeners();
  }

  int get totalTareas => tareas.length;

  int get tareasActivas =>
      tareas.where((t) => t.nombreEstado == 'Activo').length;

  int get tareasCompletadas =>
      tareas.where((t) => t.nombreEstado == 'Completada').length;

  int get cumplimientoPorcentaje {
    if (totalTareas == 0) return 0;
    return ((tareasCompletadas / totalTareas) * 100).round();
  }

  DateTime? _parseFecha(String? fecha) {
    if (fecha == null || fecha.isEmpty) return null;
    return DateTime.tryParse(fecha);
  }

  List<TareaModel> get tareasRecientes {
    final ordenadas = [...tareas]
      ..sort((a, b) {
        final fechaA = _parseFecha(a.fechaCreacionT) ?? DateTime(2000);
        final fechaB = _parseFecha(b.fechaCreacionT) ?? DateTime(2000);
        return fechaB.compareTo(fechaA);
      });
    return ordenadas.take(3).toList();
  }
}
