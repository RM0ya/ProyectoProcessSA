import 'package:flutter/material.dart';

import 'crear_tarea_screen.dart';
import 'tarea_detalle_screen.dart';
import '../../../data/models/tarea_model.dart';
import '../../../data/services/tarea_service.dart';

class TareasScreen extends StatefulWidget {
  final Future<List<TareaModel>>? tareasFutureOverride;

  const TareasScreen({super.key, this.tareasFutureOverride});

  @override
  State<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  final TareaService _service = TareaService();
  late Future<List<TareaModel>> _futureTareas;

  final bool esAdmin = true;
  final int idUsuario = 1;

  @override
  void initState() {
    super.initState();
    _cargarTareas();
  }

  void _cargarTareas() {
    if (widget.tareasFutureOverride != null) {
      _futureTareas = widget.tareasFutureOverride!;
      return;
    }

    if (esAdmin) {
      _futureTareas = _service.getAll();
    } else {
      _futureTareas = _service.getByUsuario(idUsuario);
    }
  }

  Future<void> _refrescar() async {
    setState(() {
      _cargarTareas();
    });
  }

  Future<void> _eliminarTarea(int id) async {
    await _service.delete(id);
    await _refrescar();
  }

  Color _colorEstado(String estado) {
    switch (estado.toLowerCase()) {
      case 'completada':
      case 'completado':
        return Colors.green;
      case 'activo':
      case 'activa':
      case 'en curso':
        return Colors.blue;
      case 'vencida':
      case 'inactivo':
      case 'inactiva':
        return Colors.red;
      default:
        return Colors.orange;
    }
  }

  String _iniciales(String nombre) {
    final partes = nombre.trim().split(' ');
    return partes.take(2).map((e) => e.isNotEmpty ? e[0] : '').join();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Tareas', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF185FA5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FutureBuilder<List<TareaModel>>(
        future: _futureTareas,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(
              child: Text('Error al cargar tareas: ${snapshot.error}'),
            );
          }

          final tareas = snapshot.data ?? [];

          if (tareas.isEmpty) {
            return const Center(child: Text('No hay tareas registradas'));
          }

          return RefreshIndicator(
            onRefresh: _refrescar,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: tareas.length,
              itemBuilder: (context, index) {
                final tarea = tareas[index];
                final estado = tarea.nombreEstado ?? 'Pendiente';
                final proceso = tarea.nombreProceso ?? 'Sin proceso';
                final usuario = tarea.nombreUsuario ?? 'Sin usuario';

                return GestureDetector(
                  onTap: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => TareaDetalleScreen(tarea: tarea),
                      ),
                    );
                    await _refrescar();
                  },
                  child: Container(
                    key: Key('tareaItem_${tarea.idTarea}'),
                    margin: const EdgeInsets.only(bottom: 12),
                    padding: const EdgeInsets.all(14),
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
                                tarea.nombreTarea,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ),
                            _Badge(label: estado, color: _colorEstado(estado)),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text(
                          proceso,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          tarea.descripcionT,
                          style: const TextStyle(fontSize: 13),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 12,
                              backgroundColor: const Color(0xFFE6F1FB),
                              child: Text(
                                _iniciales(usuario),
                                style: const TextStyle(
                                  fontSize: 9,
                                  color: Color(0xFF185FA5),
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                usuario,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              tarea.fechaLimiteS,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                              ),
                            ),
                            const SizedBox(width: 10),
                            IconButton(
                              key: Key('eliminarTarea_${tarea.idTarea}'),
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.red,
                              ),
                              onPressed: () {
                                if (tarea.idTarea != null) {
                                  _eliminarTarea(tarea.idTarea!);
                                }
                              },
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        key: const Key('crearTareaFab'),
        backgroundColor: const Color(0xFF185FA5),
        child: const Icon(Icons.add, color: Colors.white),
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CrearTareaScreen()),
          );
          await _refrescar();
        },
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
      key: Key('estadoBadge_$label'),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label, style: TextStyle(fontSize: 11, color: color)),
    );
  }
}
