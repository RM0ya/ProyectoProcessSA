import 'package:flutter/material.dart';

class ProcesosScreen extends StatelessWidget {
  const ProcesosScreen({super.key});

  final List<Map<String, dynamic>> _procesos = const [
    {
      'nombre': 'Onboarding cliente B',
      'cliente': 'Cliente B',
      'tareas': 10,
      'completadas': 7,
      'estado': 'En curso',
      'fecha': '30/04/2026',
      'color': Color(0xFF185FA5),
    },
    {
      'nombre': 'Auditoría interna Q2',
      'cliente': 'Interno',
      'tareas': 10,
      'completadas': 4,
      'estado': 'En riesgo',
      'fecha': '15/05/2026',
      'color': Colors.orange,
    },
    {
      'nombre': 'Rediseño proceso ventas',
      'cliente': 'Cliente A',
      'tareas': 8,
      'completadas': 8,
      'estado': 'Completado',
      'fecha': '10/04/2026',
      'color': Colors.green,
    },
    {
      'nombre': 'Onboarding cliente C',
      'cliente': 'Cliente C',
      'tareas': 12,
      'completadas': 2,
      'estado': 'Pendiente',
      'fecha': '20/05/2026',
      'color': Colors.grey,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Procesos', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF185FA5),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: Colors.white),
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                _ResumenChip(
                  label: 'Total',
                  valor: '4',
                  color: const Color(0xFF185FA5),
                ),
                const SizedBox(width: 10),
                _ResumenChip(label: 'En curso', valor: '2', color: Colors.blue),
                const SizedBox(width: 10),
                _ResumenChip(
                  label: 'En riesgo',
                  valor: '1',
                  color: Colors.orange,
                ),
                const SizedBox(width: 10),
                _ResumenChip(label: 'Listos', valor: '1', color: Colors.green),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _procesos.length,
              itemBuilder: (context, index) {
                final proceso = _procesos[index];
                final porcentaje = proceso['completadas'] / proceso['tareas'];
                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
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
                            child: Text(
                              proceso['nombre'],
                              style: const TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: (proceso['color'] as Color).withOpacity(
                                0.1,
                              ),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              proceso['estado'],
                              style: TextStyle(
                                fontSize: 10,
                                color: proceso['color'],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        proceso['cliente'],
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(4),
                              child: LinearProgressIndicator(
                                value: porcentaje,
                                backgroundColor: Colors.grey.shade200,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  proceso['color'],
                                ),
                                minHeight: 6,
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Text(
                            '${(porcentaje * 100).round()}%',
                            style: TextStyle(
                              fontSize: 11,
                              color: proceso['color'],
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: [
                          Icon(Icons.task_alt, size: 12, color: Colors.grey),
                          const SizedBox(width: 4),
                          Text(
                            '${proceso['completadas']} de ${proceso['tareas']} tareas',
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                          const Spacer(),
                          Icon(
                            Icons.calendar_today,
                            size: 12,
                            color: Colors.grey,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            proceso['fecha'],
                            style: const TextStyle(
                              fontSize: 11,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {},
        backgroundColor: const Color(0xFF185FA5),
        child: const Icon(Icons.add, color: Colors.white),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF185FA5),
        currentIndex: 2,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/tareas');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/perfil');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tareas'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_tree),
            label: 'Procesos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
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
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Text(
              valor,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: color,
              ),
            ),
            Text(
              label,
              style: const TextStyle(fontSize: 10, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }
}
