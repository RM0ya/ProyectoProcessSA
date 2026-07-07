import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/organizacion_provider.dart';
import '../../../data/providers/usuario_provider.dart';

class OrganizacionesScreen extends StatefulWidget {
  const OrganizacionesScreen({super.key});

  @override
  State<OrganizacionesScreen> createState() => _OrganizacionesScreenState();
}

class _OrganizacionesScreenState extends State<OrganizacionesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final usuarioProvider = context.read<UsuarioProvider>();
      final orgProvider = context.read<OrganizacionProvider>();

      if (usuarioProvider.token != null) {
        orgProvider.setToken(usuarioProvider.token!);
      }
      orgProvider.cargarOrganizaciones();
    });
  }

  void _mostrarFormulario({Map<String, dynamic>? organizacion}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FormularioOrganizacion(organizacionEditar: organizacion),
    );
  }

  void _confirmarEliminar(Map<String, dynamic> organizacion) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar organización'),
        content: Text(
          '¿Deseas eliminar "${organizacion['nombre']}"? Esta acción no se puede deshacer.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);

              final provider = context.read<OrganizacionProvider>();
              final ok = await provider.eliminarOrganizacion(
                organizacion['idOrganizacion'] as int,
              );

              if (!mounted) return;

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    ok
                        ? 'Organización eliminada'
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
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Organizaciones',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF185FA5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormulario(),
        backgroundColor: const Color(0xFF185FA5),
        icon: const Icon(Icons.add_business, color: Colors.white),
        label: const Text(
          'Nueva organización',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Consumer<OrganizacionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.organizaciones.isEmpty) {
            return const Center(
              child: Text(
                'No hay organizaciones registradas',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: provider.cargarOrganizaciones,
            child: ListView.builder(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              itemCount: provider.organizaciones.length,
              itemBuilder: (context, index) {
                final org = provider.organizaciones[index];

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
                        (org['nombre'] as String?)?.isNotEmpty == true
                            ? (org['nombre'] as String)[0].toUpperCase()
                            : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      org['nombre']?.toString() ?? 'Sin nombre',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      org['emailContacto']?.toString() ?? '',
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: PopupMenuButton<String>(
                      onSelected: (value) {
                        if (value == 'editar') {
                          _mostrarFormulario(organizacion: org);
                        } else if (value == 'eliminar') {
                          _confirmarEliminar(org);
                        }
                      },
                      itemBuilder: (_) => [
                        const PopupMenuItem(
                          value: 'editar',
                          child: Row(
                            children: [
                              Icon(Icons.edit, size: 18, color: Colors.blue),
                              SizedBox(width: 8),
                              Text('Editar'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'eliminar',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
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
          );
        },
      ),
    );
  }
}

class _FormularioOrganizacion extends StatefulWidget {
  final Map<String, dynamic>? organizacionEditar;

  const _FormularioOrganizacion({this.organizacionEditar});

  @override
  State<_FormularioOrganizacion> createState() =>
      _FormularioOrganizacionState();
}

class _FormularioOrganizacionState extends State<_FormularioOrganizacion> {
  final _nombreCtrl = TextEditingController();
  final _rutCtrl = TextEditingController();
  final _dvCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();

  bool _guardando = false;

  bool get _esEdicion => widget.organizacionEditar != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      final o = widget.organizacionEditar!;
      _nombreCtrl.text = o['nombre']?.toString() ?? '';
      _rutCtrl.text = o['rut']?.toString() ?? '';
      _dvCtrl.text = o['dv']?.toString() ?? '';
      _emailCtrl.text = o['emailContacto']?.toString() ?? '';
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _rutCtrl.dispose();
    _dvCtrl.dispose();
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_nombreCtrl.text.trim().isEmpty ||
        _rutCtrl.text.trim().isEmpty ||
        _dvCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Completa todos los campos'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    setState(() => _guardando = true);

    final provider = context.read<OrganizacionProvider>();

    final data = {
      'nombre': _nombreCtrl.text.trim(),
      'rut': int.tryParse(_rutCtrl.text.trim()) ?? 0,
      'dv': _dvCtrl.text.trim(),
      'emailContacto': _emailCtrl.text.trim(),
      'estado': 'Activo',
      'fechaCreacion': DateTime.now().toIso8601String().split('T').first,
    };

    final ok = _esEdicion
        ? await provider.actualizarOrganizacion(
            widget.organizacionEditar!['idOrganizacion'] as int,
            data,
          )
        : await provider.crearOrganizacion(data);

    if (!mounted) return;

    setState(() => _guardando = false);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? (_esEdicion
                  ? 'Organización actualizada'
                  : 'Organización creada correctamente')
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
              _esEdicion ? 'Editar organización' : 'Nueva organización',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nombreCtrl,
              decoration: _decoracion('Nombre *', Icons.business),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  flex: 3,
                  child: TextField(
                    controller: _rutCtrl,
                    keyboardType: TextInputType.number,
                    decoration: _decoracion('RUT *', Icons.badge_outlined),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  flex: 1,
                  child: TextField(
                    controller: _dvCtrl,
                    maxLength: 1,
                    decoration: _decoracion('DV *', null).copyWith(
                      counterText: '',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              decoration: _decoracion(
                'Correo de contacto *',
                Icons.email_outlined,
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
                        _esEdicion ? 'Guardar cambios' : 'Crear organización',
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

  InputDecoration _decoracion(String label, IconData? icono) {
    return InputDecoration(
      labelText: label,
      prefixIcon: icono != null
          ? Icon(icono, color: const Color(0xFF185FA5), size: 20)
          : null,
      filled: true,
      fillColor: Colors.grey.shade50,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: Colors.grey.shade300),
      ),
    );
  }
}