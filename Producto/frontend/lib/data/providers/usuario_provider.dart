import 'package:flutter/material.dart';
import '../models/usuario_model.dart';
import '../services/usuario_service.dart';
import 'package:dio/dio.dart';

class UsuarioProvider extends ChangeNotifier {
  final UsuarioService _service = UsuarioService();

  List<UsuarioModel> usuarios = [];
  bool isLoading = false;
  String? error;

  // FIX: campo privado con getter y setter para poder notificar desde afuera
  UsuarioModel? _usuarioLogueado;

  UsuarioModel? get usuarioLogueado => _usuarioLogueado;

  set usuarioLogueado(UsuarioModel? u) {
    _usuarioLogueado = u;
    notifyListeners();
  }

  // Expone el token para otros providers
  String? get token => _service.token;

  bool get esAdmin =>
      _usuarioLogueado?.rol?['nombre']?.toString().toLowerCase() == 'admin';

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
      isLoading = false;
      if (data != null && data['usuario'] != null) {
        _usuarioLogueado = UsuarioModel.fromJson(data['usuario']);
        print('ROL USUARIO: ${_usuarioLogueado?.rol}');
        print('ES ADMIN: $esAdmin');
        notifyListeners();
        return true;
      }
      notifyListeners();
      return false;
    } catch (e) {
      print('ERROR LOGIN: $e');
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
      isLoading = false;
      if (data != null && data['usuario'] != null) {
        _usuarioLogueado = UsuarioModel.fromJson(data['usuario']);
        print('ROL GOOGLE: ${_usuarioLogueado?.rol}');
        print('ES ADMIN GOOGLE: $esAdmin');
        notifyListeners();
        return true;
      }
      notifyListeners();
      return false;
    } catch (e) {
      print('ERROR LOGIN GOOGLE: $e');
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
      // FIX: si el usuario que se actualizó es el logueado, actualizar también
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

  void cerrarSesion() {
    _service.clearToken();
    _usuarioLogueado = null;
    usuarios = [];
    notifyListeners();
  }
}