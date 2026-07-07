import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants.dart';
import '../models/tarea_model.dart';

class TareaService {
  final String? token;

  TareaService({this.token});

  final Dio _dio = Dio(
    BaseOptions(
      responseType: ResponseType.plain,
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  Options get _authOptions =>
      Options(headers: {if (token != null) 'Authorization': 'Bearer $token'});

  Options get _authJsonOptions => Options(
    headers: {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    },
  );

  final String _base = '${AppConstants.baseUrl}/tareas';

  // Extrae el mensaje real de error que arma el backend (viene como
  // {"error": "..."} en el body), en vez de mostrar el status crudo.
  String _extraerError(dynamic data, int? statusCode) {
    try {
      final decoded = jsonDecode(data.toString());
      if (decoded is Map && decoded['error'] != null) {
        return decoded['error'].toString();
      }
    } catch (_) {
      // El body no era JSON válido, se usa el mensaje genérico de abajo.
    }
    return 'Error ${statusCode ?? ''}';
  }

  Future<List<TareaModel>> getAll() async {
    final response = await _dio.get(_base, options: _authOptions);

    if (response.statusCode != 200) {
      throw Exception(_extraerError(response.data, response.statusCode));
    }

    final decoded = jsonDecode(response.data.toString());
    return (decoded as List).map((e) => TareaModel.fromJson(e)).toList();
  }

  Future<List<TareaModel>> getByUsuario(int idUsuario) async {
    final response = await _dio.get(
      '$_base/usuario/$idUsuario',
      options: _authOptions,
    );

    if (response.statusCode != 200) {
      throw Exception(_extraerError(response.data, response.statusCode));
    }

    final decoded = jsonDecode(response.data.toString());
    return (decoded as List).map((e) => TareaModel.fromJson(e)).toList();
  }

  Future<List<TareaModel>> getByOrganizacion(int idOrganizacion) async {
    final response = await _dio.get(
      '$_base/organizacion/$idOrganizacion',
      options: _authOptions,
    );

    if (response.statusCode != 200) {
      throw Exception(_extraerError(response.data, response.statusCode));
    }

    final decoded = jsonDecode(response.data.toString());
    return (decoded as List).map((e) => TareaModel.fromJson(e)).toList();
  }

  Future<TareaModel> create(TareaModel tarea) async {
    final response = await _dio.post(
      _base,
      data: jsonEncode(tarea.toJson()),
      options: _authJsonOptions,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_extraerError(response.data, response.statusCode));
    }

    final decoded = jsonDecode(response.data.toString());
    return TareaModel.fromJson(decoded);
  }

  Future<TareaModel> update(int id, TareaModel tarea) async {
    final response = await _dio.put(
      '$_base/$id',
      data: jsonEncode(tarea.toJson()),
      options: _authJsonOptions,
    );

    if (response.statusCode != 200) {
      throw Exception(_extraerError(response.data, response.statusCode));
    }

    final decoded = jsonDecode(response.data.toString());
    return TareaModel.fromJson(decoded);
  }

  Future<void> delete(int id) async {
    final response = await _dio.delete('$_base/$id', options: _authOptions);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_extraerError(response.data, response.statusCode));
    }
  }
}