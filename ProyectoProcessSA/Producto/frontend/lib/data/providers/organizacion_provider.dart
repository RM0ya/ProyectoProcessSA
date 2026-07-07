import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/constants.dart';

class OrganizacionProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  final String _baseUrl = '${AppConstants.baseUrl}/organizaciones';

  List<Map<String, dynamic>> _organizaciones = [];
  bool _isLoading = false;
  String? _error;
  String? _token;

  List<Map<String, dynamic>> get organizaciones => _organizaciones;
  bool get isLoading => _isLoading;
  String? get error => _error;

  void setToken(String token) {
    _token = token;
  }

  Options get _authOptions =>
      Options(headers: {if (_token != null) 'Authorization': 'Bearer $_token'});

  Future<void> cargarOrganizaciones() async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.get(_baseUrl, options: _authOptions);
      _organizaciones = (response.data as List).cast<Map<String, dynamic>>();
      _error = null;
    } catch (e) {
      print('ERROR ORG: $e');
      _organizaciones = [];
      _error = 'Error al cargar organizaciones';
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<bool> crearOrganizacion(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post(
        _baseUrl,
        data: data,
        options: _authOptions,
      );
      _organizaciones.add(response.data as Map<String, dynamic>);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      print('ERROR CREAR ORG: $e');
      _error = 'Error al crear organización';
      notifyListeners();
      return false;
    }
  }

  Future<bool> actualizarOrganizacion(int id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put(
        '$_baseUrl/$id',
        data: data,
        options: _authOptions,
      );
      final idx = _organizaciones.indexWhere((o) => o['idOrganizacion'] == id);
      if (idx != -1) {
        _organizaciones[idx] = response.data as Map<String, dynamic>;
      }
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      print('ERROR ACTUALIZAR ORG: $e');
      _error = 'Error al actualizar organización';
      notifyListeners();
      return false;
    }
  }

  Future<bool> eliminarOrganizacion(int id) async {
    try {
      await _dio.delete('$_baseUrl/$id', options: _authOptions);
      _organizaciones.removeWhere((o) => o['idOrganizacion'] == id);
      _error = null;
      notifyListeners();
      return true;
    } catch (e) {
      print('ERROR ELIMINAR ORG: $e');
      _error = 'Error al eliminar organización';
      notifyListeners();
      return false;
    }
  }
}
