import 'package:dio/dio.dart';
import '../models/usuario_model.dart';
import '../../core/constants.dart';

class UsuarioService {
  final Dio _dio = Dio();
  final String _base = '${AppConstants.baseUrl}/usuarios';

  // Token JWT  sirve para guardado en memoria
  String? _token;

  String? get token => _token;

  Options get _authOptions =>
      Options(headers: {if (_token != null) 'Authorization': 'Bearer $_token'});


  Future<List<UsuarioModel>> getAll() async {
    final response = await _dio.get(_base, options: _authOptions);
    return (response.data as List)
        .map((e) => UsuarioModel.fromJson(e))
        .toList();
  }


  Future<UsuarioModel> getById(int id) async {
    final response = await _dio.get('$_base/$id', options: _authOptions);
    return UsuarioModel.fromJson(response.data);
  }

  Future<Map<String, dynamic>?> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '$_base/login',
        data: {'emailUsuario': email, 'password': password},
      );
      final data = response.data as Map<String, dynamic>;
      _token = data['token'];
      return data;
    } on DioException catch (e) {
      print('ERROR DIO LOGIN: ${e.response?.statusCode}');
      print('ERROR DIO BODY: ${e.response?.data}');
      return null;
    }
  }

  // Verifica idToken en el backend para google
  Future<Map<String, dynamic>?> loginGoogle(String idToken) async {
    try {
      final response = await _dio.post(
        '$_base/login-google',
        data: {'idToken': idToken},
      );
      final data = response.data as Map<String, dynamic>;
      _token = data['token'];
      return data;
    } on DioException {
      return null;
    }
  }


  Future<UsuarioModel> create(UsuarioModel usuario) async {
    final response = await _dio.post(
      '$_base/crear',
      data: usuario.toJson(),
      options: _authOptions,
    );
    return UsuarioModel.fromJson(response.data);
  }


  Future<UsuarioModel> update(int id, UsuarioModel usuario) async {
    final response = await _dio.put(
      '$_base/$id',
      data: usuario.toJson(),
      options: _authOptions,
    );
    return UsuarioModel.fromJson(response.data);
  }


  Future<void> delete(int id) async {
    await _dio.delete('$_base/$id', options: _authOptions);
  }


  void clearToken() {
    _token = null;
  }
}
