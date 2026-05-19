import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/tarea_model.dart';
import '../../../data/models/proceso_model.dart';
import '../../../data/services/tarea_service.dart';
import '../../../data/services/proceso_service.dart';
import '../../../data/providers/usuario_provider.dart';

class CrearTareaScreen extends StatefulWidget {
  const CrearTareaScreen({super.key});

  @override
  State<CrearTareaScreen> createState() => _CrearTareaScreenState();
}

class _CrearTareaScreenState extends State<CrearTareaScreen> {
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _fechaController = TextEditingController();

  final TareaService _tareaService = TareaService();
  final ProcesoService _procesoService = ProcesoService();

  List<ProcesoModel> _procesos = [];
  ProcesoModel? _procesoSeleccionado;

  bool _cargandoProcesos = true;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    _cargarProcesos();
  }

  Future<void> _cargarProcesos() async {
    try {
      final procesos = await _procesoService.getAll();

      setState(() {
        _procesos = procesos;
        _procesoSeleccionado = procesos.isNotEmpty ? procesos.first : null;
        _cargandoProcesos = false;
      });
    } catch (e) {
      setState(() => _cargandoProcesos = false);

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al cargar procesos: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _seleccionarFecha() async {
    final seleccionada = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (seleccionada == null) return;

    setState(() {
      _fechaController.text = seleccionada.toIso8601String().split('T').first;
    });
  }

  Future<void> _crearTarea() async {
    final usuarioProvider = Provider.of<UsuarioProvider>(
      context,
      listen: false,
    );

    final usuario = usuarioProvider.usuarioLogueado;

    if (usuario == null || usuario.idUsuario == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No hay usuario logueado'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_procesoSeleccionado == null ||
        _procesoSeleccionado!.idProceso == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona un proceso'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (_tituloController.text.trim().isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('El título es obligatorio')));
      return;
    }

    if (_fechaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('La fecha límite es obligatoria')),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final tarea = TareaModel(
        idProceso: _procesoSeleccionado!.idProceso!,
        idUsuario: usuario.idUsuario!,
        idEstado: 1,
        nombreTarea: _tituloController.text.trim(),
        descripcionT: _descripcionController.text.trim().isEmpty
            ? 'Sin descripción'
            : _descripcionController.text.trim(),
        ordenT: 1,
        fechaLimiteS: _fechaController.text.trim(),
        fechaCompletada: null,
        fechaCreacionT: DateTime.now().toIso8601String().split('T').first,
      );

      await _tareaService.create(tarea);

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarea creada correctamente'),
          backgroundColor: Color(0xFF639922),
        ),
      );

      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al crear tarea: $e'),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _guardando = false);
      }
    }
  }

  @override
  void dispose() {
    _tituloController.dispose();
    _descripcionController.dispose();
    _fechaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Nueva tarea', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF185FA5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _cargandoProcesos
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  _CampoTexto(
                    label: 'Título de la tarea',
                    controller: _tituloController,
                    icono: Icons.task_outlined,
                    tipo: TextInputType.text,
                  ),

                  _CampoTexto(
                    label: 'Descripción',
                    controller: _descripcionController,
                    icono: Icons.notes,
                    tipo: TextInputType.multiline,
                    maxLines: 3,
                  ),

                  _DropdownProceso(
                    procesos: _procesos,
                    procesoSeleccionado: _procesoSeleccionado,
                    onChanged: (value) {
                      setState(() => _procesoSeleccionado = value);
                    },
                  ),

                  _CampoTexto(
                    label: 'Fecha límite',
                    controller: _fechaController,
                    icono: Icons.calendar_today,
                    tipo: TextInputType.none,
                    readOnly: true,
                    onTap: _seleccionarFecha,
                  ),

                  const SizedBox(height: 24),

                  SizedBox(
                    width: double.infinity,
                    height: 48,
                    child: ElevatedButton(
                      onPressed: _guardando ? null : _crearTarea,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF185FA5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: _guardando
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text(
                              'Crear tarea',
                              style: TextStyle(color: Colors.white),
                            ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _DropdownProceso extends StatelessWidget {
  final List<ProcesoModel> procesos;
  final ProcesoModel? procesoSeleccionado;
  final ValueChanged<ProcesoModel?> onChanged;

  const _DropdownProceso({
    required this.procesos,
    required this.procesoSeleccionado,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade300),
        ),
        child: Row(
          children: [
            const Icon(Icons.account_tree_outlined, color: Color(0xFF185FA5)),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<ProcesoModel>(
                  value: procesoSeleccionado,
                  isExpanded: true,
                  hint: const Text('Selecciona un proceso'),
                  items: procesos.map((proceso) {
                    return DropdownMenuItem<ProcesoModel>(
                      value: proceso,
                      child: Text(proceso.nombre),
                    );
                  }).toList(),
                  onChanged: onChanged,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CampoTexto extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icono;
  final TextInputType tipo;
  final int maxLines;
  final bool readOnly;
  final VoidCallback? onTap;

  const _CampoTexto({
    required this.label,
    required this.controller,
    required this.icono,
    required this.tipo,
    this.maxLines = 1,
    this.readOnly = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: tipo,
        maxLines: maxLines,
        readOnly: readOnly,
        onTap: onTap,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icono, color: const Color(0xFF185FA5)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
