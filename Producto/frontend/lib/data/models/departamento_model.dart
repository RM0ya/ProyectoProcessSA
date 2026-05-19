class DepartamentoModel {
  final int idDepartamento;
  final String nombre;
  final String descripcion;

  DepartamentoModel({
    required this.idDepartamento,
    required this.nombre,
    required this.descripcion,
  });

  factory DepartamentoModel.fromJson(Map<String, dynamic> json) {
    return DepartamentoModel(
      idDepartamento: json['idDepartamento'] as int,
      nombre: json['nombre'] as String,
      descripcion: json['descripcion'] as String,
    );
  }

  Map<String, dynamic> toJson() => {
        'idDepartamento': idDepartamento,
        'nombre': nombre,
        'descripcion': descripcion,
      };
}