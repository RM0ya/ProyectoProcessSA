import 'package:flutter/material.dart';

class TareaDetalleScreen extends StatefulWidget {
  final Map<String, dynamic> tarea;

  const TareaDetalleScreen({super.key, required this.tarea});

  @override
  State<TareaDetalleScreen> createState() => _TareaDetalleScreenState();
}

class _TareaDetalleScreenState extends State<TareaDetalleScreen> {
  final _comentarioController = TextEditingController();
  late List<Map<String, dynamic>> _comentarios;
  late double _progreso;

  @override
  void initState() {
    super.initState();
    _comentarios = List.from(widget.tarea['comentarios']);
    _progreso = widget.tarea['progreso'];
  }

  void _agregarComentario() {
    if (_comentarioController.text.trim().isEmpty) return;
    setState(() {
      _comentarios.add({
        'usuario': 'Sebastián Mardones',
        'iniciales': 'SM',
        'texto': _comentarioController.text.trim(),
        'fecha': 'Ahora',
      });
      widget.tarea['comentarios'] = _comentarios;
    });
    _comentarioController.clear();
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    final tarea = widget.tarea;
    final Color colorEstado = tarea['colorEstado'];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Detalle de tarea',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF185FA5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Header
            Container(
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
                        child: Text(tarea['titulo'],
                            style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600)),
                      ),
                      _Badge(
                          label: tarea['estado'],
                          color: colorEstado),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(tarea['proceso'],
                      style: const TextStyle(
                          fontSize: 12, color: Colors.grey)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Info grid
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              childAspectRatio: 2.5,
              children: [
                _InfoCard(
                    icono: Icons.person_outline,
                    label: 'Responsable',
                    valor: tarea['responsable'],
                    color: const Color(0xFF185FA5)),
                _InfoCard(
                    icono: Icons.flag_outlined,
                    label: 'Prioridad',
                    valor: tarea['prioridad'],
                    color: tarea['colorPrioridad']),
                _InfoCard(
                    icono: Icons.calendar_today,
                    label: 'Fecha límite',
                    valor: tarea['fecha'],
                    color: Colors.orange),
                _InfoCard(
                    icono: Icons.account_tree_outlined,
                    label: 'Proceso',
                    valor: tarea['proceso'],
                    color: Colors.purple),
              ],
            ),

            const SizedBox(height: 12),

            // Progreso
            Container(
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
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Progreso',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      Text('${(_progreso * 100).round()}%',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: colorEstado)),
                    ],
                  ),
                  const SizedBox(height: 10),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(6),
                    child: LinearProgressIndicator(
                      value: _progreso,
                      backgroundColor: Colors.grey.shade200,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(colorEstado),
                      minHeight: 10,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text('Ajustar progreso',
                      style: TextStyle(
                          fontSize: 11, color: Colors.grey)),
                  Slider(
                    value: _progreso,
                    min: 0,
                    max: 1,
                    divisions: 10,
                    activeColor: const Color(0xFF185FA5),
                    onChanged: (valor) {
                      setState(() {
                        _progreso = valor;
                        widget.tarea['progreso'] = valor;
                      });
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Descripción
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Descripción',
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600)),
                  const SizedBox(height: 8),
                  Text(tarea['descripcion'],
                      style: const TextStyle(
                          fontSize: 13,
                          color: Colors.grey,
                          height: 1.5)),
                ],
              ),
            ),

            const SizedBox(height: 12),

            // Comentarios
            Container(
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
                      const Text('Comentarios',
                          style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600)),
                      const SizedBox(width: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE6F1FB),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text('${_comentarios.length}',
                            style: const TextStyle(
                                fontSize: 11,
                                color: Color(0xFF185FA5))),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Lista comentarios
                  if (_comentarios.isEmpty)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 12),
                        child: Text('Sin comentarios aún',
                            style: TextStyle(
                                color: Colors.grey, fontSize: 12)),
                      ),
                    ),
                  ..._comentarios.map((c) => _ComentarioItem(
                        comentario: c,
                      )),

                  const SizedBox(height: 12),
                  const Divider(),
                  const SizedBox(height: 8),

                  // Input nuevo comentario
                  Row(
                    children: [
                      const CircleAvatar(
                        radius: 16,
                        backgroundColor: Color(0xFFE6F1FB),
                        child: Text('SM',
                            style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF185FA5),
                                fontWeight: FontWeight.w600)),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: TextField(
                          controller: _comentarioController,
                          maxLines: null,
                          decoration: InputDecoration(
                            hintText: 'Escribe un comentario...',
                            hintStyle: const TextStyle(
                                fontSize: 12, color: Colors.grey),
                            filled: true,
                            fillColor: Colors.grey.shade50,
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade300),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20),
                              borderSide: BorderSide(
                                  color: Colors.grey.shade300),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      GestureDetector(
                        onTap: _agregarComentario,
                        child: Container(
                          width: 36,
                          height: 36,
                          decoration: const BoxDecoration(
                            color: Color(0xFF185FA5),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.send,
                              size: 16, color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

class _InfoCard extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;
  final Color color;

  const _InfoCard({
    required this.icono,
    required this.label,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(icono, size: 14, color: color),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label,
                    style: const TextStyle(
                        fontSize: 9, color: Colors.grey)),
                Text(valor,
                    style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w500),
                    overflow: TextOverflow.ellipsis),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _ComentarioItem extends StatelessWidget {
  final Map<String, dynamic> comentario;

  const _ComentarioItem({required this.comentario});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 14,
            backgroundColor: const Color(0xFFE6F1FB),
            child: Text(comentario['iniciales'],
                style: const TextStyle(
                    fontSize: 9,
                    color: Color(0xFF185FA5),
                    fontWeight: FontWeight.w600)),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(comentario['usuario'],
                        style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600)),
                    const SizedBox(width: 6),
                    Text(comentario['fecha'],
                        style: const TextStyle(
                            fontSize: 10, color: Colors.grey)),
                  ],
                ),
                const SizedBox(height: 3),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border:
                        Border.all(color: Colors.grey.shade200),
                  ),
                  child: Text(comentario['texto'],
                      style: const TextStyle(
                          fontSize: 12, height: 1.4)),
                ),
              ],
            ),
          ),
        ],
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
      padding:
          const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 10, color: color)),
    );
  }
}