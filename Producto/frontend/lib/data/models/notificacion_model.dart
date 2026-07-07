class NotificacionModel {
  final int idNotificacion;
  final String tipoNoti;
  final String mensajeNoti;
  final bool leida;
  final String? fechaEnvio;
  final String? fechaLectura;

  NotificacionModel({
    required this.idNotificacion,
    required this.tipoNoti,
    required this.mensajeNoti,
    required this.leida,
    this.fechaEnvio,
    this.fechaLectura,
  });

  factory NotificacionModel.fromJson(Map<String, dynamic> json) {
    return NotificacionModel(
      idNotificacion: json['idNotificacion'] as int,
      tipoNoti: json['tipoNoti']?.toString() ?? '',
      mensajeNoti: json['mensajeNoti']?.toString() ?? '',
      // El backend guarda 'S' / 'N' como Character; puede llegar
      // serializado como String de un carácter.
      leida: json['notiLeida']?.toString().toUpperCase() == 'S',
      fechaEnvio: json['fechaEnvio']?.toString(),
      fechaLectura: json['fechaLectura']?.toString(),
    );
  }
}
