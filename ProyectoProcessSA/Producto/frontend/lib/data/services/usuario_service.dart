import 'package:dio/dio.dart';
import '../models/usuario_model.dart';
import '../../core/constants.dart';

class UsuarioService {
  final Dio _dio = Dio(
    BaseOptions(
      // Configuración global para asegurar que las peticiones se traten como JSON
      contentType: Headers.jsonContentType,
      validateStatus: (status) => status != null && status < 500,
    ),
  );

  final String _base = '${AppConstants.baseUrl}/usuarios';

  // Token JWT
  String? _token;
  String? get token => _token;

  void setToken(String token) {
    _token = token;
  }

  void clearToken() {
    _token = null;
  }

  // Generador de opciones de autenticación dinámico
  Options get _authOptions => Options(
    headers: {
      if (_token != null) 'Authorization': 'Bearer $_token',
      'Accept': 'application/json',
    },
  );

  Future<List<UsuarioModel>> getAll() async {
    final response = await _dio.get(_base, options: _authOptions);
    if (response.statusCode == 200) {
      return (response.data as List)
          .map((e) => UsuarioModel.fromJson(e))
          .toList();
    }
    throw Exception('Error al obtener usuarios: ${response.statusCode}');
  }

  Future<List<UsuarioModel>> getByOrganizacion(int idOrganizacion) async {
    final response = await _dio.get(
      '$_base/organizacion/$idOrganizacion',
      options: _authOptions,
    );
    if (response.statusCode == 200) {
      return (response.data as List)
          .map((e) => UsuarioModel.fromJson(e))
          .toList();
    }
    throw Exception('Error al obtener usuarios por organización');
  }

  // Usuarios sin organización asignada
  Future<List<UsuarioModel>> getPendientes() async {
    final response = await _dio.get('$_base/pendientes', options: _authOptions);
    if (response.statusCode == 200) {
      return (response.data as List)
          .map((e) => UsuarioModel.fromJson(e))
          .toList();
    }
    throw Exception('Error al obtener usuarios pendientes');
  }

  // Asignar organización a un usuario (usado por el superadmin)
  Future<UsuarioModel> asignarOrganizacion(
    int idUsuario,
    int idOrganizacion,
  ) async {
    final response = await _dio.put(
      '$_base/$idUsuario/asignar-organizacion',
      data: {'idOrganizacion': idOrganizacion},
      options: _authOptions,
    );
    if (response.statusCode == 200) {
      return UsuarioModel.fromJson(response.data);
    }
    throw Exception('Error al asignar organización');
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

      print('STATUS LOGIN: ${response.statusCode}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['token'] != null) {
          _token = data['token'];
        }
        return data;
      }
      return null;
    } on DioException catch (e) {
      print('ERROR DIO LOGIN: ${e.message}');
      return null;
    }
  }

  Future<Map<String, dynamic>?> loginGoogle(String idToken) async {
    try {
      final response = await _dio.post(
        '$_base/login-google',
        data: {'idToken': idToken},
      );

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data as Map<String, dynamic>;
        if (data['token'] != null) {
          _token = data['token'];
        }
        return data;
      }
      return null;
    } on DioException catch (e) {
      print('ERROR GOOGLE LOGIN: ${e.message}');
      return null;
    }
  }

  // Registro público (sin autenticación) — usado desde RegistroScreen.
  // El backend siempre fuerza organizacion = null en este endpoint,
  // sin importar lo que se envíe.
  Future<UsuarioModel> create(UsuarioModel usuario) async {
    final response = await _dio.post(
      '$_base/crear',
      data: usuario.toJson(),
      options: _authOptions,
    );
    return UsuarioModel.fromJson(response.data);
  }

  // Creación por Admin/SuperAdmin desde el panel — usado desde
  // AdminScreen. A diferencia de create(), este endpoint SÍ respeta
  // el rol, organización y departamento seleccionados en el formulario.
  Future<UsuarioModel> createByStaff(UsuarioModel usuario) async {
    final response = await _dio.post(
      '$_base/crear-staff',
      data: usuario.toJson(),
      options: _authOptions,
    );
    if (response.statusCode == 200) {
      return UsuarioModel.fromJson(response.data);
    }
    throw Exception('Error al crear usuario: ${response.data}');
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
}
