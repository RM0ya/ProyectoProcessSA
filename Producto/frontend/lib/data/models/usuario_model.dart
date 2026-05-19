class UsuarioModel {
  final int? idUsuario;

  final String nombre;
  final String apellidoP;
  final String? apellidoM;

  final String emailUsuario;
  final String password;

  final String? telefono;

  final int? intentosFallidos;
  final String? bloqueado;

  final String? ultimoLogin;
  final String? fechaCreacion;

  final Map<String, dynamic>? rol;
  final Map<String, dynamic>? organizacion;
  final Map<String, dynamic>? departamento; // NUEVO

  UsuarioModel({
    this.idUsuario,

    required this.nombre,
    required this.apellidoP,
    this.apellidoM,

    required this.emailUsuario,
    required this.password,

    this.telefono,

    this.intentosFallidos,
    this.bloqueado,

    this.ultimoLogin,
    this.fechaCreacion,

    this.rol,
    this.organizacion,
    this.departamento, // NUEVO
  });

  factory UsuarioModel.fromJson(Map<String, dynamic> json) {
    return UsuarioModel(
      idUsuario: json['idUsuario'],
      nombre: json['nombre'] ?? '',
      apellidoP: json['apellidoP'] ?? '',
      apellidoM: json['apellidoM'],
      emailUsuario: json['emailUsuario'] ?? '',
      password: json['password'] ?? '',
      telefono: json['telefono'],
      intentosFallidos: json['intentosFallidos'],
      bloqueado: json['bloqueado'],
      ultimoLogin: json['ultimoLogin'],
      fechaCreacion: json['fechaCreacion'],
      rol: json['rol'],
      organizacion: json['organizacion'],
      departamento: json['departamento'], // NUEVO
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idUsuario': idUsuario,

      'nombre': nombre,
      'apellidoP': apellidoP,
      'apellidoM': apellidoM,

      'emailUsuario': emailUsuario,
      'password': password,

      'telefono': telefono,

      'intentosFallidos': intentosFallidos,
      'bloqueado': bloqueado,

      'ultimoLogin': ultimoLogin,
      'fechaCreacion': fechaCreacion,

      'rol': rol,
      'organizacion': organizacion,
      'departamento': departamento, // NUEVO
    };
  }
}
