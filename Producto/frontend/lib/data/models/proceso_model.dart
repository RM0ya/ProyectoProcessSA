class ProcesoModel {
  final int? idProceso;
  final String nombre;
  final String descripcionProceso;
  final String fechaInicio;
  final String fechaLimite;
  final String fechaCreacion;

  ProcesoModel({
    this.idProceso,
    required this.nombre,
    required this.descripcionProceso,
    required this.fechaInicio,
    required this.fechaLimite,
    required this.fechaCreacion,
  });

  factory ProcesoModel.fromJson(Map<String, dynamic> json) {
    return ProcesoModel(
      idProceso: json['idProceso'],
      nombre: json['nombre'] ?? '',
      descripcionProceso: json['descripcionProceso'] ?? '',
      fechaInicio: json['fechaInicio'] ?? '',
      fechaLimite: json['fechaLimite'] ?? '',
      fechaCreacion: json['fechaCreacion'] ?? '',
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
      'organizacion': {'idOrganizacion': 1},
      'kpi': {'idKpi': 1},
      'estado': {'idEstado': 1},
    };
  }
}