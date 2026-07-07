import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants.dart';
import '../models/proceso_model.dart';

class ProcesoService {
  final String? token;

  ProcesoService({this.token});

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

  final String _base = '${AppConstants.baseUrl}/procesos';

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

  Future<List<ProcesoModel>> getAll() async {
    final response = await _dio.get(_base, options: _authOptions);

    if (response.statusCode != 200) {
      throw Exception(_extraerError(response.data, response.statusCode));
    }

    final decoded = jsonDecode(response.data.toString());
    return (decoded as List).map((e) => ProcesoModel.fromJson(e)).toList();
  }

  Future<List<ProcesoModel>> getByOrganizacion(int idOrganizacion) async {
    final response = await _dio.get(
      '$_base/organizacion/$idOrganizacion',
      options: _authOptions,
    );

    if (response.statusCode != 200) {
      throw Exception(_extraerError(response.data, response.statusCode));
    }

    final decoded = jsonDecode(response.data.toString());
    return (decoded as List).map((e) => ProcesoModel.fromJson(e)).toList();
  }

  Future<ProcesoModel> create(ProcesoModel proceso) async {
    final response = await _dio.post(
      _base,
      data: jsonEncode(proceso.toJson()),
      options: _authJsonOptions,
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception(_extraerError(response.data, response.statusCode));
    }

    return ProcesoModel.fromJson(jsonDecode(response.data.toString()));
  }

  Future<ProcesoModel> update(int id, ProcesoModel proceso) async {
    final response = await _dio.put(
      '$_base/$id',
      data: jsonEncode(proceso.toJson()),
      options: _authJsonOptions,
    );

    if (response.statusCode != 200) {
      throw Exception(_extraerError(response.data, response.statusCode));
    }

    return ProcesoModel.fromJson(jsonDecode(response.data.toString()));
  }

  Future<ProcesoModel> updateEstado(int idProceso, int idEstado) async {
    final response = await _dio.put(
      '$_base/$idProceso/estado',
      data: jsonEncode({'idEstado': idEstado}),
      options: _authJsonOptions,
    );

    if (response.statusCode != 200) {
      throw Exception(_extraerError(response.data, response.statusCode));
    }

    return ProcesoModel.fromJson(jsonDecode(response.data.toString()));
  }

  Future<void> delete(int id) async {
    final response = await _dio.delete('$_base/$id', options: _authOptions);

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception(_extraerError(response.data, response.statusCode));
    }
  }
}
