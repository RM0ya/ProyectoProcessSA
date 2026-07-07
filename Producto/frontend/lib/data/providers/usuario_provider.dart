import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import '../models/usuario_model.dart';
import '../services/usuario_service.dart';

import 'package:process_sa/core/constants.dart';

class UsuarioProvider extends ChangeNotifier {
  final UsuarioService _service = UsuarioService();

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  List<UsuarioModel> usuarios = [];
  List<UsuarioModel> pendientes = [];
  bool isLoading = false;
  String? error;

  UsuarioModel? _usuarioLogueado;

  late final Future<void> inicializado;

  UsuarioProvider() {
    inicializado = _cargarTokenInicial();
  }

  Future<void> _cargarTokenInicial() async {
    final token = await _storage.read(key: 'jwt_token');
    final usuarioJson = await _storage.read(key: 'usuario_data');

    if (token != null) {
      _service.setToken(token);
    }

    if (usuarioJson != null) {
      try {
        _usuarioLogueado = UsuarioModel.fromJson(jsonDecode(usuarioJson));
      } catch (e) {
        print('ERROR AL RESTAURAR USUARIO: $e');
        await _storage.delete(key: 'usuario_data');
      }
    }

    if (token != null || usuarioJson != null) {
      notifyListeners();
    }
  }

  UsuarioModel? get usuarioLogueado => _usuarioLogueado;

  set usuarioLogueado(UsuarioModel? u) {
    _usuarioLogueado = u;
    notifyListeners();
  }

  String? get token => _service.token;

  bool get esAdmin =>
      _usuarioLogueado?.rol?['nombre']?.toString().toLowerCase() == 'admin';

  bool get esSuperAdmin =>
      _usuarioLogueado?.rol?['nombre']?.toString().toLowerCase() ==
      'superadmin';

  Dio _dioSesion() {
    return Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        headers: {
          if (_service.token != null)
            'Authorization': 'Bearer ${_service.token}',
        },
      ),
    );
  }

  Future<void> _registrarInicioSesion() async {
    try {
      if (_usuarioLogueado?.idUsuario == null || _service.token == null) {
        return;
      }

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
      final idOrganizacion =
          _usuarioLogueado?.organizacion?['idOrganizacion'] as int?;

      if (esSuperAdmin || idOrganizacion == null) {
        usuarios = await _service.getAll();
      } else {
        usuarios = await _service.getByOrganizacion(idOrganizacion);
      }

      error = null;
    } catch (e) {
      error = 'Error al cargar usuarios';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> cargarPendientes() async {
    isLoading = true;
    notifyListeners();

    try {
      pendientes = await _service.getPendientes();
      error = null;
    } catch (e) {
      error = 'Error al cargar usuarios pendientes';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<bool> asignarOrganizacion(int idUsuario, int idOrganizacion) async {
    try {
      final actualizado = await _service.asignarOrganizacion(
        idUsuario,
        idOrganizacion,
      );

      pendientes.removeWhere((u) => u.idUsuario == idUsuario);

      final idx = usuarios.indexWhere((u) => u.idUsuario == idUsuario);
      if (idx != -1) {
        usuarios[idx] = actualizado;
      }

      error = null;
      notifyListeners();
      return true;
    } catch (e) {
      print('ERROR ASIGNAR ORGANIZACION: $e');
      error = 'Error al asignar organización';
      notifyListeners();
      return false;
    }
  }

  Future<bool> login(String email, String password) async {
    isLoading = true;
    notifyListeners();

    try {
      final data = await _service.login(email, password);
      print('RESPUESTA LOGIN: $data');

      if (data != null && data['usuario'] != null && data['token'] != null) {
        _usuarioLogueado = UsuarioModel.fromJson(data['usuario']);

        await _storage.write(key: 'jwt_token', value: data['token']);
        await _storage.write(
          key: 'usuario_data',
          value: jsonEncode(data['usuario']),
        );

        _service.setToken(data['token']);

        await _registrarInicioSesion();

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

      if (data != null && data['usuario'] != null && data['token'] != null) {
        _usuarioLogueado = UsuarioModel.fromJson(data['usuario']);

        await _storage.write(key: 'jwt_token', value: data['token']);
        await _storage.write(
          key: 'usuario_data',
          value: jsonEncode(data['usuario']),
        );

        _service.setToken(data['token']);

        await _registrarInicioSesion();

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
        organizacion: null,
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
      final nuevo = await _service.createByStaff(usuario);

      usuarios.add(nuevo);

      error = null;
      isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      print('ERROR REGISTRO: $e');

      if (e is DioException) {
        final status = e.response?.statusCode;
        final data = e.response?.data;

        if (status == 409 ||
            (data is Map &&
                data['error']?.toString().toLowerCase().contains('correo') ==
                    true) ||
            (data is Map &&
                data['error']?.toString().toLowerCase().contains('email') ==
                    true)) {
          error = 'Este correo ya está registrado';
        } else if (status == 400) {
          error = 'Los datos ingresados no son válidos';
        } else {
          error = 'Error al registrar usuario';
        }
      } else {
        error = 'Error al registrar usuario';
      }

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

      if (idx != -1) {
        usuarios[idx] = actualizado;
      }

      if (_usuarioLogueado?.idUsuario == id) {
        _usuarioLogueado = actualizado;

        await _storage.write(
          key: 'usuario_data',
          value: jsonEncode(actualizado.toJson()),
        );
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

    await _storage.delete(key: 'jwt_token');
    await _storage.delete(key: 'usuario_data');

    _service.clearToken();

    _usuarioLogueado = null;
    usuarios = [];
    error = null;

    notifyListeners();
  }
}