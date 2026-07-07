import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';
import 'package:process_sa/core/constants.dart';

class ReporteService {
  final Dio dio;

  ReporteService(String? token)
    : dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.baseUrl,
          headers: {
            if (token != null) 'Authorization': 'Bearer $token',
            'Accept': 'application/pdf', // Indicamos que esperamos un PDF
          },
          responseType: ResponseType.bytes,
        ),
      ) {
    // Interceptor para depurar errores en consola
    dio.interceptors.add(
      LogInterceptor(
        requestBody: true,
        responseBody: false, // PDF en bytes es muy largo, no lo imprimas
        error: true,
      ),
    );
  }

  // En ReporteService.dart

  Future<void> descargarReporteOrganizacion(int idOrganizacion) async {
    try {
      // Cambia esto: '/api/reportes/...'
      // Por esto: '/reportes/...'
      final response = await dio.get(
        '/reportes/tareas/pdf/organizacion/$idOrganizacion',
      );
      await _guardarYAbrirPdf(response.data, 'reporte_general_tareas.pdf');
    } on DioException catch (e) {
      _manejarError(e);
    }
  }

  Future<void> descargarReporteUsuario(int idUsuario) async {
    try {
      // Cambia esto: '/api/reportes/...'
      // Por esto: '/reportes/...'
      final response = await dio.get('/reportes/tareas/pdf/usuario/$idUsuario');
      await _guardarYAbrirPdf(response.data, 'reporte_mis_tareas.pdf');
    } on DioException catch (e) {
      _manejarError(e);
    }
  }

  Future<void> _guardarYAbrirPdf(List<int> bytes, String nombreArchivo) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$nombreArchivo');

    await file.writeAsBytes(bytes, flush: true);
    await OpenFilex.open(file.path);
  }

  void _manejarError(DioException e) {
    if (e.response != null) {
      print(
        "Error de servidor: ${e.response?.statusCode} - ${e.response?.data}",
      );
      throw Exception('Error del servidor: ${e.response?.statusCode}');
    } else {
      print("Error de red: ${e.message}");
      throw Exception('Error de conexión');
    }
  }
}
