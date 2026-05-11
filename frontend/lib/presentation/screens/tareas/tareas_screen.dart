import 'package:flutter/material.dart';
import 'tarea_detalle_screen.dart';
import 'crear_tarea_screen.dart';

class TareasScreen extends StatefulWidget {
  const TareasScreen({super.key});

  @override
  State<TareasScreen> createState() => _TareasScreenState();
}

class _TareasScreenState extends State<TareasScreen> {
  String _filtroActivo = 'Todos';

  final List<Map<String, dynamic>> _tareas = [
    {
      'id': 1,
      'titulo': 'Revisión contrato cliente A',
      'proceso': 'Onboarding cliente B',
      'responsable': 'Ana López',
      'iniciales': 'AL',
      'estado': 'En curso',
      'prioridad': 'Alta',
      'fecha': '22/04/2026',
      'descripcion': 'Revisar cláusulas del contrato y validar con el área legal antes de la firma.',
      'progreso': 0.6,
      'comentarios': [
        {'usuario': 'Rodrigo Moya', 'iniciales': 'RM', 'texto': 'Falta adjuntar el anexo B.', 'fecha': 'Hoy 09:15'},
      ],
      'colorEstado': Colors.blue,
      'colorPrioridad': Colors.orange,
    },
    {
      'id': 2,
      'titulo': 'Informe mensual RRHH',
      'proceso': 'Auditoría interna Q2',
      'responsable': 'Juan Pérez',
      'iniciales': 'JP',
      'estado': 'Pendiente',
      'prioridad': 'Media',
      'fecha': '25/04/2026',
      'descripcion': 'Generar informe de asistencia y rendimiento del mes de abril.',
      'progreso': 0.0,
      'comentarios': [],
      'colorEstado': Colors.orange,
      'colorPrioridad': Colors.blue,
    },
    {
      'id': 3,
      'titulo': 'Auditoría de accesos',
      'proceso': 'Auditoría interna Q2',
      'responsable': 'María Castro',
      'iniciales': 'MC',
      'estado': 'Completada',
      'prioridad': 'Baja',
      'fecha': '18/04/2026',
      'descripcion': 'Verificar logs de acceso del último trimestre.',
      'progreso': 1.0,
      'comentarios': [
        {'usuario': 'María Castro', 'iniciales': 'MC', 'texto': 'Revisión completada sin incidentes.', 'fecha': 'Ayer 14:00'},
      ],
      'colorEstado': Colors.green,
      'colorPrioridad': Colors.grey,
    },
    {
      'id': 4,
      'titulo': 'Validación base de datos',
      'proceso': 'Rediseño proceso ventas',
      'responsable': 'Paula Vega',
      'iniciales': 'PV',
      'estado': 'Pendiente',
      'prioridad': 'Crítica',
      'fecha': '20/04/2026',
      'descripcion': 'Validar integridad de datos migrados al nuevo esquema SQL.',
      'progreso': 0.2,
      'comentarios': [],
      'colorEstado': Colors.orange,
      'colorPrioridad': Colors.red,
    },
    {
      'id': 5,
      'titulo': 'Reunión con cliente C',
      'proceso': 'Onboarding cliente C',
      'responsable': 'Ana López',
      'iniciales': 'AL',
      'estado': 'Vencida',
      'prioridad': 'Alta',
      'fecha': '15/04/2026',
      'descripcion': 'Reunión de kickoff para presentar el sistema al cliente C.',
      'progreso': 0.0,
      'comentarios': [],
      'colorEstado': Colors.red,
      'colorPrioridad': Colors.orange,
    },
  ];

  List<Map<String, dynamic>> get _tareasFiltradas {
    if (_filtroActivo == 'Todos') return _tareas;
    return _tareas.where((t) => t['estado'] == _filtroActivo).toList();
  }

