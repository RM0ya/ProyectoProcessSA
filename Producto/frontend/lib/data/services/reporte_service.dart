import 'dart:io';
import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
import 'package:open_filex/open_filex.dart';

class ReporteService {
  final Dio dio;

  ReporteService(String? token)
    : dio = Dio(
        BaseOptions(
          baseUrl: 'http://10.0.2.2:8080/api',
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
          responseType: ResponseType.bytes,
        ),
      );

  Future<void> descargarReporteOrganizacion(int idOrganizacion) async {
    final response = await dio.get(
      '/reportes/tareas/pdf/organizacion/$idOrganizacion',
    );

    await _guardarYAbrirPdf(response.data, 'reporte_general_tareas.pdf');
  }

  Future<void> descargarReporteUsuario(int idUsuario) async {
    final response = await dio.get('/reportes/tareas/pdf/usuario/$idUsuario');

    await _guardarYAbrirPdf(response.data, 'reporte_mis_tareas.pdf');
  }

  Future<void> _guardarYAbrirPdf(List<int> bytes, String nombreArchivo) async {
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/$nombreArchivo');

    await file.writeAsBytes(bytes, flush: true);
    await OpenFilex.open(file.path);
  }
}
