import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/constants.dart';

class OrganizacionProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  final String _baseUrl = '${AppConstants.baseUrl}/organizaciones';

  List<Map<String, dynamic>> _organizaciones = [];
  bool _isLoading = false;
  String? _token;

  List<Map<String, dynamic>> get organizaciones => _organizaciones;
  bool get isLoading => _isLoading;

  void setToken(String token) {
    _token = token;
    print('TOKEN SETEADO EN ORG: $_token');
  }

  Options get _authOptions =>
      Options(headers: {if (_token != null) 'Authorization': 'Bearer $_token'});

  Future<void> cargarOrganizaciones() async {
    _isLoading = true;
    notifyListeners();

    print('TOKEN AL CARGAR ORG: $_token');

    try {
      final response = await _dio.get(_baseUrl, options: _authOptions);
      _organizaciones = (response.data as List).cast<Map<String, dynamic>>();
      print('ORGANIZACIONES: $_organizaciones');
    } catch (e) {
      print('ERROR ORG: $e');
      _organizaciones = [];
    }

    _isLoading = false;
    notifyListeners();
  }
}
