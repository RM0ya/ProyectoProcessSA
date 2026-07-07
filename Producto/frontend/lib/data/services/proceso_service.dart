import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants.dart';
import '../models/proceso_model.dart';

class ProcesoService {
  final Dio _dio = Dio(
    BaseOptions(
      responseType: ResponseType.plain,
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  final String _base = '${AppConstants.baseUrl}/procesos';

  Future<List<ProcesoModel>> getAll() async {
    final response = await _dio.get(_base);

    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode}: ${response.data}');
    }

    final decoded = jsonDecode(response.data.toString());

    return (decoded as List)
        .map((e) => ProcesoModel.fromJson(e))
        .toList();
  }

  Future<ProcesoModel> create(ProcesoModel proceso) async {
    final response = await _dio.post(
      _base,
      data: jsonEncode(proceso.toJson()),
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    if (response.statusCode != 200 && response.statusCode != 201) {
      throw Exception('Error ${response.statusCode}: ${response.data}');
    }

    return ProcesoModel.fromJson(jsonDecode(response.data.toString()));
  }

  Future<ProcesoModel> update(int id, ProcesoModel proceso) async {
    final response = await _dio.put(
      '$_base/$id',
      data: jsonEncode(proceso.toJson()),
      options: Options(headers: {'Content-Type': 'application/json'}),
    );

    if (response.statusCode != 200) {
      throw Exception('Error ${response.statusCode}: ${response.data}');
    }

    return ProcesoModel.fromJson(jsonDecode(response.data.toString()));
  }

  Future<void> delete(int id) async {
    final response = await _dio.delete('$_base/$id');

    if (response.statusCode != 200 && response.statusCode != 204) {
      throw Exception('Error al eliminar proceso: ${response.statusCode}');
    }
  }
}