  void _eliminarTarea(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Eliminar tarea'),
        content: const Text('¿Estás seguro que deseas eliminar esta tarea? Esta acción no se puede deshacer.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _tareas.removeWhere((t) => t['id'] == id));
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tarea eliminada'),
                  backgroundColor: Colors.red,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Eliminar', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _finalizarTarea(int id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Finalizar tarea'),
        content: const Text('¿Confirmas que esta tarea está completada?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() {
                final tarea = _tareas.firstWhere((t) => t['id'] == id);
                tarea['estado'] = 'Completada';
                tarea['colorEstado'] = Colors.green;
                tarea['progreso'] = 1.0;
              });
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Tarea marcada como completada'),
                  backgroundColor: Color(0xFF639922),
                ),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF639922)),
            child: const Text('Confirmar',
                style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Tareas',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF185FA5),
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: ['Todos', 'Pendiente', 'En curso',
                    'Completada', 'Vencida']
                    .map((filtro) => _FiltroChip(
                          label: filtro,
                          activo: _filtroActivo == filtro,
                          onTap: () =>
                              setState(() => _filtroActivo = filtro),
                        ))
                    .toList(),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(
                horizontal: 16, vertical: 10),
            child: Row(
              children: [
                Text('${_tareasFiltradas.length} tareas',
                    style: const TextStyle(
                        color: Colors.grey, fontSize: 13)),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _tareasFiltradas.length,
              itemBuilder: (context, index) {
                final tarea = _tareasFiltradas[index];
                return _TareaCard(
                  tarea: tarea,
                  onEliminar: () => _eliminarTarea(tarea['id']),
                  onFinalizar: () => _finalizarTarea(tarea['id']),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) =>
                            TareaDetalleScreen(tarea: tarea),
                      ),
                    ).then((_) => setState(() {}));
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => CrearTareaScreen(
                onCrear: (nuevaTarea) {
                  setState(() {
                    _tareas.add({
                      ...nuevaTarea,
                      'id': _tareas.length + 1,
                      'comentarios': [],
                      'progreso': 0.0,
                      'colorEstado': Colors.orange,
                      'colorPrioridad': Colors.blue,
                    });
                  });
                },
              ),
            ),
          );
        },
        backgroundColor: const Color(0xFF185FA5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF185FA5),
        currentIndex: 1,
        onTap: (index) {
          if (index == 0) Navigator.pushReplacementNamed(context, '/dashboard');
          else if (index == 2) Navigator.pushReplacementNamed(context, '/procesos');
          else if (index == 3) Navigator.pushReplacementNamed(context, '/perfil');
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tareas'),
          BottomNavigationBarItem(icon: Icon(Icons.account_tree), label: 'Procesos'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _FiltroChip extends StatelessWidget {
  final String label;
  final bool activo;
  final VoidCallback onTap;

  const _FiltroChip({
    required this.label,
    required this.activo,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: activo ? const Color(0xFF185FA5) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: activo ? Colors.white : Colors.grey,
            fontWeight: activo ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ),
    );
  }
}

class _TareaCard extends StatelessWidget {
  final Map<String, dynamic> tarea;
  final VoidCallback onEliminar;
  final VoidCallback onFinalizar;
  final VoidCallback onTap;

  const _TareaCard({
    required this.tarea,
    required this.onEliminar,
    required this.onFinalizar,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool completada = tarea['estado'] == 'Completada';
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(tarea['titulo'],
                      style: const TextStyle(
                          fontSize: 13, fontWeight: FontWeight.w600)),
                ),
                _Badge(label: tarea['estado'], color: tarea['colorEstado']),
              ],
            ),
            const SizedBox(height: 6),
            Text(tarea['proceso'],
                style: const TextStyle(fontSize: 11, color: Colors.grey)),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: tarea['progreso'],
                backgroundColor: Colors.grey.shade200,
                valueColor: AlwaysStoppedAnimation<Color>(
                    tarea['colorEstado']),
                minHeight: 4,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                CircleAvatar(
                  radius: 10,
                  backgroundColor: const Color(0xFFE6F1FB),
                  child: Text(tarea['iniciales'],
                      style: const TextStyle(
                          fontSize: 8,
                          color: Color(0xFF185FA5),
                          fontWeight: FontWeight.w600)),
                ),
                const SizedBox(width: 6),
                Text(tarea['responsable'],
                    style: const TextStyle(fontSize: 11, color: Colors.grey)),
                const Spacer(),
                if (!completada)
                  GestureDetector(
                    onTap: onFinalizar,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: Colors.green.shade50,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: Colors.green.shade200),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.check, size: 11, color: Colors.green),
                          SizedBox(width: 3),
                          Text('Finalizar',
                              style: TextStyle(
                                  fontSize: 10, color: Colors.green)),
                        ],
                      ),
                    ),
                  ),
                const SizedBox(width: 6),
                GestureDetector(
                  onTap: onEliminar,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.red.shade50,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: Colors.red.shade200),
                    ),
                    child: Row(
                      children: const [
                        Icon(Icons.delete_outline,
                            size: 11, color: Colors.red),
                        SizedBox(width: 3),
                        Text('Eliminar',
                            style: TextStyle(
                                fontSize: 10, color: Colors.red)),
                      ],
                    ),
                  ),
                ),
              ],
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
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label, style: TextStyle(fontSize: 10, color: color)),
    );
  }
}