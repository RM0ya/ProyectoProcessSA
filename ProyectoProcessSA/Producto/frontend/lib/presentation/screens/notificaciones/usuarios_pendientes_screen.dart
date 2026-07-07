import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/usuario_provider.dart';
import '../../../data/providers/organizacion_provider.dart';

class UsuariosPendientesScreen extends StatefulWidget {
  const UsuariosPendientesScreen({super.key});

  @override
  State<UsuariosPendientesScreen> createState() =>
      _UsuariosPendientesScreenState();
}

class _UsuariosPendientesScreenState extends State<UsuariosPendientesScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  Future<void> _cargar() async {
    final usuarioProvider = context.read<UsuarioProvider>();
    final orgProvider = context.read<OrganizacionProvider>();

    if (usuarioProvider.token != null) {
      orgProvider.setToken(usuarioProvider.token!);
    }

    await usuarioProvider.cargarPendientes();
    await orgProvider.cargarOrganizaciones();
  }

  void _mostrarSelectorOrganizacion(int idUsuario, String nombreUsuario) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _SelectorOrganizacion(
        idUsuario: idUsuario,
        nombreUsuario: nombreUsuario,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Usuarios pendientes'),
        backgroundColor: const Color(0xFF185FA5),
        foregroundColor: Colors.white,
      ),
      body: Consumer<UsuarioProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.pendientes.isEmpty) {
            return const Center(
              child: Text(
                'No hay usuarios pendientes de asignación',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _cargar,
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: provider.pendientes.length,
              itemBuilder: (context, index) {
                final u = provider.pendientes[index];
                final iniciales =
                    (u.nombre.isNotEmpty ? u.nombre[0] : '') +
                    (u.apellidoP.isNotEmpty ? u.apellidoP[0] : '');

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
                      backgroundColor: Colors.orange,
                      child: Text(
                        iniciales.toUpperCase(),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    title: Text(
                      '${u.nombre} ${u.apellidoP}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                      u.emailUsuario,
                      style: const TextStyle(fontSize: 12),
                    ),
                    trailing: ElevatedButton(
                      onPressed: () => _mostrarSelectorOrganizacion(
                        u.idUsuario!,
                        '${u.nombre} ${u.apellidoP}',
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF185FA5),
                      ),
                      child: const Text(
                        'Asignar',
                        style: TextStyle(color: Colors.white),
                      ),
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

class _SelectorOrganizacion extends StatefulWidget {
  final int idUsuario;
  final String nombreUsuario;

  const _SelectorOrganizacion({
    required this.idUsuario,
    required this.nombreUsuario,
  });

  @override
  State<_SelectorOrganizacion> createState() => _SelectorOrganizacionState();
}

class _SelectorOrganizacionState extends State<_SelectorOrganizacion> {
  int? _orgSeleccionada;
  bool _guardando = false;

  Future<void> _confirmar() async {
    if (_orgSeleccionada == null) return;

    setState(() => _guardando = true);

    final provider = context.read<UsuarioProvider>();
    final ok = await provider.asignarOrganizacion(
      widget.idUsuario,
      _orgSeleccionada!,
    );

    if (!mounted) return;

    setState(() => _guardando = false);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? 'Organización asignada correctamente'
              : provider.error ?? 'Error al asignar',
        ),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final orgProvider = context.watch<OrganizacionProvider>();

    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Asignar organización a ${widget.nombreUsuario}',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 16),
            orgProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
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
                        onChanged: (v) => setState(() => _orgSeleccionada = v),
                      ),
                    ),
                  ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _guardando || _orgSeleccionada == null
                    ? null
                    : _confirmar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF185FA5),
                ),
                child: _guardando
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Confirmar asignación',
                        style: TextStyle(color: Colors.white),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
