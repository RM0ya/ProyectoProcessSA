import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import 'package:process_sa/core/constants.dart';
import '../models/proceso_model.dart';

class ProcesoProvider extends ChangeNotifier {
  List<ProcesoModel> procesos = [];
  bool isLoading = false;
  String? error;

  Dio _dio(String? token) {
    return Dio(
      BaseOptions(
        baseUrl: AppConstants.baseUrl,
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ),
    );
  }

  Future<void> cargarProcesos({
    required int? idOrganizacion,
    required String? token,
  }) async {
    isLoading = true;
    notifyListeners();

    try {
      final response = await _dio(
        token,
      ).get('/procesos/organizacion/$idOrganizacion');

      procesos = (response.data as List)
          .map((e) => ProcesoModel.fromJson(e))
          .toList();

      error = null;
    } catch (e) {
      print('ERROR CARGAR PROCESOS: $e');
      error = 'Error al cargar procesos';
    }

    isLoading = false;
    notifyListeners();
  }

  int get totalProcesos => procesos.length;
}
