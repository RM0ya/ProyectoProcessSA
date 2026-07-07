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
}