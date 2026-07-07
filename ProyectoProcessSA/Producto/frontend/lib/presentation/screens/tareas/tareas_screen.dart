import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'crear_tarea_screen.dart';
import 'tarea_detalle_screen.dart';
import '../../../data/models/tarea_model.dart';
import '../../../data/services/tarea_service.dart';
import '../../../data/providers/usuario_provider.dart';

class TareasScreen extends StatefulWidget {
  final Future<List<TareaModel>>? tareasFutureOverride;

  const TareasScreen({super.key, this.tareasFutureOverride});

  @override
  State<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen>
    with SingleTickerProviderStateMixin {
  late Future<List<TareaModel>> _futureTareas = Future.value([]);
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          _cargarTareas();
        });
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _cargarTareas() {
    if (widget.tareasFutureOverride != null) {
      _futureTareas = widget.tareasFutureOverride!;
      return;
    }

    final usuarioProvider = context.read<UsuarioProvider>();
    final service = TareaService(token: usuarioProvider.token);
    final esAdmin = usuarioProvider.esAdmin;
    final idUsuario = usuarioProvider.usuarioLogueado?.idUsuario;
    final idOrganizacion =
        usuarioProvider.usuarioLogueado?.organizacion?['idOrganizacion'];

    if (esAdmin && idOrganizacion != null) {
      _futureTareas = service.getByOrganizacion(idOrganizacion as int);
    } else if (idUsuario != null) {
      _futureTareas = service.getByUsuario(idUsuario);
    } else {
      _futureTareas = Future.value([]);
    }
  }

  Future<void> _refrescar() async {
    setState(() {
      _cargarTareas();
    });
  }

  Future<void> _eliminarTarea(int id) async {
    final usuarioProvider = context.read<UsuarioProvider>();
    final service = TareaService(token: usuarioProvider.token);

    try {
      await service.delete(id);
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

  bool _puedeGestionar(TareaModel tarea, UsuarioProvider usuarioProvider) {
    if (usuarioProvider.esAdmin) return true;

    final esDueno =
        tarea.idUsuario == usuarioProvider.usuarioLogueado?.idUsuario;
    final estaCompletada =
        (tarea.nombreEstado ?? '').toLowerCase() == 'completada';

    return esDueno && !estaCompletada;
  }

  bool _estaCompletada(TareaModel tarea) {
    return (tarea.nombreEstado ?? '').toLowerCase() == 'completada';
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

  Widget _listaVacia(String mensaje) {
    return Center(
      child: Text(mensaje, style: const TextStyle(color: Colors.grey)),
    );
  }

  Widget _buildLista(List<TareaModel> tareas, UsuarioProvider usuarioProvider) {
    if (tareas.isEmpty) {
      return _listaVacia('No hay tareas para mostrar');
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
          final puedeGestionar = _puedeGestionar(tarea, usuarioProvider);

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
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
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
                      if (puedeGestionar) ...[
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
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = context.watch<UsuarioProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Tareas', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF185FA5),
        iconTheme: const IconThemeData(color: Colors.white),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: const [
            Tab(text: 'Activas'),
            Tab(text: 'Historial'),
          ],
        ),
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
          final activas = tareas.where((t) => !_estaCompletada(t)).toList();
          final completadas = tareas.where(_estaCompletada).toList();

          return TabBarView(
            controller: _tabController,
            children: [
              activas.isEmpty
                  ? _listaVacia('No hay tareas activas')
                  : _buildLista(activas, usuarioProvider),
              completadas.isEmpty
                  ? _listaVacia('No hay tareas completadas todavía')
                  : _buildLista(completadas, usuarioProvider),
            ],
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
