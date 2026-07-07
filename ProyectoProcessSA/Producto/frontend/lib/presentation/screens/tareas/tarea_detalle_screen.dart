import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/tarea_model.dart';
import '../../../data/services/tarea_service.dart';
import '../../../data/providers/usuario_provider.dart';
import '../../../data/models/usuario_model.dart';

class TareaDetalleScreen extends StatefulWidget {
  final TareaModel tarea;

  const TareaDetalleScreen({super.key, required this.tarea});

  @override
  State<TareaDetalleScreen> createState() => _TareaDetalleScreenState();
}

class _TareaDetalleScreenState extends State<TareaDetalleScreen> {
  late TextEditingController _tituloController;
  late TextEditingController _descripcionController;
  late TextEditingController _fechaController;
  late int _idEstado;
  late int? _idUsuarioSeleccionado;

  List<UsuarioModel> _usuariosOrganizacion = [];

  bool _editando = false;
  bool _guardando = false;

  final List<Map<String, dynamic>> _estados = const [
    {'id': 1, 'nombre': 'Activo', 'color': Colors.blue},
    {'id': 2, 'nombre': 'Inactivo', 'color': Colors.orange},
    {'id': 3, 'nombre': 'Completada', 'color': Colors.green},
  ];

  @override
  void initState() {
    super.initState();

    _tituloController = TextEditingController(text: widget.tarea.nombreTarea);
    _descripcionController = TextEditingController(
      text: widget.tarea.descripcionT,
    );
    _fechaController = TextEditingController(text: widget.tarea.fechaLimiteS);

    _idEstado = widget.tarea.idEstado;
    _idUsuarioSeleccionado = widget.tarea.idUsuario;

    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _cargarUsuariosSiEsAdmin(),
    );
  }

  Future<void> _cargarUsuariosSiEsAdmin() async {
    final usuarioProvider = context.read<UsuarioProvider>();
    if (!usuarioProvider.esAdmin) return;

    await usuarioProvider.cargarUsuarios();
    if (!mounted) return;
    setState(() => _usuariosOrganizacion = usuarioProvider.usuarios);
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  // Un usuario normal solo puede editar su propia tarea, y solo mientras
  // no esté completada. El Admin puede editar cualquier tarea, incluso
  // completadas (para reabrirlas o corregirlas).
  bool _puedeEditar(UsuarioProvider usuarioProvider) {
    if (usuarioProvider.esAdmin) return true;

    final esDueno =
        widget.tarea.idUsuario == usuarioProvider.usuarioLogueado?.idUsuario;
    final estaCompletadaOriginal =
        (widget.tarea.nombreEstado ?? '').toLowerCase() == 'completada';

    return esDueno && !estaCompletadaOriginal;
  }

  Color _colorEstado() {
    final estado = _estados.firstWhere(
      (e) => e['id'] == _idEstado,
      orElse: () => _estados.first,
    );

    return estado['color'] as Color;
  }

  String _nombreEstado() {
    final estado = _estados.firstWhere(
      (e) => e['id'] == _idEstado,
      orElse: () => _estados.first,
    );

    return estado['nombre'] as String;
  }

  Future<void> _seleccionarFecha() async {
    final actual = DateTime.tryParse(_fechaController.text) ?? DateTime.now();

    final seleccionada = await showDatePicker(
      context: context,
      initialDate: actual,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (seleccionada == null) return;

    setState(() {
      _fechaController.text = seleccionada.toIso8601String().split('T').first;
    });
  }

  Future<void> _guardarCambios() async {
    if (widget.tarea.idTarea == null) return;

    if (_tituloController.text.trim().isEmpty ||
        _descripcionController.text.trim().isEmpty ||
        _fechaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa título, descripción y fecha'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final usuarioProvider = context.read<UsuarioProvider>();
      final service = TareaService(token: usuarioProvider.token);

      final tareaActualizada = TareaModel(
        idTarea: widget.tarea.idTarea,
        idProceso: widget.tarea.idProceso,
        idUsuario: _idUsuarioSeleccionado ?? widget.tarea.idUsuario,
        idEstado: _idEstado,
        nombreTarea: _tituloController.text.trim(),
        descripcionT: _descripcionController.text.trim(),
        ordenT: widget.tarea.ordenT,
        fechaLimiteS: _fechaController.text.trim(),
        fechaCompletada: _idEstado == 3
            ? DateTime.now().toIso8601String()
            : widget.tarea.fechaCompletada,
        fechaCreacionT: widget.tarea.fechaCreacionT,
      );

      await service.update(widget.tarea.idTarea!, tareaActualizada);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarea actualizada correctamente'),
          backgroundColor: Color(0xFF639922),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  Widget _campo({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    bool readOnly = false,
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        controller: controller,
        enabled: _editando || readOnly,
        readOnly: readOnly,
        maxLines: maxLines,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF185FA5)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
        ),
      ),
    );
  }

  Widget _infoCard({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 18,
            backgroundColor: color.withOpacity(0.12),
            child: Icon(icon, size: 18, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _selectorEstado() {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _idEstado,
          isExpanded: true,
          icon: const Icon(Icons.keyboard_arrow_down),
          onChanged: _editando
              ? (value) {
                  if (value == null) return;
                  setState(() => _idEstado = value);
                }
              : null,
          items: _estados.map((estado) {
            return DropdownMenuItem<int>(
              value: estado['id'] as int,
              child: Row(
                children: [
                  Icon(Icons.circle, size: 10, color: estado['color'] as Color),
                  const SizedBox(width: 8),
                  Text(estado['nombre'] as String),
                ],
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  Widget _selectorUsuario() {
    final existeEnLista = _usuariosOrganizacion.any(
      (u) => u.idUsuario == _idUsuarioSeleccionado,
    );

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: existeEnLista ? _idUsuarioSeleccionado : null,
          isExpanded: true,
          hint: const Text('Reasignar a...'),
          icon: const Icon(Icons.keyboard_arrow_down),
          items: _usuariosOrganizacion.map((u) {
            return DropdownMenuItem<int>(
              value: u.idUsuario,
              child: Text('${u.nombre} ${u.apellidoP}'),
            );
          }).toList(),
          onChanged: (value) => setState(() => _idUsuarioSeleccionado = value),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = context.watch<UsuarioProvider>();
    final puedeEditar = _puedeEditar(usuarioProvider);

    final proceso = widget.tarea.nombreProceso ?? 'Sin proceso';
    final usuario = widget.tarea.nombreUsuario ?? 'Sin usuario';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Detalle de tarea',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF185FA5),
        iconTheme: const IconThemeData(color: Colors.white),
        actions: [
          // El ícono de editar solo aparece si el usuario tiene permiso.
          if (puedeEditar)
            IconButton(
              icon: Icon(_editando ? Icons.close : Icons.edit),
              onPressed: () {
                setState(() => _editando = !_editando);
              },
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: const Color(0xFF185FA5),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _Badge(
                    label: _nombreEstado(),
                    color: Colors.white,
                    backgroundColor: Colors.white.withOpacity(0.18),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _tituloController.text,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    proceso,
                    style: const TextStyle(color: Colors.white70, fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            if (!puedeEditar)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 16),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.info_outline,
                      size: 18,
                      color: Colors.orange,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        (widget.tarea.nombreEstado ?? '').toLowerCase() ==
                                'completada'
                            ? 'Esta tarea ya está completada. Solo un administrador puede modificarla.'
                            : 'No puedes modificar esta tarea porque no es tuya.',
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.4,
              children: [
                _infoCard(
                  icon: Icons.person_outline,
                  label: 'Responsable',
                  value: usuario,
                  color: const Color(0xFF185FA5),
                ),
                _infoCard(
                  icon: Icons.account_tree_outlined,
                  label: 'Proceso',
                  value: proceso,
                  color: Colors.purple,
                ),
                _infoCard(
                  icon: Icons.calendar_today,
                  label: 'Fecha límite',
                  value: _fechaController.text,
                  color: Colors.orange,
                ),
                _infoCard(
                  icon: Icons.flag_outlined,
                  label: 'Estado',
                  value: _nombreEstado(),
                  color: _colorEstado(),
                ),
              ],
            ),

            const SizedBox(height: 18),

            _campo(
              label: 'Título',
              controller: _tituloController,
              icon: Icons.task_outlined,
            ),

            _campo(
              label: 'Descripción',
              controller: _descripcionController,
              icon: Icons.notes,
              maxLines: 3,
            ),

            _campo(
              label: 'Fecha límite',
              controller: _fechaController,
              icon: Icons.calendar_today,
              readOnly: true,
              onTap: _editando ? _seleccionarFecha : null,
            ),

            // Solo el Admin, y solo en modo edición, ve el selector para
            // reasignar la tarea a otro usuario de la organización.
            if (usuarioProvider.esAdmin && _editando) _selectorUsuario(),

            _selectorEstado(),

            if (_editando)
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton.icon(
                  onPressed: _guardando ? null : _guardarCambios,
                  icon: _guardando
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : const Icon(Icons.save, color: Colors.white),
                  label: Text(
                    _guardando ? 'Guardando...' : 'Guardar cambios',
                    style: const TextStyle(color: Colors.white),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF185FA5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _Badge extends StatelessWidget {
  final String label;
  final Color color;
  final Color backgroundColor;

  const _Badge({
    required this.label,
    required this.color,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
