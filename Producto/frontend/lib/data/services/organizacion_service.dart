import 'package:dio/dio.dart';
import '../../core/constants.dart';

class OrganizacionService {
  final Dio _dio = Dio();
  final String _base = '${AppConstants.baseUrl}/organizaciones';

  String? _token;
  void setToken(String token) => _token = token;

  Options get _authOptions =>
      Options(headers: {if (_token != null) 'Authorization': 'Bearer $_token'});

  Future<List<Map<String, dynamic>>> getAll() async {
    final response = await _dio.get(_base, options: _authOptions);
    return (response.data as List).cast<Map<String, dynamic>>();
  }
}