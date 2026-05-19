class TareaModel {
  final int? idTarea;
  final int idProceso;
  final int idUsuario;
  final int idEstado;
  final String nombreTarea;
  final String descripcionT;
  final int ordenT;
  final String fechaLimiteS;
  final String? fechaCompletada;
  final String fechaCreacionT;

  final String? nombreProceso;
  final String? nombreUsuario;
  final String? nombreEstado;

  TareaModel({
    this.idTarea,
    required this.idProceso,
    required this.idUsuario,
    required this.idEstado,
    required this.nombreTarea,
    required this.descripcionT,
    required this.ordenT,
    required this.fechaLimiteS,
    this.fechaCompletada,
    required this.fechaCreacionT,
    this.nombreProceso,
    this.nombreUsuario,
    this.nombreEstado,
  });

  factory TareaModel.fromJson(Map<String, dynamic> json) {
    return TareaModel(
      idTarea: json['idTarea'],
      idProceso: json['proceso']?['idProceso'] ?? 0,
      idUsuario: json['usuario']?['idUsuario'] ?? 0,
      idEstado: json['estado']?['idEstado'] ?? 0,
      nombreTarea: json['nombreTarea'] ?? '',
      descripcionT: json['descripcionT'] ?? '',
      ordenT: json['ordenT'] ?? 0,
      fechaLimiteS: json['fechaLimiteS'] ?? '',
      fechaCompletada: json['fechaCompletada'],
      fechaCreacionT: json['fechaCreacionT'] ?? '',
      nombreProceso:
          json['proceso']?['nombre'] ?? json['proceso']?['nombreProceso'],
      nombreUsuario:
          json['usuario']?['nombreUsuario'] ??
          json['usuario']?['nombreCompleto'] ??
          json['usuario']?['nombre'] ??
          json['usuario']?['emailUsuario'],
      nombreEstado:
          json['estado']?['nombreEstado'] ?? json['estado']?['nombre'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idTarea != null) 'idTarea': idTarea,
      'proceso': {'idProceso': idProceso},
      'usuario': {'idUsuario': idUsuario},
      'estado': {'idEstado': idEstado},
      'nombreTarea': nombreTarea,
      'descripcionT': descripcionT,
      'ordenT': ordenT,
      'fechaLimiteS': fechaLimiteS,
      'fechaCompletada': fechaCompletada,
      'fechaCreacionT': fechaCreacionT,
    };
  }
}
