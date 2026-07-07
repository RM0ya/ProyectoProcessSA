import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../core/constants.dart';
import '../models/notificacion_model.dart';

class NotificacionProvider extends ChangeNotifier {
  final Dio _dio = Dio();
  final String _baseUrl = '${AppConstants.baseUrl}/notificaciones';

  List<NotificacionModel> _notificaciones = [];
  bool isLoading = false;
  String? error;
  String? _token;

  List<NotificacionModel> get notificaciones => _notificaciones;

  int get noLeidasCount => _notificaciones.where((n) => !n.leida).length;

  void setToken(String token) {
    _token = token;
  }

  Options get _authOptions =>
      Options(headers: {if (_token != null) 'Authorization': 'Bearer $_token'});

  Future<void> cargarNotificaciones(int idUsuario) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _dio.get(
        '$_baseUrl/usuario/$idUsuario',
        options: _authOptions,
      );
      _notificaciones = (response.data as List)
          .map((e) => NotificacionModel.fromJson(e as Map<String, dynamic>))
          .toList();
      error = null;
    } catch (e) {
      print('ERROR CARGAR NOTIFICACIONES: $e');
      _notificaciones = [];
      error = 'Error al cargar notificaciones';
    }

    isLoading = false;
    notifyListeners();
  }

  Future<void> marcarLeida(int idNotificacion) async {
    try {
      await _dio.put(
        '$_baseUrl/$idNotificacion/marcar-leida',
        options: _authOptions,
      );

      final idx = _notificaciones.indexWhere(
        (n) => n.idNotificacion == idNotificacion,
      );
      if (idx != -1) {
        final anterior = _notificaciones[idx];
        _notificaciones[idx] = NotificacionModel(
          idNotificacion: anterior.idNotificacion,
          tipoNoti: anterior.tipoNoti,
          mensajeNoti: anterior.mensajeNoti,
          leida: true,
          fechaEnvio: anterior.fechaEnvio,
          fechaLectura: anterior.fechaLectura,
        );
        notifyListeners();
      }
    } catch (e) {
      print('ERROR MARCAR LEIDA: $e');
    }
  }
}
