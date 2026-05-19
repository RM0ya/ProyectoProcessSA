import 'package:flutter/material.dart';
import '../../../data/models/proceso_model.dart';
import '../../../data/services/proceso_service.dart';

class ProcesosScreen extends StatefulWidget {
  const ProcesosScreen({super.key});

  @override
  State<ProcesosScreen> createState() => _ProcesosScreenState();
}

class _ProcesosScreenState extends State<ProcesosScreen> {
  final ProcesoService _service = ProcesoService();
  late Future<List<ProcesoModel>> _futureProcesos;

  @override
  void initState() {
    super.initState();
    _cargarProcesos();
  }

  void _cargarProcesos() {
    _futureProcesos = _service.getAll();
  }

  Future<void> _refrescar() async {
    setState(() {
      _cargarProcesos();
    });
  }

  Future<void> _eliminarProceso(int id) async {
    await _service.delete(id);
    await _refrescar();
  }

  Color _colorPorFecha(String fechaLimite) {
    final fecha = DateTime.tryParse(fechaLimite);
    if (fecha == null) return Colors.blue;

    final hoy = DateTime.now();
    if (fecha.isBefore(hoy)) return Colors.red;
    if (fecha.difference(hoy).inDays <= 7) return Colors.orange;
    return Colors.green;
  }

  String _estadoPorFecha(String fechaLimite) {
    final fecha = DateTime.tryParse(fechaLimite);
    if (fecha == null) return 'En curso';

    final hoy = DateTime.now();
    if (fecha.isBefore(hoy)) return 'Vencido';
    if (fecha.difference(hoy).inDays <= 7) return 'En riesgo';
    return 'En curso';
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
              if (proceso.idProceso != null) {
                await _eliminarProceso(proceso.idProceso!);
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Procesos', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF185FA5),
      ),
      body: FutureBuilder<List<ProcesoModel>>(
        future: _futureProcesos,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final procesos = snapshot.data ?? [];

          if (procesos.isEmpty) {
            return const Center(child: Text('No hay procesos registrados'));
          }

          return RefreshIndicator(
            onRefresh: _refrescar,
            child: Column(
              children: [
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      _ResumenChip(
                        label: 'Total',
                        valor: '${procesos.length}',
                        color: const Color(0xFF185FA5),
                      ),
                      const SizedBox(width: 10),
                      _ResumenChip(
                        label: 'Activos',
                        valor: '${procesos.where((p) => _estadoPorFecha(p.fechaLimite) == 'En curso').length}',
                        color: Colors.green,
                      ),
                      const SizedBox(width: 10),
                      _ResumenChip(
                        label: 'Riesgo',
                        valor: '${procesos.where((p) => _estadoPorFecha(p.fechaLimite) == 'En riesgo').length}',
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: procesos.length,
                    itemBuilder: (context, index) {
                      final proceso = procesos[index];
                      final estado = _estadoPorFecha(proceso.fechaLimite);
                      final color = _colorPorFecha(proceso.fechaLimite);

                      return GestureDetector(
                        onTap: () => _abrirFormulario(proceso: proceso),
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
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.black54,
                                ),
                              ),
                              const SizedBox(height: 12),
                              Row(
                                children: [
                                  const Icon(Icons.calendar_today, size: 14, color: Colors.grey),
                                  const SizedBox(width: 5),
                                  Text(
                                    '${proceso.fechaInicio} → ${proceso.fechaLimite}',
                                    style: const TextStyle(
                                      fontSize: 11,
                                      color: Colors.grey,
                                    ),
                                  ),
                                  const Spacer(),
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Color(0xFF185FA5)),
                                    onPressed: () => _abrirFormulario(proceso: proceso),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete_outline, color: Colors.red),
                                    onPressed: () => _confirmarEliminar(proceso),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: const Color(0xFF185FA5),
        onPressed: () => _abrirFormulario(),
        child: const Icon(Icons.add, color: Colors.white),
      ),
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
  final ProcesoService _service = ProcesoService();

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
      _fechaInicioController.text =
          DateTime.now().toIso8601String().split('T').first;
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
      final proceso = ProcesoModel(
        idProceso: widget.proceso?.idProceso,
        nombre: _nombreController.text.trim(),
        descripcionProceso: _descripcionController.text.trim(),
        fechaInicio: _fechaInicioController.text.trim(),
        fechaLimite: _fechaLimiteController.text.trim(),
        fechaCreacion:
            widget.proceso?.fechaCreacion ?? DateTime.now().toIso8601String().split('T').first,
      );

      if (_editando) {
        await _service.update(widget.proceso!.idProceso!, proceso);
      } else {
        await _service.create(proceso);
      }

      if (!mounted) return;
      Navigator.pop(context, true);
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al guardar proceso: $e'),
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
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: TextField(
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
              label: 'Nombre del proceso',
              controller: _nombreController,
              icon: Icons.account_tree_outlined,
            ),
            _campo(
              label: 'Descripción',
              controller: _descripcionController,
              icon: Icons.notes,
              maxLines: 3,
            ),
            _campo(
              label: 'Fecha inicio',
              controller: _fechaInicioController,
              icon: Icons.calendar_month,
              calendario: true,
            ),
            _campo(
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
                onPressed: _guardando ? null : _guardar,
                icon: _guardando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
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

class _ResumenChip extends StatelessWidget {
  final String label;
  final String valor;
  final Color color;

  const _ResumenChip({
    required this.label,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(9),
        ),
        child: Column(
          children: [
            Text(
              valor,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(label, style: const TextStyle(fontSize: 10, color: Colors.grey)),
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