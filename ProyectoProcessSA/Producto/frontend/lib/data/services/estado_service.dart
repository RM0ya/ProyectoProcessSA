import 'dart:convert';
import 'package:dio/dio.dart';
import '../../core/constants.dart';
import '../models/estado_model.dart';

class EstadoService {
  final String? token;

  EstadoService({this.token});

  final Dio _dio = Dio(
    BaseOptions(
      responseType: ResponseType.plain,
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  Options get _authOptions =>
      Options(headers: {if (token != null) 'Authorization': 'Bearer $token'});

  final String _base = '${AppConstants.baseUrl}/estados';

  Future<List<EstadoModel>> getAll() async {
    final response = await _dio.get(_base, options: _authOptions);

    if (response.statusCode != 200) {
      throw Exception('Error al cargar estados');
    }

    final decoded = jsonDecode(response.data.toString());
    return (decoded as List).map((e) => EstadoModel.fromJson(e)).toList();
  }
}
