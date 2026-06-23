import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificacionesConfigScreen extends StatefulWidget {
  const NotificacionesConfigScreen({super.key});

  @override
  State<NotificacionesConfigScreen> createState() =>
      _NotificacionesConfigScreenState();
}

class _NotificacionesConfigScreenState
    extends State<NotificacionesConfigScreen> {
  bool _notificacionesActivas = true;
  bool _notifPush = true;
  bool _notifCorreo = true;
  bool _notifTareaAsignada = true;
  bool _notifTareaVence48h = true;
  bool _notifTareaVencida = true;
  bool _notifTareaCompletada = true;
  bool _notifProcesoRiesgo = true;
  bool _notifComentarioMencion = true;
  bool _notifDocumentoSubido = false;
  bool _notifNuevoUsuario = true;

  String _anticipacionSeleccionada = '48 horas';

  final List<String> _opcionesAnticipacion = const [
    '12 horas',
    '24 horas',
    '48 horas',
    '72 horas',
  ];

  bool _guardando = false;
  bool _cargando = true;

  @override
  void initState() {
    super.initState();
    _cargarPreferencias();
  }

  Future<void> _cargarPreferencias() async {
    final prefs = await SharedPreferences.getInstance();

    setState(() {
      _notificacionesActivas =
          prefs.getBool('notif_activas') ?? _notificacionesActivas;
      _notifPush = prefs.getBool('notif_push') ?? _notifPush;
      _notifCorreo = prefs.getBool('notif_correo') ?? _notifCorreo;
      _notifTareaAsignada =
          prefs.getBool('notif_tarea_asignada') ?? _notifTareaAsignada;
      _notifTareaVence48h =
          prefs.getBool('notif_tarea_vence') ?? _notifTareaVence48h;
      _notifTareaVencida =
          prefs.getBool('notif_tarea_vencida') ?? _notifTareaVencida;
      _notifTareaCompletada =
          prefs.getBool('notif_tarea_completada') ?? _notifTareaCompletada;
      _notifProcesoRiesgo =
          prefs.getBool('notif_proceso_riesgo') ?? _notifProcesoRiesgo;
      _notifComentarioMencion =
          prefs.getBool('notif_comentario_mencion') ?? _notifComentarioMencion;
      _notifDocumentoSubido =
          prefs.getBool('notif_documento_subido') ?? _notifDocumentoSubido;
      _notifNuevoUsuario =
          prefs.getBool('notif_nuevo_usuario') ?? _notifNuevoUsuario;
      _anticipacionSeleccionada =
          prefs.getString('notif_anticipacion') ?? _anticipacionSeleccionada;
      _cargando = false;
    });
  }

  Future<void> _guardarConfiguracion() async {
    setState(() => _guardando = true);

    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('notif_activas', _notificacionesActivas);
    await prefs.setBool('notif_push', _notifPush);
    await prefs.setBool('notif_correo', _notifCorreo);
    await prefs.setBool('notif_tarea_asignada', _notifTareaAsignada);
    await prefs.setBool('notif_tarea_vence', _notifTareaVence48h);
    await prefs.setBool('notif_tarea_vencida', _notifTareaVencida);
    await prefs.setBool('notif_tarea_completada', _notifTareaCompletada);
    await prefs.setBool('notif_proceso_riesgo', _notifProcesoRiesgo);
    await prefs.setBool('notif_comentario_mencion', _notifComentarioMencion);
    await prefs.setBool('notif_documento_subido', _notifDocumentoSubido);
    await prefs.setBool('notif_nuevo_usuario', _notifNuevoUsuario);
    await prefs.setString('notif_anticipacion', _anticipacionSeleccionada);

    if (!mounted) return;

    setState(() => _guardando = false);

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Configuración guardada correctamente'),
        backgroundColor: Color(0xFF639922),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_cargando) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Notificaciones',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF185FA5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SwitchRow(
              switchKey: const Key('notificacionesActivasSwitch'),
              icono: Icons.notifications,
              color: const Color(0xFF185FA5),
              label: 'Notificaciones',
              descripcion: _notificacionesActivas
                  ? 'Activadas'
                  : 'Desactivadas',
              valor: _notificacionesActivas,
              onChanged: (valor) =>
                  setState(() => _notificacionesActivas = valor),
            ),

            if (_notificacionesActivas) ...[
              const _SeccionTitulo(titulo: 'Canal de notificaciones'),
              _SwitchRow(
                switchKey: const Key('notificacionesPushSwitch'),
                icono: Icons.phone_android,
                color: const Color(0xFF185FA5),
                label: 'Notificaciones push',
                descripcion: 'Alertas en tu dispositivo móvil',
                valor: _notifPush,
                onChanged: (v) => setState(() => _notifPush = v),
              ),
              _SwitchRow(
                switchKey: const Key('notificacionesCorreoSwitch'),
                icono: Icons.email_outlined,
                color: Colors.teal,
                label: 'Correo electrónico',
                descripcion: 'Resumen de alertas por correo',
                valor: _notifCorreo,
                onChanged: (v) => setState(() => _notifCorreo = v),
              ),

              const _SeccionTitulo(
                titulo: 'Anticipación de alertas de vencimiento',
              ),
              Container(
                key: const Key('notificacionesAnticipacionDropdown'),
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _anticipacionSeleccionada,
                    isExpanded: true,
                    icon: const Icon(
                      Icons.keyboard_arrow_down,
                      color: Color(0xFF185FA5),
                    ),
                    onChanged: (valor) {
                      if (valor == null) return;
                      setState(() => _anticipacionSeleccionada = valor);
                    },
                    items: _opcionesAnticipacion
                        .map(
                          (opcion) => DropdownMenuItem(
                            value: opcion,
                            child: Text(opcion),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ),

              const _SeccionTitulo(titulo: 'Tipos de notificaciones'),
              _SwitchRow(
                switchKey: const Key('notificacionesTareaAsignadaSwitch'),
                icono: Icons.assignment_ind_outlined,
                color: const Color(0xFF185FA5),
                label: 'Tarea asignada',
                descripcion: 'Cuando te asignan una nueva tarea',
                valor: _notifTareaAsignada,
                onChanged: (v) => setState(() => _notifTareaAsignada = v),
              ),
              _SwitchRow(
                switchKey: const Key('notificacionesTareaVenceSwitch'),
                icono: Icons.timer_outlined,
                color: Colors.orange,
                label: 'Tarea por vencer',
                descripcion:
                    'Aviso $_anticipacionSeleccionada antes del vencimiento',
                valor: _notifTareaVence48h,
                onChanged: (v) => setState(() => _notifTareaVence48h = v),
              ),
              _SwitchRow(
                switchKey: const Key('notificacionesTareaVencidaSwitch'),
                icono: Icons.alarm_off_outlined,
                color: Colors.red,
                label: 'Tarea vencida',
                descripcion: 'Cuando una tarea supera su fecha límite',
                valor: _notifTareaVencida,
                onChanged: (v) => setState(() => _notifTareaVencida = v),
              ),
              _SwitchRow(
                switchKey: const Key('notificacionesTareaCompletadaSwitch'),
                icono: Icons.task_alt,
                color: Colors.green,
                label: 'Tarea completada',
                descripcion: 'Cuando una tarea de tu equipo se completa',
                valor: _notifTareaCompletada,
                onChanged: (v) => setState(() => _notifTareaCompletada = v),
              ),
              _SwitchRow(
                switchKey: const Key('notificacionesProcesoRiesgoSwitch'),
                icono: Icons.warning_amber_outlined,
                color: Colors.deepOrange,
                label: 'Proceso en riesgo',
                descripcion:
                    'Cuando un proceso supera el 50% de tareas vencidas',
                valor: _notifProcesoRiesgo,
                onChanged: (v) => setState(() => _notifProcesoRiesgo = v),
              ),
              _SwitchRow(
                switchKey: const Key('notificacionesComentarioSwitch'),
                icono: Icons.alternate_email,
                color: Colors.purple,
                label: 'Mención en comentario',
                descripcion: 'Cuando alguien te menciona en una tarea',
                valor: _notifComentarioMencion,
                onChanged: (v) => setState(() => _notifComentarioMencion = v),
              ),
              _SwitchRow(
                switchKey: const Key('notificacionesDocumentoSwitch'),
                icono: Icons.upload_file_outlined,
                color: Colors.teal,
                label: 'Documento subido',
                descripcion: 'Cuando se sube un archivo a tus procesos',
                valor: _notifDocumentoSubido,
                onChanged: (v) => setState(() => _notifDocumentoSubido = v),
              ),
              _SwitchRow(
                switchKey: const Key('notificacionesNuevoUsuarioSwitch'),
                icono: Icons.person_add_outlined,
                color: const Color(0xFF185FA5),
                label: 'Nuevo usuario',
                descripcion: 'Cuando se agrega un usuario al sistema',
                valor: _notifNuevoUsuario,
                onChanged: (v) => setState(() => _notifNuevoUsuario = v),
              ),
            ],

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                key: const Key('guardarNotificacionesButton'),
                onPressed: _guardando ? null : _guardarConfiguracion,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF185FA5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: _guardando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Guardar configuración',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
              ),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _SeccionTitulo extends StatelessWidget {
  final String titulo;

  const _SeccionTitulo({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF185FA5),
        ),
      ),
    );
  }
}

class _SwitchRow extends StatelessWidget {
  final Key? switchKey;
  final IconData icono;
  final Color color;
  final String label;
  final String descripcion;
  final bool valor;
  final ValueChanged<bool> onChanged;

  const _SwitchRow({
    this.switchKey,
    required this.icono,
    required this.color,
    required this.label,
    required this.descripcion,
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icono, size: 18, color: color),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  descripcion,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
              ],
            ),
          ),
          Switch(
            key: switchKey,
            value: valor,
            activeColor: const Color(0xFF185FA5),
            onChanged: onChanged,
          ),
        ],
      ),
    );
  }
}
