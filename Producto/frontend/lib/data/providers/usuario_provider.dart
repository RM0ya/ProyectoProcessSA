import 'package:flutter/material.dart';
import 'package:dio/dio.dart';

import '../models/usuario_model.dart';
import '../services/usuario_service.dart';

class UsuarioProvider extends ChangeNotifier {
  final UsuarioService _service = UsuarioService();

  List<UsuarioModel> usuarios = [];
  bool isLoading = false;
  String? error;

  UsuarioModel? _usuarioLogueado;

  UsuarioModel? get usuarioLogueado => _usuarioLogueado;

  set usuarioLogueado(UsuarioModel? u) {
    _usuarioLogueado = u;
    notifyListeners();
  }

  String? get token => _service.token;

  bool get esAdmin =>
      _usuarioLogueado?.rol?['nombre']?.toString().toLowerCase() == 'admin';

  Dio _dioSesion() {
    return Dio(
      BaseOptions(
        baseUrl: 'http://10.0.2.2:8080/api',
        headers: {
          if (_service.token != null)
            'Authorization': 'Bearer ${_service.token}',
        },
      ),
    );
  }

  Future<void> _registrarInicioSesion() async {
    try {
      if (_usuarioLogueado?.idUsuario == null || _service.token == null) return;

      await _dioSesion().post(
        '/sesiones/iniciar',
        data: {
          'idUsuario': _usuarioLogueado!.idUsuario,
          'token': _service.token,
        },
      );

      print('SESION INICIADA REGISTRADA');
    } catch (e) {
      print('ERROR REGISTRAR INICIO SESION: $e');
    }
  }

  Future<void> _registrarCierreSesion() async {
    try {
      if (_usuarioLogueado?.idUsuario == null) return;

      await _dioSesion().post(
        '/sesiones/cerrar',
        data: {'idUsuario': _usuarioLogueado!.idUsuario},
      );

      print('SESION CERRADA REGISTRADA');
    } catch (e) {
      print('ERROR REGISTRAR CIERRE SESION: $e');
    }
  }

  Future<void> cargarUsuarios() async {
    isLoading = true;
    notifyListeners();

    try {
      usuarios = await _service.getAll();
      error = null;
    } catch (e) {
      error = 'Error al cargar usuarios';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await _service.login(email, password);
      print('RESPUESTA LOGIN: $data');

      if (data != null && data['usuario'] != null) {
        _usuarioLogueado = UsuarioModel.fromJson(data['usuario']);

        // sin await — fire and forget, no bloquea la navegación
        _registrarInicioSesion();

        print('ROL USUARIO: ${_usuarioLogueado?.rol}');
        print('ES ADMIN: $esAdmin');

        error = null;
        isLoading = false;
        notifyListeners();
        return true;
      }

      error = 'Credenciales incorrectas';
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('ERROR LOGIN: $e');
      error = 'Error al iniciar sesión';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginConGoogle(String idToken) async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await _service.loginGoogle(idToken);

      if (data != null && data['usuario'] != null) {
        _usuarioLogueado = UsuarioModel.fromJson(data['usuario']);

        // sin await — fire and forget, no bloquea la navegación
        _registrarInicioSesion();

        print('ROL GOOGLE: ${_usuarioLogueado?.rol}');
        print('ES ADMIN GOOGLE: $esAdmin');

        error = null;
        isLoading = false;
        notifyListeners();
        return true;
      }

      error = 'No se pudo iniciar sesión con Google';
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('ERROR LOGIN GOOGLE: $e');
      error = 'Error al iniciar sesión con Google';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> registrar({
    required String nombre,
    required String apellido,
    required String email,
    required String password,
    String? telefono,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final nuevoUsuario = UsuarioModel(
        idUsuario: null,
        nombre: nombre,
        apellidoP: apellido,
        apellidoM: null,
        emailUsuario: email,
        password: password,
        telefono: telefono,
        intentosFallidos: 0,
        bloqueado: 'N',
        ultimoLogin: DateTime.now().toIso8601String(),
        fechaCreacion: DateTime.now().toIso8601String().substring(0, 10),
        rol: {'idRol': 2},
        organizacion: {'idOrganizacion': 1},
      );

      await _service.create(nuevoUsuario);

      error = null;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('ERROR REGISTRO: $e');
      error = 'Error al registrar usuario: $e';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> crearUsuario(UsuarioModel usuario) async {
    isLoading = true;
    notifyListeners();

    try {
      final nuevo = await _service.create(usuario);
      usuarios.add(nuevo);

      error = null;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = 'Error al crear usuario';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarUsuario(int id, UsuarioModel usuario) async {
    isLoading = true;
    notifyListeners();

    try {
      final actualizado = await _service.update(id, usuario);
      final idx = usuarios.indexWhere((u) => u.idUsuario == id);

      if (idx != -1) usuarios[idx] = actualizado;

      if (_usuarioLogueado?.idUsuario == id) {
        _usuarioLogueado = actualizado;
      }

      error = null;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      error = 'Error al actualizar usuario';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarUsuario(int id) async {
    isLoading = true;
    notifyListeners();

    try {
      await _service.delete(id);
      usuarios.removeWhere((u) => u.idUsuario == id);

      error = null;
      isLoading = false;
      notifyListeners();
      return true;
    } on DioException catch (e) {
      print('ERROR ELIMINAR STATUS: ${e.response?.statusCode}');
      print('ERROR ELIMINAR BODY: ${e.response?.data}');

      error = 'Error al eliminar usuario';
      isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      print('ERROR ELIMINAR GENERAL: $e');

      error = 'Error al eliminar usuario';
      isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> cerrarSesion() async {
    await _registrarCierreSesion();

    _service.clearToken();
    _usuarioLogueado = null;
    usuarios = [];
    notifyListeners();
  }
}
