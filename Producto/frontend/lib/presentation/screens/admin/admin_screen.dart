import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/usuario_model.dart';
import '../../../data/providers/departamento_provider.dart';
import '../../../data/providers/organizacion_provider.dart';
import '../../../data/providers/usuario_provider.dart';
import '../reportes/reportes_screen.dart';
import 'sesiones_admin_screen.dart';

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
      final usuarioProvider = Provider.of<UsuarioProvider>(
        context,
        listen: false,
      );
      final orgProvider = Provider.of<OrganizacionProvider>(
        context,
        listen: false,
      );
      final depProvider = Provider.of<DepartamentoProvider>(
        context,
        listen: false,
      );

      final token = usuarioProvider.token;

      if (token != null) {
        orgProvider.setToken(token);
        depProvider.setToken(token);
      }

      usuarioProvider.cargarUsuarios();
      orgProvider.cargarOrganizaciones();
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
          '¿Estás seguro de eliminar a ${usuario.nombre} ${usuario.apellidoP}?',
        ),
        actions: [
          TextButton(
            key: const Key('adminCancelarEliminarButton'),
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            key: const Key('adminConfirmarEliminarButton'),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);

              final messenger = ScaffoldMessenger.of(context);
              final provider = Provider.of<UsuarioProvider>(
                context,
                listen: false,
              );

              if (usuario.idUsuario == null) {
                messenger.showSnackBar(
                  const SnackBar(
                    content: Text(
                      'No se pudo identificar el usuario a eliminar',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
                return;
              }

              final ok = await provider.eliminarUsuario(usuario.idUsuario!);

              messenger.showSnackBar(
                SnackBar(
                  content: Text(
                    ok
                        ? 'Usuario eliminado'
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

  void _abrirSesiones() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const SesionesAdminScreen()),
    );
  }

  void _abrirReportes() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const ReportesScreen()),
    );
  }

  List<Widget> _opcionesAdmin() {
    return [
      _AdminOptionCard(
        icono: Icons.manage_accounts,
        titulo: 'Sesiones de usuarios',
        subtitulo: 'Ver sesiones activas y cerradas del sistema',
        color: const Color(0xFF185FA5),
        onTap: _abrirSesiones,
      ),
      const SizedBox(height: 12),
      _AdminOptionCard(
        icono: Icons.picture_as_pdf,
        titulo: 'Reportes',
        subtitulo: 'Generar y descargar reportes de tareas',
        color: Colors.red,
        onTap: _abrirReportes,
      ),
    ];
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
        key: const Key('adminNuevoUsuarioButton'),
        onPressed: () => _mostrarFormulario(),
        backgroundColor: const Color(0xFF185FA5),
        icon: const Icon(Icons.person_add, color: Colors.white),
        label: const Text(
          'Nuevo usuario',
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Consumer<UsuarioProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.usuarios.isEmpty) {
            return ListView(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
              children: [
                ..._opcionesAdmin(),
                const SizedBox(height: 80),
                const Center(
                  child: Column(
                    children: [
                      Icon(Icons.people_outline, size: 60, color: Colors.grey),
                      SizedBox(height: 12),
                      Text(
                        'No hay usuarios registrados',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            );
          }

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 90),
            children: [
              ..._opcionesAdmin(),
              const SizedBox(height: 20),
              const Text(
                'Usuarios registrados',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 12),
              ...provider.usuarios.map((u) {
                final esYo = u.idUsuario == provider.usuarioLogueado?.idUsuario;
                final rolNombre = u.rol?['nombre']?.toString() ?? 'Sin rol';
                final depNombre = u.departamento?['nombre']?.toString();
                final iniciales =
                    (u.nombre.isNotEmpty ? u.nombre[0] : '') +
                    (u.apellidoP.isNotEmpty ? u.apellidoP[0] : '');

                return Container(
                  key: Key('adminUsuarioItem_${u.idUsuario}'),
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
                      horizontal: 16,
                      vertical: 8,
                    ),
                    leading: CircleAvatar(
                      backgroundColor: const Color(0xFF185FA5),
                      child: Text(
                        iniciales.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ),
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${u.nombre} ${u.apellidoP}',
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (esYo) ...[
                          const SizedBox(width: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: const Color(0xFF185FA5).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: const Text(
                              'Tú',
                              style: TextStyle(
                                fontSize: 10,
                                color: Color(0xFF185FA5),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 2),
                        Text(
                          u.emailUsuario,
                          style: const TextStyle(
                            fontSize: 12,
                            color: Colors.grey,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            _Tag(
                              texto: rolNombre,
                              color: rolNombre.toLowerCase() == 'admin'
                                  ? Colors.blue
                                  : Colors.green,
                            ),
                            if (depNombre != null)
                              _Tag(texto: depNombre, color: Colors.orange),
                          ],
                        ),
                      ],
                    ),
                    trailing: PopupMenuButton<String>(
                      key: Key('adminUsuarioMenu_${u.idUsuario}'),
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
              }),
            ],
          );
        },
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String texto;
  final Color color;

  const _Tag({required this.texto, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        texto,
        style: TextStyle(
          fontSize: 10,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}

class _AdminOptionCard extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final Color color;
  final VoidCallback onTap;

  const _AdminOptionCard({
    required this.icono,
    required this.titulo,
    required this.subtitulo,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: Colors.grey.shade200),
          ),
          child: Row(
            children: [
              Container(
                width: 46,
                height: 46,
                decoration: BoxDecoration(
                  color: color.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icono, color: color),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      subtitulo,
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right, color: Colors.grey),
            ],
          ),
        ),
      ),
    );
  }
}

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
  int? _orgSeleccionada;

  static const int _sinDepartamento = -1;
  int _depSeleccionado = _sinDepartamento;

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
      _depSeleccionado = u.departamento?['idDepartamento'] ?? _sinDepartamento;
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      final usuarioProvider = Provider.of<UsuarioProvider>(
        context,
        listen: false,
      );
      final orgProvider = Provider.of<OrganizacionProvider>(
        context,
        listen: false,
      );
      final depProvider = Provider.of<DepartamentoProvider>(
        context,
        listen: false,
      );

      final token = usuarioProvider.token;

      if (token != null) {
        orgProvider.setToken(token);
        depProvider.setToken(token);
      }

      orgProvider.cargarOrganizaciones().then((_) {
        if (!mounted) return;
        int? orgId;

        if (_esEdicion) {
          final orgValue =
              widget.usuarioEditar?.organizacion?['idOrganizacion'];

          if (orgValue is int) {
            orgId = orgValue;
          } else if (orgValue != null) {
            orgId = int.tryParse(orgValue.toString());
          }
        }

        setState(() => _orgSeleccionada = orgId);

        if (orgId != null) {
          depProvider.cargarPorOrganizacion(orgId).then((_) {
            if (!mounted) return;

            final existeEnLista = depProvider.departamentos.any(
              (d) => d.idDepartamento == _depSeleccionado,
            );

            if (!existeEnLista) {
              setState(() => _depSeleccionado = _sinDepartamento);
            }
          });
        }
      });
    });
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
      _snack('Completa todos los campos obligatorios', Colors.red);
      return;
    }

    if (!_esEdicion && _passwordCtrl.text.trim().isEmpty) {
      _snack('La contraseña es obligatoria', Colors.red);
      return;
    }

    if (_orgSeleccionada == null) {
      _snack('Selecciona una organización', Colors.red);
      return;
    }

    setState(() => _guardando = true);

    final provider = Provider.of<UsuarioProvider>(context, listen: false);

    final depIdParaGuardar = _depSeleccionado == _sinDepartamento
        ? null
        : _depSeleccionado;

    final usuario = UsuarioModel(
      idUsuario: _esEdicion ? widget.usuarioEditar!.idUsuario : null,
      nombre: _nombreCtrl.text.trim(),
      apellidoP: _apellidoCtrl.text.trim(),
      apellidoM: '',
      emailUsuario: _emailCtrl.text.trim(),
      password: _passwordCtrl.text.isNotEmpty
          ? _passwordCtrl.text.trim()
          : widget.usuarioEditar?.password ?? '',
      intentosFallidos: 0,
      bloqueado: 'N',
      ultimoLogin: DateTime.now().toIso8601String(),
      fechaCreacion: DateTime.now().toIso8601String().substring(0, 10),
      rol: {'idRol': _rolSeleccionado},
      organizacion: {'idOrganizacion': _orgSeleccionada},
      departamento: depIdParaGuardar != null
          ? {'idDepartamento': depIdParaGuardar}
          : null,
    );

    final ok = _esEdicion
        ? await provider.actualizarUsuario(
            widget.usuarioEditar!.idUsuario!,
            usuario,
          )
        : await provider.crearUsuario(usuario);

    if (!mounted) return;

    setState(() => _guardando = false);
    Navigator.pop(context);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          ok
              ? (_esEdicion
                    ? 'Usuario actualizado correctamente'
                    : 'Usuario creado correctamente')
              : provider.error ?? 'Error al guardar',
        ),
        backgroundColor: ok ? Colors.green : Colors.red,
      ),
    );
  }

  void _snack(String msg, Color color) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(msg), backgroundColor: color));
  }

  @override
  Widget build(BuildContext context) {
    final depProvider = context.watch<DepartamentoProvider>();
    final orgProvider = context.watch<OrganizacionProvider>();

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
          key: const Key('adminUsuarioForm'),
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
              _esEdicion ? 'Editar usuario' : 'Nuevo usuario',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Expanded(
                  child: _Campo(
                    keyCampo: const Key('adminNombreField'),
                    label: 'Nombre *',
                    controller: _nombreCtrl,
                    icono: Icons.person_outline,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _Campo(
                    keyCampo: const Key('adminApellidoField'),
                    label: 'Apellido *',
                    controller: _apellidoCtrl,
                    icono: Icons.person_outline,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _Campo(
              keyCampo: const Key('adminEmailField'),
              label: 'Correo electrónico *',
              controller: _emailCtrl,
              icono: Icons.email_outlined,
              tipo: TextInputType.emailAddress,
            ),
            const SizedBox(height: 12),
            TextField(
              key: const Key('adminPasswordField'),
              controller: _passwordCtrl,
              obscureText: !_verPassword,
              decoration: _inputDecoration(
                label: _esEdicion
                    ? 'Nueva contraseña (dejar vacío para no cambiar)'
                    : 'Contraseña *',
                icono: Icons.lock_outline,
                suffixIcon: IconButton(
                  icon: Icon(
                    _verPassword ? Icons.visibility_off : Icons.visibility,
                    color: Colors.grey,
                    size: 20,
                  ),
                  onPressed: () => setState(() => _verPassword = !_verPassword),
                ),
              ),
            ),
            const SizedBox(height: 12),
            const _SelectorLabel(
              icono: Icons.business_outlined,
              label: 'Organización *',
            ),
            const SizedBox(height: 8),
            orgProvider.isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : _DropdownField<int>(
                    keyCampo: const Key('adminOrganizacionDropdown'),
                    value: _orgSeleccionada,
                    hint: 'Selecciona organización',
                    items: orgProvider.organizaciones
                        .map(
                          (o) => DropdownMenuItem<int>(
                            value: o['idOrganizacion'] as int,
                            child: Text(o['nombre'] as String),
                          ),
                        )
                        .toList(),
                    onChanged: (v) {
                      setState(() {
                        _orgSeleccionada = v;
                        _depSeleccionado = _sinDepartamento;
                      });

                      if (v != null) {
                        Provider.of<DepartamentoProvider>(
                          context,
                          listen: false,
                        ).cargarPorOrganizacion(v);
                      }
                    },
                  ),
            const SizedBox(height: 12),
            const _SelectorLabel(
              icono: Icons.work_outline,
              label: 'Departamento',
            ),
            const SizedBox(height: 8),
            _orgSeleccionada == null
                ? Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.grey.shade50,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade300),
                    ),
                    child: const Text(
                      'Selecciona primero una organización',
                      style: TextStyle(fontSize: 14, color: Colors.grey),
                    ),
                  )
                : depProvider.isLoading
                ? const Center(child: CircularProgressIndicator(strokeWidth: 2))
                : _DropdownField<int>(
                    keyCampo: const Key('adminDepartamentoDropdown'),
                    value:
                        depProvider.departamentos.any(
                          (d) => d.idDepartamento == _depSeleccionado,
                        )
                        ? _depSeleccionado
                        : _sinDepartamento,
                    hint: 'Sin departamento asignado',
                    items: [
                      const DropdownMenuItem<int>(
                        value: _sinDepartamento,
                        child: Text(
                          'Sin departamento',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                      ...depProvider.departamentos.map(
                        (d) => DropdownMenuItem<int>(
                          value: d.idDepartamento,
                          child: Text(d.nombre),
                        ),
                      ),
                    ],
                    onChanged: (v) => setState(
                      () => _depSeleccionado = v ?? _sinDepartamento,
                    ),
                  ),
            const SizedBox(height: 12),
            const Text(
              'Rol *',
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Colors.grey,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                _RolChip(
                  keyCampo: const Key('adminRolUsuarioChip'),
                  label: 'Usuario',
                  seleccionado: _rolSeleccionado == 2,
                  onTap: () => setState(() => _rolSeleccionado = 2),
                ),
                const SizedBox(width: 10),
                _RolChip(
                  keyCampo: const Key('adminRolAdminChip'),
                  label: 'Admin',
                  seleccionado: _rolSeleccionado == 1,
                  onTap: () => setState(() => _rolSeleccionado = 1),
                  color: Colors.blue,
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                key: const Key('adminGuardarUsuarioButton'),
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
                        _esEdicion ? 'Guardar cambios' : 'Crear usuario',
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

class _SelectorLabel extends StatelessWidget {
  final IconData icono;
  final String label;

  const _SelectorLabel({required this.icono, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icono, size: 16, color: const Color(0xFF185FA5)),
        const SizedBox(width: 6),
        Text(
          label,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w500,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }
}

class _DropdownField<T> extends StatelessWidget {
  final Key? keyCampo;
  final T? value;
  final String hint;
  final List<DropdownMenuItem<T>> items;
  final ValueChanged<T?> onChanged;

  const _DropdownField({
    this.keyCampo,
    required this.value,
    required this.hint,
    required this.items,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      key: keyCampo,
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          value: value,
          hint: Text(hint, style: const TextStyle(fontSize: 14)),
          isExpanded: true,
          items: items,
          onChanged: onChanged,
          style: const TextStyle(fontSize: 14, color: Colors.black87),
        ),
      ),
    );
  }
}

class _Campo extends StatelessWidget {
  final Key? keyCampo;
  final String label;
  final TextEditingController controller;
  final IconData icono;
  final TextInputType tipo;

  const _Campo({
    this.keyCampo,
    required this.label,
    required this.controller,
    required this.icono,
    this.tipo = TextInputType.text,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      key: keyCampo,
      controller: controller,
      keyboardType: tipo,
      decoration: _inputDecoration(label: label, icono: icono),
    );
  }
}

InputDecoration _inputDecoration({
  required String label,
  required IconData icono,
  Widget? suffixIcon,
}) {
  return InputDecoration(
    labelText: label,
    labelStyle: const TextStyle(fontSize: 13),
    prefixIcon: Icon(icono, color: const Color(0xFF185FA5), size: 20),
    suffixIcon: suffixIcon,
    filled: true,
    fillColor: Colors.grey.shade50,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: Color(0xFF185FA5), width: 2),
    ),
  );
}

class _RolChip extends StatelessWidget {
  final Key? keyCampo;
  final String label;
  final bool seleccionado;
  final VoidCallback onTap;
  final Color color;

  const _RolChip({
    this.keyCampo,
    required this.label,
    required this.seleccionado,
    required this.onTap,
    this.color = Colors.green,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: keyCampo,
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
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
              seleccionado ? Icons.check_circle : Icons.radio_button_unchecked,
              size: 16,
              color: seleccionado ? color : Colors.grey,
            ),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: seleccionado ? color : Colors.grey,
                fontWeight: seleccionado ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
