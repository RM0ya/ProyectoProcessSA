import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/proceso_model.dart';
import '../../../data/models/estado_model.dart';
import '../../../data/services/proceso_service.dart';
import '../../../data/services/estado_service.dart';
import '../../../data/providers/usuario_provider.dart';

class ProcesosScreen extends StatefulWidget {
  const ProcesosScreen({super.key});

  @override
  State<ProcesosScreen> createState() => _ProcesosScreenState();
}

class _ProcesosScreenState extends State<ProcesosScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<ProcesoModel>> _futureProcesos = Future.value([]);
  TabController? _tabController;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        final usuarioProvider = context.read<UsuarioProvider>();
        final esGestor =
            usuarioProvider.esAdmin || usuarioProvider.esSuperAdmin;

        setState(() {
          _tabController = TabController(length: esGestor ? 2 : 1, vsync: this);
          _cargarProcesos();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController?.dispose();
    super.dispose();
  }

  void _cargarProcesos() {
    final usuarioProvider = context.read<UsuarioProvider>();
    final service = ProcesoService(token: usuarioProvider.token);
    final idOrganizacion =
        usuarioProvider.usuarioLogueado?.organizacion?['idOrganizacion'];

    if (idOrganizacion != null) {
      // El backend ya filtra: Usuario normal recibe solo activos,
      // Admin/SuperAdmin reciben todo incluyendo completados.
      _futureProcesos = service.getByOrganizacion(idOrganizacion as int);
    } else {
      _futureProcesos = Future.value([]);
    }
  }

  Future<void> _refrescar() async {
    setState(() {
      _cargarProcesos();
    });
  }

  bool _estaCompletado(ProcesoModel proceso) {
    return (proceso.nombreEstado ?? '').toLowerCase() == 'completada';
  }

  Future<bool> _eliminarProceso(int id) async {
    try {
      final usuarioProvider = context.read<UsuarioProvider>();
      final service = ProcesoService(token: usuarioProvider.token);
      await service.delete(id);
      await _refrescar();
      return true;
    } catch (e) {
      if (!mounted) return false;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );

      return false;
    }
  }

  Future<void> _cambiarEstado(ProcesoModel proceso) async {
    final usuarioProvider = context.read<UsuarioProvider>();
    final estadoService = EstadoService(token: usuarioProvider.token);
    final procesoService = ProcesoService(token: usuarioProvider.token);

    List<EstadoModel> estados;
    try {
      estados = await estadoService.getAll();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al cargar estados: $e')));
      return;
    }

    // Solo mostramos los 3 estados relevantes para procesos.
    final estadosValidos = estados
        .where(
          (e) =>
              ['Activo', 'En revisión', 'Completada'].contains(e.nombreEstado),
        )
        .toList();

    if (!mounted) return;

    final nuevoEstado = await showModalBottomSheet<EstadoModel>(
      context: context,
      builder: (_) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: estadosValidos
              .map(
                (e) => ListTile(
                  title: Text(e.nombreEstado),
                  onTap: () => Navigator.pop(context, e),
                ),
              )
              .toList(),
        ),
      ),
    );

    if (nuevoEstado == null) return;

    try {
      await procesoService.updateEstado(
        proceso.idProceso!,
        nuevoEstado.idEstado!,
      );
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Estado actualizado a "${nuevoEstado.nombreEstado}"'),
          backgroundColor: Colors.green,
        ),
      );
      await _refrescar();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceFirst('Exception: ', '')),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Color _colorPorEstado(String? nombreEstado) {
    switch (nombreEstado) {
      case 'Completada':
        return Colors.green;
      case 'En revisión':
        return Colors.orange;
      default:
        return Colors.blue;
    }
  }

  void _confirmarEliminar(ProcesoModel proceso) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar proceso'),
        content: Text('¿Deseas eliminar "${proceso.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);

              if (proceso.idProceso == null) return;

              final ok = await _eliminarProceso(proceso.idProceso!);

              if (!mounted) return;

              if (ok) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Proceso eliminado correctamente'),
                    backgroundColor: Colors.green,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _abrirFormulario({ProcesoModel? proceso}) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => CrearEditarProcesoScreen(proceso: proceso),
      ),
    ).then((_) => _refrescar());
  }

  Widget _tarjetaProceso(ProcesoModel proceso, int index, bool esGestor) {
    final estado = proceso.nombreEstado ?? 'Activo';
    final color = _colorPorEstado(estado);

    return GestureDetector(
      key: Key('procesoCard_$index'),
      onTap: esGestor ? () => _abrirFormulario(proceso: proceso) : null,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    proceso.nombre,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                _Badge(label: estado, color: color),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              proceso.descripcionProceso,
              style: const TextStyle(fontSize: 12, color: Colors.black54),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                const SizedBox(width: 5),
                Text(
                  '${proceso.fechaInicio} → ${proceso.fechaLimite}',
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const Spacer(),
                if (esGestor) ...[
                  IconButton(
                    icon: const Icon(Icons.flag_outlined, color: Colors.orange),
                    tooltip: 'Cambiar estado',
                    onPressed: () => _cambiarEstado(proceso),
                  ),
                  IconButton(
                    key: Key('procesoEditarButton_$index'),
                    icon: const Icon(Icons.edit, color: Color(0xFF185FA5)),
                    onPressed: () => _abrirFormulario(proceso: proceso),
                  ),
                  IconButton(
                    key: Key('procesoEliminarButton_$index'),
                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                    onPressed: () => _confirmarEliminar(proceso),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = context.watch<UsuarioProvider>();
    final esGestor = usuarioProvider.esAdmin || usuarioProvider.esSuperAdmin;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Procesos', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF185FA5),
        bottom: _tabController == null
            ? null
            : TabBar(
                controller: _tabController,
                indicatorColor: Colors.white,
                labelColor: Colors.white,
                unselectedLabelColor: Colors.white70,
                tabs: esGestor
                    ? const [Tab(text: 'Activos'), Tab(text: 'Historial')]
                    : const [Tab(text: 'Activos')],
              ),
      ),
      body: _tabController == null
          ? const Center(child: CircularProgressIndicator())
          : FutureBuilder<List<ProcesoModel>>(
              future: _futureProcesos,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                final procesos = snapshot.data ?? [];
                final activos = procesos
                    .where((p) => !_estaCompletado(p))
                    .toList();
                final completados = procesos.where(_estaCompletado).toList();

                Widget listaActivos = activos.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay procesos activos',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refrescar,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: activos.length,
                          itemBuilder: (context, index) =>
                              _tarjetaProceso(activos[index], index, esGestor),
                        ),
                      );

                if (!esGestor) {
                  return listaActivos;
                }

                Widget listaHistorial = completados.isEmpty
                    ? const Center(
                        child: Text(
                          'No hay procesos completados todavía',
                          style: TextStyle(color: Colors.grey),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _refrescar,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: completados.length,
                          itemBuilder: (context, index) => _tarjetaProceso(
                            completados[index],
                            index + 1000,
                            esGestor,
                          ),
                        ),
                      );

                return TabBarView(
                  controller: _tabController,
                  children: [listaActivos, listaHistorial],
                );
              },
            ),
      floatingActionButton: esGestor
          ? FloatingActionButton(
              key: const Key('nuevoProcesoButton'),
              backgroundColor: const Color(0xFF185FA5),
              onPressed: () => _abrirFormulario(),
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }
}

