import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants.dart';
import '../models/tarea_model.dart';

class TareaService {
  final Dio _dio = Dio(
    BaseOptions(
      responseType: ResponseType.plain,
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  final String _base = '${AppConstants.baseUrl}/tareas';

  Future<List<TareaModel>> getAll() async {
    final response = await _dio.get(_base);

    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode}: ${response.data}');
    }

    final decoded = jsonDecode(response.data.toString());

    return (decoded as List).map((e) => TareaModel.fromJson(e)).toList();
  }

  Future<List<TareaModel>> getByUsuario(int idUsuario) async {
    final response = await _dio.get('$_base/usuario/$idUsuario');

    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode}: ${response.data}');
    }

    final decoded = jsonDecode(response.data.toString());

    return (decoded as List).map((e) => TareaModel.fromJson(e)).toList();
  }

  Future<TareaModel> create(TareaModel tarea) async {
    final response = await _dio.post(
      _base,
      data: jsonEncode(tarea.toJson()),
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error ${response.statusCode}: ${response.data}');
    }

    final decoded = jsonDecode(response.data.toString());
    return TareaModel.fromJson(decoded);
  }

  Future<TareaModel> update(int id, TareaModel tarea) async {
    final response = await _dio.put(
      '$_base/$id',
      data: jsonEncode(tarea.toJson()),
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode}: ${response.data}');
    }

    final decoded = jsonDecode(response.data.toString());
    return TareaModel.fromJson(decoded);
  }

  Future<void> delete(int id) async {
    final response = await _dio.delete('$_base/$id');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar: ${response.statusCode}');
    }
  }
}
