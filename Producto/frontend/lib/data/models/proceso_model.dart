class ProcesoModel {
  final int? idProceso;
  final String nombre;
  final String descripcionProceso;
  final String fechaInicio;
  final String fechaLimite;
  final String fechaCreacion;
  final int? idOrganizacion;
  final int idEstado; // NUEVO
  final String? nombreEstado; // NUEVO

  ProcesoModel({
    this.idProceso,
    required this.nombre,
    required this.descripcionProceso,
    required this.fechaInicio,
    required this.fechaLimite,
    required this.fechaCreacion,
    this.idOrganizacion,
    this.idEstado = 1, // Activo por defecto al crear
    this.nombreEstado,
  });

  factory ProcesoModel.fromJson(Map<String, dynamic> json) {
    return ProcesoModel(
      idProceso: json['idProceso'],
      nombre: json['nombre'] ?? '',
      descripcionProceso: json['descripcionProceso'] ?? '',
      fechaInicio: json['fechaInicio'] ?? '',
      fechaLimite: json['fechaLimite'] ?? '',
      fechaCreacion: json['fechaCreacion'] ?? '',
      idOrganizacion: json['organizacion']?['idOrganizacion'],
      idEstado: json['estado']?['idEstado'] ?? 1,
      nombreEstado: json['estado']?['nombreEstado'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      if (idProceso != null) 'idProceso': idProceso,
      'nombre': nombre,
      'descripcionProceso': descripcionProceso,
      'fechaInicio': fechaInicio,
      'fechaLimite': fechaLimite,
      'fechaCreacion': fechaCreacion,
      'organizacion': {'idOrganizacion': idOrganizacion ?? 1},
      'kpi': {'idKpi': 1},
      'estado': {'idEstado': idEstado},
    };
  }
}
