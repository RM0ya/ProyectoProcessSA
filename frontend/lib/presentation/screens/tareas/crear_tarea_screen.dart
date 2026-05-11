import 'package:flutter/material.dart';

class CrearTareaScreen extends StatefulWidget {
  final Function(Map<String, dynamic>) onCrear;

  const CrearTareaScreen({super.key, required this.onCrear});

  @override
  State<CrearTareaScreen> createState() => _CrearTareaScreenState();
}

class _CrearTareaScreenState extends State<CrearTareaScreen> {
  final _tituloController = TextEditingController();
  final _descripcionController = TextEditingController();
  final _fechaController = TextEditingController();

  String _prioridadSeleccionada = 'Media';
  String _responsableSeleccionado = 'Ana López';
  String _procesoSeleccionado = 'Onboarding cliente B';
  bool _guardando = false;

  final List<String> _prioridades = ['Baja', 'Media', 'Alta', 'Crítica'];
  final List<String> _responsables = [
    'Ana López',
    'Juan Pérez',
    'María Castro',
    'Paula Vega',
    'Rodrigo Moya',
  ];
  final List<String> _procesos = [
    'Onboarding cliente B',
    'Auditoría interna Q2',
    'Rediseño proceso ventas',
    'Onboarding cliente C',
  ];

  Color _colorPrioridad(String prioridad) {
    switch (prioridad) {
      case 'Crítica': return Colors.red;
      case 'Alta': return Colors.orange;
      case 'Media': return Colors.blue;
      default: return Colors.grey;
    }
  }

  void _crearTarea() async {
    if (_tituloController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El título es obligatorio'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }
    if (_fechaController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('La fecha límite es obligatoria'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _guardando = true);
    await Future.delayed(const Duration(seconds: 1));

    final iniciales = _responsableSeleccionado
        .split(' ')
        .map((p) => p[0])
        .take(2)
        .join();

    widget.onCrear({
      'titulo': _tituloController.text.trim(),
      'proceso': _procesoSeleccionado,
      'responsable': _responsableSeleccionado,
      'iniciales': iniciales,
      'estado': 'Pendiente',
      'prioridad': _prioridadSeleccionada,
      'fecha': _fechaController.text.trim(),
      'descripcion': _descripcionController.text.trim().isEmpty
          ? 'Sin descripción.'
          : _descripcionController.text.trim(),
      'colorPrioridad': _colorPrioridad(_prioridadSeleccionada),
    });

    setState(() => _guardando = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tarea creada correctamente'),
          backgroundColor: Color(0xFF639922),
        ),
      );
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Nueva tarea',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF185FA5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            _SeccionTitulo(titulo: 'Información de la tarea'),

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

            _CampoTexto(
              label: 'Fecha límite (dd/mm/aaaa)',
              controller: _fechaController,
              icono: Icons.calendar_today,
              tipo: TextInputType.datetime,
            ),

            _SeccionTitulo(titulo: 'Asignación'),

            _Dropdown(
              label: 'Responsable',
              icono: Icons.person_outline,
              valor: _responsableSeleccionado,
              opciones: _responsables,
              onChanged: (v) =>
                  setState(() => _responsableSeleccionado = v!),
            ),

            _Dropdown(
              label: 'Proceso',
              icono: Icons.account_tree_outlined,
              valor: _procesoSeleccionado,
              opciones: _procesos,
              onChanged: (v) =>
                  setState(() => _procesoSeleccionado = v!),
            ),

            _SeccionTitulo(titulo: 'Prioridad'),

            Row(
              children: _prioridades.map((p) {
                final seleccionado = _prioridadSeleccionada == p;
                final color = _colorPrioridad(p);
                return GestureDetector(
                  onTap: () =>
                      setState(() => _prioridadSeleccionada = p),
                  child: Container(
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: seleccionado
                          ? color
                          : color.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: seleccionado
                            ? color
                            : color.withOpacity(0.3),
                      ),
                    ),
                    child: Text(p,
                        style: TextStyle(
                            fontSize: 12,
                            color: seleccionado
                                ? Colors.white
                                : color,
                            fontWeight: FontWeight.w500)),
                  ),
                );
              }).toList(),
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
                    ? const CircularProgressIndicator(
                        color: Colors.white)
                    : const Text('Crear tarea',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600)),
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.grey.shade100,
                  foregroundColor: Colors.grey.shade700,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
                child: const Text('Cancelar',
                    style: TextStyle(fontSize: 16)),
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
      child: Text(titulo,
          style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF185FA5))),
    );
  }
}

class _CampoTexto extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icono;
  final TextInputType tipo;
  final int maxLines;

  const _CampoTexto({
    required this.label,
    required this.controller,
    required this.icono,
    required this.tipo,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: tipo,
        maxLines: maxLines,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: Icon(icono, color: const Color(0xFF185FA5)),
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: BorderSide(color: Colors.grey.shade300),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
                color: Color(0xFF185FA5), width: 2),
          ),
        ),
      ),
    );
  }
}

class _Dropdown extends StatelessWidget {
  final String label;
  final IconData icono;
  final String valor;
  final List<String> opciones;
  final ValueChanged<String?> onChanged;

  const _Dropdown({
    required this.label,
    required this.icono,
    required this.valor,
    required this.opciones,
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
            Icon(icono, color: const Color(0xFF185FA5), size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: valor,
                  isExpanded: true,
                  icon: const Icon(Icons.keyboard_arrow_down,
                      color: Color(0xFF185FA5)),
                  style: const TextStyle(
                      fontSize: 13, color: Colors.black87),
                  onChanged: onChanged,
                  items: opciones
                      .map((o) => DropdownMenuItem(
                            value: o,
                            child: Text(o),
                          ))
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}