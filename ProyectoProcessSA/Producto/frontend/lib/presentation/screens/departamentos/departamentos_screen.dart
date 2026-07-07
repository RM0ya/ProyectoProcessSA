import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/departamento_model.dart';
import '../../../data/providers/departamento_provider.dart';
import '../../../data/providers/organizacion_provider.dart';
import '../../../data/providers/usuario_provider.dart';

class DepartamentosScreen extends StatefulWidget {
  const DepartamentosScreen({super.key});

  @override
  State<DepartamentosScreen> createState() => _DepartamentosScreenState();
}

class _DepartamentosScreenState extends State<DepartamentosScreen> {
  int? _orgSeleccionada;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final usuarioProvider = context.read<UsuarioProvider>();
      final orgProvider = context.read<OrganizacionProvider>();

      if (usuarioProvider.token != null) {
        orgProvider.setToken(usuarioProvider.token!);
        context.read<DepartamentoProvider>().setToken(usuarioProvider.token!);
      }
      orgProvider.cargarOrganizaciones();
    });
  }

  void _seleccionarOrganizacion(int? idOrganizacion) {
    setState(() => _orgSeleccionada = idOrganizacion);
    if (idOrganizacion != null) {
      context.read<DepartamentoProvider>().cargarPorOrganizacion(
        idOrganizacion,
      );
    }
  }

  void _mostrarFormulario({DepartamentoModel? departamento}) {
    if (_orgSeleccionada == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Selecciona una organización primero'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FormularioDepartamento(
        idOrganizacion: _orgSeleccionada!,
        departamentoEditar: departamento,
      ),
    );
  }

  void _confirmarEliminar(DepartamentoModel departamento) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar departamento'),
        content: Text('¿Deseas eliminar "${departamento.nombre}"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);

              final provider = context.read<DepartamentoProvider>();
              final ok = await provider.eliminarDepartamento(
                departamento.idDepartamento,
              );

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok
                        ? 'Departamento eliminado'
                        : provider.error ?? 'Error al eliminar',
                  ),
                  backgroundColor: ok ? Colors.green : Colors.red,
                ),
              );
            },
            child: const Text(
              'Eliminar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orgProvider = context.watch<OrganizacionProvider>();
    final depProvider = context.watch<DepartamentoProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Departamentos',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF185FA5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormulario(),
        backgroundColor: const Color(0xFF185FA5),
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text(
          'Nuevo departamento',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            color: Colors.white,
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Selecciona una organización',
                  style: TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                orgProvider.isLoading
                    ? const Center(
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey.shade50,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade300),
                        ),
                        child: DropdownButtonHideUnderline(
                          child: DropdownButton<int>(
                            value: _orgSeleccionada,
                            isExpanded: true,
                            hint: const Text('Selecciona organización'),
                            items: orgProvider.organizaciones
                                .map(
                                  (o) => DropdownMenuItem<int>(
                                    value: o['idOrganizacion'] as int,
                                    child: Text(o['nombre'] as String),
                                  ),
                                )
                                .toList(),
                            onChanged: _seleccionarOrganizacion,
                          ),
                        ),
                      ),
              ],
            ),
          ),
          Expanded(
            child: _orgSeleccionada == null
                ? const Center(
                    child: Text(
                      'Selecciona una organización para ver sus departamentos',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : depProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : depProvider.departamentos.isEmpty
                ? const Center(
                    child: Text(
                      'No hay departamentos registrados',
                      style: TextStyle(color: Colors.grey),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: depProvider.departamentos.length,
                    itemBuilder: (context, index) {
                      final dep = depProvider.departamentos[index];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.shade200),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: CircleAvatar(
                            backgroundColor: const Color(0xFF185FA5),
                            child: Text(
                              dep.nombre.isNotEmpty
                                  ? dep.nombre[0].toUpperCase()
                                  : '?',
                              style: const TextStyle(color: Colors.white),
                            ),
                          ),
                          title: Text(
                            dep.nombre,
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          subtitle: Text(
                            dep.descripcion,
                            style: const TextStyle(fontSize: 12),
                          ),
                          trailing: PopupMenuButton<String>(
                            onSelected: (value) {
                              if (value == 'editar') {
                                _mostrarFormulario(departamento: dep);
                              } else if (value == 'eliminar') {
                                _confirmarEliminar(dep);
                              }
                            },
                            itemBuilder: (_) => [
                              const PopupMenuItem(
                                value: 'editar',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.edit,
                                      size: 18,
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 8),
                                    Text('Editar'),
                                  ],
                                ),
                              ),
                              const PopupMenuItem(
                                value: 'eliminar',
                                child: Row(
                                  children: [
                                    Icon(
                                      Icons.delete,
                                      size: 18,
                                      color: Colors.red,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Eliminar',
                                      style: TextStyle(color: Colors.red),
                                    ),
                                  ],
                                ),
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
  }
}

class _FormularioDepartamento extends StatefulWidget {
  final int idOrganizacion;
  final DepartamentoModel? departamentoEditar;

  const _FormularioDepartamento({
    required this.idOrganizacion,
    this.departamentoEditar,
  });

  @override
  State<_FormularioDepartamento> createState() =>
      _FormularioDepartamentoState();
}

class _FormularioDepartamentoState extends State<_FormularioDepartamento> {
  final _nombreCtrl = TextEditingController();
  final _descripcionCtrl = TextEditingController();

  bool _guardando = false;

  bool get _esEdicion => widget.departamentoEditar != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      _nombreCtrl.text = widget.departamentoEditar!.nombre;
      _descripcionCtrl.text = widget.departamentoEditar!.descripcion;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _descripcionCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_nombreCtrl.text.trim().isEmpty ||
        _descripcionCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    final provider = context.read<DepartamentoProvider>();

    final ok = _esEdicion
        ? await provider.actualizarDepartamento(
            idDepartamento: widget.departamentoEditar!.idDepartamento,
            nombre: _nombreCtrl.text.trim(),
            descripcion: _descripcionCtrl.text.trim(),
          )
        : await provider.crearDepartamento(
            nombre: _nombreCtrl.text.trim(),
            descripcion: _descripcionCtrl.text.trim(),
            idOrganizacion: widget.idOrganizacion,
          );

    if (!mounted) return;

    setState(() => _guardando = false);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? (_esEdicion
                    ? 'Departamento actualizado'
                    : 'Departamento creado correctamente')
              : provider.error ?? 'Error al guardar',
        ),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(
              _esEdicion ? 'Editar departamento' : 'Nuevo departamento',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nombreCtrl,
              decoration: InputDecoration(
                labelText: 'Nombre *',
                prefixIcon: const Icon(
                  Icons.account_tree_outlined,
                  color: Color(0xFF185FA5),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _descripcionCtrl,
              maxLines: 3,
              decoration: InputDecoration(
                labelText: 'Descripción *',
                prefixIcon: const Icon(Icons.notes, color: Color(0xFF185FA5)),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF185FA5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _guardando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2.5,
                        ),
                      )
                    : Text(
                        _esEdicion ? 'Guardar cambios' : 'Crear departamento',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
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