class CrearEditarProcesoScreen extends StatefulWidget {
  final ProcesoModel? proceso;

  const CrearEditarProcesoScreen({super.key, this.proceso});

  @override
  State<CrearEditarProcesoScreen> createState() =>
      _CrearEditarProcesoScreenState();
}

class _CrearEditarProcesoScreenState extends State<CrearEditarProcesoScreen> {
  final _nombreController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _fechaInicioController = TextEditingController();
  final _fechaLimiteController = TextEditingController();

  bool _guardando = false;

  bool get _editando => widget.proceso != null;

  @override
  void initState() {
    super.initState();

    final p = widget.proceso;

    if (p != null) {
      _nombreController.text = p.nombre;
      _descripcionController.text = p.descripcionProceso;
      _fechaInicioController.text = p.fechaInicio;
      _fechaLimiteController.text = p.fechaLimite;
    } else {
      _fechaInicioController.text = DateTime.now()
          .toIso8601String()
          .split('T')
          .first;
    }
  }

  Future<void> _seleccionarFecha(TextEditingController controller) async {
    final inicial = DateTime.tryParse(controller.text) ?? DateTime.now();

    final seleccionada = await showDatePicker(
      context: context,
      initialDate: inicial,
      firstDate: DateTime(2024),
      lastDate: DateTime(2035),
    );

    if (seleccionada == null) return;

    setState(() {
      controller.text = seleccionada.toIso8601String().split('T').first;
    });
  }

