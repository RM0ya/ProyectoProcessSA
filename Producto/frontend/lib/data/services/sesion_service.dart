import 'package:dio/dio.dart';
import 'package:process_sa/core/constants.dart'; // Asegúrate que este import sea correcto
import '../models/sesion_model.dart';

class SesionService {
  final Dio dio;

  // Pasamos el token aquí para autenticar cada petición
  SesionService(String? token)
    : dio = Dio(
        BaseOptions(
          baseUrl: AppConstants.baseUrl, // <--- ESTO ES LO QUE ESTABA FALTANDO
          headers: {if (token != null) 'Authorization': 'Bearer $token'},
        ),
      );

  Future<List<SesionModel>> listarTodas() async {
    final response = await dio.get('/sesiones');
    return (response.data as List).map((e) => SesionModel.fromJson(e)).toList();
  }
}
