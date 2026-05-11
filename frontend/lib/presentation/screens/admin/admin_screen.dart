import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/usuario_model.dart';
import '../../../data/providers/usuario_provider.dart';

class AdminScreen extends StatefulWidget {
  const AdminScreen({super.key});

  @override
  State<AdminScreen> createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<UsuarioProvider>(context, listen: false).cargarUsuarios();
    });
  }

  void _mostrarFormulario({UsuarioModel? usuario}) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FormularioUsuario(usuarioEditar: usuario),
    );
  }

  void _confirmarEliminar(BuildContext context, UsuarioModel usuario) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Eliminar usuario'),
        content: Text(
            '¿Estás seguro de eliminar a ${usuario.nombre} ${usuario.apellidoP}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              final provider =
                  Provider.of<UsuarioProvider>(context, listen: false);
              final ok =
                  await provider.eliminarUsuario(usuario.idUsuario!);
              if (mounted) {
                ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                  content: Text(ok
                      ? 'Usuario eliminado'
                      : provider.error ?? 'Error al eliminar'),
                  backgroundColor: ok ? Colors.green : Colors.red,
                ));
              }
            },
            child: const Text('Eliminar',
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
        title: const Text('Administración'),
        backgroundColor: const Color(0xFF185FA5),
        foregroundColor: Colors.white,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _mostrarFormulario(),
        backgroundColor: const Color(0xFF185FA5),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label:
            const Text('Nuevo usuario', style: TextStyle(color: Colors.white)),
      ),
      body: Consumer<UsuarioProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.usuarios.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.people_outline, size: 60, color: Colors.grey),
                  SizedBox(height: 12),
                  Text('No hay usuarios registrados',
                      style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 80),
            itemCount: provider.usuarios.length,
            itemBuilder: (context, index) {
              final u = provider.usuarios[index];
              final esYo = u.idUsuario ==
                  provider.usuarioLogueado?.idUsuario;
              final rolNombre =
                  u.rol?['nombre']?.toString() ?? 'Sin rol';
              final iniciales = (u.nombre.isNotEmpty
                      ? u.nombre[0]
                      : '') +
                  (u.apellidoP.isNotEmpty ? u.apellidoP[0] : '');

              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: esYo
                        ? const Color(0xFF185FA5).withOpacity(0.4)
                        : Colors.grey.shade200,
                    width: esYo ? 1.5 : 1,
                  ),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: const Color(0xFF185FA5),
                    child: Text(
                      iniciales.toUpperCase(),
                      style: const TextStyle(
                          color: Colors.white, fontSize: 14),
                    ),
                  ),
                  title: Row(
                    children: [
                      Text(
                        '${u.nombre} ${u.apellidoP}',
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      if (esYo) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: const Color(0xFF185FA5).withOpacity(0.1),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text('Tú',
                              style: TextStyle(
                                  fontSize: 10,
                                  color: Color(0xFF185FA5))),
                        ),
                      ],
                    ],
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 2),
                      Text(u.emailUsuario,
                          style: const TextStyle(
                              fontSize: 12, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: rolNombre.toLowerCase() == 'admin'
                              ? Colors.blue.withOpacity(0.1)
                              : Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          rolNombre,
                          style: TextStyle(
                            fontSize: 10,
                            color: rolNombre.toLowerCase() == 'admin'
                                ? Colors.blue
                                : Colors.green,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                  trailing: PopupMenuButton<String>(
                    icon: const Icon(Icons.more_vert, color: Colors.grey),
                    onSelected: (value) {
                      if (value == 'editar') {
                        _mostrarFormulario(usuario: u);
                      } else if (value == 'eliminar') {
                        _confirmarEliminar(context, u);
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
                      if (!esYo)
                        const PopupMenuItem(
                          value: 'eliminar',
                          child: Row(
                            children: [
                              Icon(Icons.delete, size: 18, color: Colors.red),
                              SizedBox(width: 8),
                              Text('Eliminar',
                                  style: TextStyle(color: Colors.red)),
                            ],
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

// ── Formulario crear/editar ──────────────────────────────────────────────────

class _FormularioUsuario extends StatefulWidget {
  final UsuarioModel? usuarioEditar;
  const _FormularioUsuario({this.usuarioEditar});

  @override
  State<_FormularioUsuario> createState() => _FormularioUsuarioState();
}

class _FormularioUsuarioState extends State<_FormularioUsuario> {
  final _nombreCtrl = TextEditingController();
  final _apellidoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  int _rolSeleccionado = 2;
  bool _guardando = false;
  bool _verPassword = false;

  bool get _esEdicion => widget.usuarioEditar != null;

  @override
  void initState() {
    super.initState();
    if (_esEdicion) {
      final u = widget.usuarioEditar!;
      _nombreCtrl.text = u.nombre;
      _apellidoCtrl.text = u.apellidoP;
      _emailCtrl.text = u.emailUsuario;
      _rolSeleccionado = u.rol?['idRol'] ?? 2;
    }
  }

  @override
  void dispose() {
    _nombreCtrl.dispose();
    _apellidoCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  Future<void> _guardar() async {
    if (_nombreCtrl.text.trim().isEmpty ||
        _apellidoCtrl.text.trim().isEmpty ||
        _emailCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Completa todos los campos obligatorios'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    if (!_esEdicion && _passwordCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('La contraseña es obligatoria'),
        backgroundColor: Colors.red,
      ));
      return;
    }

    setState(() => _guardando = true);
    final provider = Provider.of<UsuarioProvider>(context, listen: false);

    final usuario = UsuarioModel(
      idUsuario: _esEdicion ? widget.usuarioEditar!.idUsuario : null,
      nombre: _nombreCtrl.text.trim(),
      apellidoP: _apellidoCtrl.text.trim(),
      apellidoM: '',
      emailUsuario: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.isNotEmpty
          ? _passwordCtrl.text.trim()
          : (widget.usuarioEditar?.password ?? ''),
      intentosFallidos: 0,
      bloqueado: 'N',
      ultimoLogin: DateTime.now().toIso8601String(),
      fechaCreacion: DateTime.now().toIso8601String().substring(0, 10),
      rol: {'idRol': _rolSeleccionado},
      organizacion: {'idOrganizacion': 1},
    );

    bool ok;
    if (_esEdicion) {
      ok = await provider.actualizarUsuario(
          widget.usuarioEditar!.idUsuario!, usuario);
    } else {
      ok = await provider.crearUsuario(usuario);
    }

    setState(() => _guardando = false);

    if (mounted) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(ok
            ? (_esEdicion
                ? 'Usuario actualizado correctamente'
                : 'Usuario creado correctamente')
            : provider.error ?? 'Error al guardar'),
        backgroundColor: ok ? Colors.green : Colors.red,
      ));
    }
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
            // Handle
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
              _esEdicion ? 'Editar usuario' : 'Nuevo usuario',
              style: const TextStyle(
                  fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),

            // Nombre y Apellido
            Row(
              children: [
                Expanded(
                  child: _Campo(
                    label: 'Nombre *',
                    controller: _nombreCtrl,
                    icono: Icons.person_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Campo(
                    label: 'Apellido *',
                    controller: _apellidoCtrl,
                    icono: Icons.person_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Email
            _Campo(
              label: 'Correo electrónico *',
              controller: _emailCtrl,
              icono: Icons.email_outlined,
              tipo: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),

            // Password
            TextField(
              controller: _passwordCtrl,
              obscureText: !_verPassword,
              decoration: InputDecoration(
                labelText: _esEdicion
                    ? 'Nueva contraseña (dejar vacío para no cambiar)'
                    : 'Contraseña *',
                prefixIcon: const Icon(Icons.lock_outline,
                    color: Color(0xFF185FA5), size: 20),
                suffixIcon: IconButton(
                  icon: Icon(
                    _verPassword
                        ? Icons.visibility_off
                        : Icons.visibility,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () =>
                      setState(() => _verPassword = !_verPassword),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: const BorderSide(
                        color: Color(0xFF185FA5), width: 2)),
              ),
            ),
            const SizedBox(height: 12),

            // Rol
            const Text('Rol *',
                style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey)),
            const SizedBox(height: 8),
            Row(
              children: [
                _RolChip(
                  label: 'Usuario',
                  seleccionado: _rolSeleccionado == 2,
                  onTap: () => setState(() => _rolSeleccionado = 2),
                ),
                const SizedBox(width: 10),
                _RolChip(
                  label: 'Admin',
                  seleccionado: _rolSeleccionado == 1,
                  onTap: () => setState(() => _rolSeleccionado = 1),
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Botón guardar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF185FA5),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12)),
                ),
                child: _guardando
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2.5))
                    : Text(
                        _esEdicion ? 'Guardar cambios' : 'Crear usuario',
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
                      ),
              ),
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icono;
  final TextInputType tipo;

  const _Campo({
    required this.label,
    required this.controller,
    required this.icono,
    this.tipo = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: tipo,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(fontSize: 13),
        prefixIcon:
            Icon(icono, color: const Color(0xFF185FA5), size: 20),
        filled: true,
        fillColor: Colors.grey.shade50,
        border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide(color: Colors.grey.shade300)),
        focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: Color(0xFF185FA5), width: 2)),
      ),
    );
  }
}

class _RolChip extends StatelessWidget {
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;
  final Color color;

  const _RolChip({
    required this.label,
    required this.seleccionado,
    required this.onTap,
    this.color = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: seleccionado ? color.withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: seleccionado ? color : Colors.grey.shade300,
            width: seleccionado ? 2 : 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              seleccionado
                  ? Icons.check_circle
                  : Icons.radio_button_unchecked,
              size: 16,
              color: seleccionado ? color : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: seleccionado ? color : Colors.grey,
                fontWeight: seleccionado
                    ? FontWeight.w600
                    : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}