class EstadoModel {
  final int? idEstado;
  final String nombreEstado;

  EstadoModel({
    this.idEstado,
    required this.nombreEstado,
  });

  factory EstadoModel.fromJson(Map<String, dynamic> json) {
    return EstadoModel(
      idEstado: json['idEstado'],
      nombreEstado: json['nombreEstado'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idEstado != null) 'idEstado': idEstado,
      'nombreEstado': nombreEstado,
    };
  }
}