  Future<void> _guardar() async {
    if (_nombreController.text.trim().isEmpty ||
        _descripcionController.text.trim().isEmpty ||
        _fechaInicioController.text.trim().isEmpty ||
        _fechaLimiteController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Completa todos los campos')),
      );
      return;
    }

    setState(() => _guardando = true);

    try {
      final usuarioProvider = context.read<UsuarioProvider>();
      final service = ProcesoService(token: usuarioProvider.token);
      final idOrganizacion =
          usuarioProvider.usuarioLogueado?.organizacion?['idOrganizacion']
              as int?;

      final proceso = ProcesoModel(
        idProceso: widget.proceso?.idProceso,
        nombre: _nombreController.text.trim(),
        descripcionProceso: _descripcionController.text.trim(),
        fechaInicio: _fechaInicioController.text.trim(),
        fechaLimite: _fechaLimiteController.text.trim(),
        fechaCreacion:
            widget.proceso?.fechaCreacion ??
            DateTime.now().toIso8601String().split('T').first,
        idOrganizacion: widget.proceso?.idOrganizacion ?? idOrganizacion,
        idEstado: widget.proceso?.idEstado ?? 1,
      );

      if (_editando) {
        await service.update(widget.proceso!.idProceso!, proceso);
      } else {
        await service.create(proceso);
      }

      if (!mounted) return;
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
      if (mounted) setState(() => _guardando = false);
    }
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _descripcionController.dispose();
    _fechaInicioController.dispose();
    _fechaLimiteController.dispose();
    super.dispose();
  }

  Widget _campo({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    int maxLines = 1,
    bool calendario = false,
    Key? fieldKey,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
        key: fieldKey,
        controller: controller,
        maxLines: maxLines,
        readOnly: calendario,
        onTap: calendario ? () => _seleccionarFecha(controller) : null,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icon, color: const Color(0xFF185FA5)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(14)),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text(
          _editando ? 'Editar proceso' : 'Nuevo proceso',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF185FA5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            _campo(
              fieldKey: const Key('procesoNombreField'),
              label: 'Nombre del proceso',
              controller: _nombreController,
              icon: Icons.account_tree_outlined,
            ),
            _campo(
              fieldKey: const Key('procesoDescripcionField'),
              label: 'Descripción',
              controller: _descripcionController,
              icon: Icons.notes,
              maxLines: 3,
            ),
            _campo(
              fieldKey: const Key('procesoFechaInicioField'),
              label: 'Fecha inicio',
              controller: _fechaInicioController,
              icon: Icons.calendar_month,
              calendario: true,
            ),
            _campo(
              fieldKey: const Key('procesoFechaLimiteField'),
              label: 'Fecha límite',
              controller: _fechaLimiteController,
              icon: Icons.event_available,
              calendario: true,
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton.icon(
                key: const Key('guardarProcesoButton'),
                onPressed: _guardando ? null : _guardar,
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
                  _guardando ? 'Guardando...' : 'Guardar proceso',
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

  const _Badge({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color)),
    );
  }
}
