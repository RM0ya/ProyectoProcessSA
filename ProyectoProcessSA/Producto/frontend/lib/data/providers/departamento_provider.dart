import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../models/departamento_model.dart';
import '../../core/constants.dart';

class DepartamentoProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  final String _baseUrl = '${AppConstants.baseUrl}/departamentos';

  List<DepartamentoModel> _departamentos = [];
  bool _isLoading = false;
  String? _error;
  String? _token;

  List<DepartamentoModel> get departamentos => _departamentos;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setToken(String token) => _token = token;

  Options get _authOptions =>
      Options(headers: {if (_token != null) 'Authorization': 'Bearer $_token'});

  // Carga todos los departamentos (sin filtro)
  Future<void> cargarDepartamentos() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _dio.get(_baseUrl, options: _authOptions);
      final List<dynamic> data = response.data;
      _departamentos = data.map((e) => DepartamentoModel.fromJson(e)).toList();
    } catch (e) {
      print('ERROR DEP: $e');
      _error = 'Error al cargar departamentos: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  // Carga departamentos filtrados por organización
  Future<void> cargarPorOrganizacion(int idOrganizacion) async {
    _isLoading = true;
    _error = null;
    _departamentos = [];
    notifyListeners();

    try {
      final response = await _dio.get(
        '$_baseUrl/por-organizacion/$idOrganizacion',
        options: _authOptions,
      );
      final List<dynamic> data = response.data;
      _departamentos = data.map((e) => DepartamentoModel.fromJson(e)).toList();
      print('DEPARTAMENTOS ORG $idOrganizacion: $_departamentos');
    } catch (e) {
      print('ERROR DEP: $e');
      _error = 'Error al cargar departamentos: $e';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> crearDepartamento({
    required String nombre,
    required String descripcion,
    required int idOrganizacion,
  }) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        data: {
          'nombre': nombre,
          'descripcion': descripcion,
          'organizacion': {'idOrganizacion': idOrganizacion},
        },
        options: _authOptions,
      );

      final nuevo = DepartamentoModel.fromJson(response.data);
      _departamentos.add(nuevo);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      print('ERROR CREAR DEP: $e');
      _error = 'Error al crear departamento';
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarDepartamento({
    required int idDepartamento,
    required String nombre,
    required String descripcion,
  }) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/$idDepartamento',
        data: {'nombre': nombre, 'descripcion': descripcion},
        options: _authOptions,
      );

      final actualizado = DepartamentoModel.fromJson(response.data);
      final idx = _departamentos.indexWhere(
        (d) => d.idDepartamento == idDepartamento,
      );
      if (idx != -1) _departamentos[idx] = actualizado;

      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      print('ERROR ACTUALIZAR DEP: $e');
      _error = 'Error al actualizar departamento';
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarDepartamento(int idDepartamento) async {
    try {
      await _dio.delete('$_baseUrl/$idDepartamento', options: _authOptions);
      _departamentos.removeWhere((d) => d.idDepartamento == idDepartamento);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      print('ERROR ELIMINAR DEP: $e');
      _error = 'Error al eliminar departamento';
      notifyListeners();
      return false;
    }
  }
}
