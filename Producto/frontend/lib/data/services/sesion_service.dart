import 'package:dio/dio.dart';
import '../models/sesion_model.dart';

class SesionService {
  final Dio dio;

  SesionService(this.dio);

  Future<List<SesionModel>> listarTodas() async {
    final response = await dio.get('/sesiones');

    return (response.data as List).map((e) => SesionModel.fromJson(e)).toList();
  }
}
