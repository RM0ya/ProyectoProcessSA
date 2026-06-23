class SesionModel {
  final int idSesion;
  final String token;
  final String fechaInicioS;
  final String? fechaFinS;
  final String ipOrigen;
  final String tipoEvento;
  final Map<String, dynamic>? usuario;

  SesionModel({
    required this.idSesion,
    required this.token,
    required this.fechaInicioS,
    required this.fechaFinS,
    required this.ipOrigen,
    required this.tipoEvento,
    required this.usuario,
  });

  factory SesionModel.fromJson(Map<String, dynamic> json) {
    return SesionModel(
      idSesion: json['idSesion'],
      token: json['token'] ?? '',
      fechaInicioS: json['fechaInicioS'] ?? '',
      fechaFinS: json['fechaFinS'],
      ipOrigen: json['ipOrigen'] ?? '',
      tipoEvento: json['tipoEvento'] ?? '',
      usuario: json['usuario'],
    );
  }

  bool get activa => fechaFinS == null;
}
