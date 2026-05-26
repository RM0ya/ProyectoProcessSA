import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/usuario_model.dart';
import '../../../data/providers/usuario_provider.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordActualController = TextEditingController();
  final _passwordNuevoController = TextEditingController();
  final _passwordConfirmarController = TextEditingController();

  bool _verPasswordActual = false;
  bool _verPasswordNuevo = false;
  bool _verPasswordConfirmar = false;
  bool _guardando = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final usuario = Provider.of<UsuarioProvider>(
        context,
        listen: false,
      ).usuarioLogueado;
      if (usuario != null) {
        _nombreController.text = usuario.nombre;
        _apellidoController.text = usuario.apellidoP;
        _correoController.text = usuario.emailUsuario;
        _telefonoController.text = usuario.telefono ?? '';
      }
    });
  }

  @override
  void dispose() {
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _passwordActualController.dispose();
    _passwordNuevoController.dispose();
    _passwordConfirmarController.dispose();
    super.dispose();
  }

  Future<void> _guardarCambios() async {
    final provider = Provider.of<UsuarioProvider>(context, listen: false);
    final usuario = provider.usuarioLogueado;
    if (usuario == null) return;

    if (_nombreController.text.trim().isEmpty ||
        _apellidoController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('El nombre y apellido son obligatorios'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final quiereCambiarPassword =
        _passwordNuevoController.text.isNotEmpty ||
        _passwordActualController.text.isNotEmpty;

    if (quiereCambiarPassword) {
      if (_passwordActualController.text.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Ingresa tu contraseña actual'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_passwordNuevoController.text.length < 6) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'La nueva contraseña debe tener al menos 6 caracteres',
            ),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
      if (_passwordNuevoController.text != _passwordConfirmarController.text) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Las contraseñas no coinciden'),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }
    }

    setState(() => _guardando = true);

    final usuarioActualizado = UsuarioModel(
      idUsuario: usuario.idUsuario,
      nombre: _nombreController.text.trim(),
      apellidoP: _apellidoController.text.trim(),
      apellidoM: usuario.apellidoM,
      emailUsuario: _correoController.text.trim(),
      password: quiereCambiarPassword
          ? _passwordNuevoController.text.trim()
          : usuario.password,
      telefono: _telefonoController.text.trim().isEmpty
          ? null
          : _telefonoController.text.trim(),
      intentosFallidos: usuario.intentosFallidos,
      bloqueado: usuario.bloqueado,
      ultimoLogin: usuario.ultimoLogin,
      fechaCreacion: usuario.fechaCreacion,
      rol: usuario.rol,
      organizacion: usuario.organizacion,
      departamento: usuario.departamento,
    );

    final ok = await provider.actualizarUsuario(
      usuario.idUsuario!,
      usuarioActualizado,
    );

    setState(() => _guardando = false);

    if (!mounted) return;

    // FIX: usar solo el setter (ya llama notifyListeners internamente)
    // se eliminó provider.notifyListeners() que causaba el error
    if (ok) {
      provider.usuarioLogueado = usuarioActualizado;

      final messenger = ScaffoldMessenger.of(context);
      Navigator.pop(context);
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
          backgroundColor: Color(0xFF639922),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(provider.error ?? 'Error al actualizar el perfil'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final usuario = context.watch<UsuarioProvider>().usuarioLogueado;

    final iniciales = usuario != null
        ? (usuario.nombre.isNotEmpty ? usuario.nombre[0] : '') +
              (usuario.apellidoP.isNotEmpty ? usuario.apellidoP[0] : '')
        : '?';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text(
          'Editar perfil',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: const Color(0xFF185FA5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Avatar ──────────────────────────────────────────────────
            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: const Color(0xFFE6F1FB),
                        child: Text(
                          iniciales.toUpperCase(),
                          style: const TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF185FA5),
                          ),
                        ),
                      ),
                      Positioned(
                        bottom: 0,
                        right: 0,
                        child: GestureDetector(
                          onTap: () {},
                          child: Container(
                            width: 28,
                            height: 28,
                            decoration: BoxDecoration(
                              color: const Color(0xFF185FA5),
                              shape: BoxShape.circle,
                              border: Border.all(color: Colors.white, width: 2),
                            ),
                            child: const Icon(
                              Icons.camera_alt,
                              size: 14,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  if (usuario != null)
                    Text(
                      '${usuario.nombre} ${usuario.apellidoP}',
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF185FA5),
                      ),
                    ),
                  if (usuario?.rol?['nombre'] != null)
                    Text(
                      usuario!.rol!['nombre'].toString(),
                      style: const TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // ── Datos personales ─────────────────────────────────────────
            const _SeccionTitulo(titulo: 'Datos personales'),
            _CampoTexto(
              label: 'Nombre',
              controller: _nombreController,
              icono: Icons.person_outline,
              tipo: TextInputType.name,
            ),
            _CampoTexto(
              label: 'Apellido',
              controller: _apellidoController,
              icono: Icons.person_outline,
              tipo: TextInputType.name,
            ),
            _CampoTexto(
              label: 'Correo electrónico',
              controller: _correoController,
              icono: Icons.email_outlined,
              tipo: TextInputType.emailAddress,
            ),
            _CampoTexto(
              label: 'Número de teléfono',
              controller: _telefonoController,
              icono: Icons.phone_outlined,
              tipo: TextInputType.phone,
            ),

            // Info de organización/departamento (solo lectura)
            if (usuario?.organizacion != null ||
                usuario?.departamento != null) ...[
              const _SeccionTitulo(titulo: 'Información de la empresa'),
              if (usuario?.organizacion?['nombre'] != null)
                _InfoReadOnly(
                  label: 'Organización',
                  valor: usuario!.organizacion!['nombre'].toString(),
                  icono: Icons.business_outlined,
                ),
              if (usuario?.departamento?['nombre'] != null)
                _InfoReadOnly(
                  label: 'Departamento',
                  valor: usuario!.departamento!['nombre'].toString(),
                  icono: Icons.work_outline,
                ),
            ],

            const SizedBox(height: 8),

            // ── Cambiar contraseña ───────────────────────────────────────
            const _SeccionTitulo(titulo: 'Cambiar contraseña'),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F1FB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Color(0xFF185FA5)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Deja estos campos vacíos si no deseas cambiar tu contraseña.',
                      style: TextStyle(fontSize: 11, color: Color(0xFF185FA5)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            _CampoPassword(
              label: 'Contraseña actual',
              controller: _passwordActualController,
              verPassword: _verPasswordActual,
              onToggle: () =>
                  setState(() => _verPasswordActual = !_verPasswordActual),
            ),
            _CampoPassword(
              label: 'Nueva contraseña',
              controller: _passwordNuevoController,
              verPassword: _verPasswordNuevo,
              onToggle: () =>
                  setState(() => _verPasswordNuevo = !_verPasswordNuevo),
            ),
            _CampoPassword(
              label: 'Confirmar nueva contraseña',
              controller: _passwordConfirmarController,
              verPassword: _verPasswordConfirmar,
              onToggle: () => setState(
                () => _verPasswordConfirmar = !_verPasswordConfirmar,
              ),
            ),

            const SizedBox(height: 24),

            // ── Botones ──────────────────────────────────────────────────
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: _guardando ? null : _guardarCambios,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF185FA5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
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
                    : const Text(
                        'Guardar cambios',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
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
                child: const Text('Cancelar', style: TextStyle(fontSize: 16)),
              ),
            ),

            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}

// ── Widgets auxiliares ───────────────────────────────────────────────────────

class _SeccionTitulo extends StatelessWidget {
  final String titulo;
  const _SeccionTitulo({required this.titulo});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Color(0xFF185FA5),
        ),
      ),
    );
  }
}

class _InfoReadOnly extends StatelessWidget {
  final String label;
  final String valor;
  final IconData icono;

  const _InfoReadOnly({
    required this.label,
    required this.valor,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.grey.shade200),
        ),
        child: Row(
          children: [
            Icon(icono, color: Colors.grey, size: 20),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 11, color: Colors.grey),
                ),
                const SizedBox(height: 2),
                Text(
                  valor,
                  style: const TextStyle(fontSize: 14, color: Colors.black87),
                ),
              ],
            ),
            const Spacer(),
            const Icon(Icons.lock_outline, size: 14, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

class _CampoTexto extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icono;
  final TextInputType tipo;

  const _CampoTexto({
    required this.label,
    required this.controller,
    required this.icono,
    required this.tipo,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        keyboardType: tipo,
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
            borderSide: const BorderSide(color: Color(0xFF185FA5), width: 2),
          ),
        ),
      ),
    );
  }
}

class _CampoPassword extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool verPassword;
  final VoidCallback onToggle;

  const _CampoPassword({
    required this.label,
    required this.controller,
    required this.verPassword,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: !verPassword,
        decoration: InputDecoration(
          labelText: label,
          prefixIcon: const Icon(Icons.lock_outline, color: Color(0xFF185FA5)),
          suffixIcon: IconButton(
            icon: Icon(
              verPassword ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
            ),
            onPressed: onToggle,
          ),
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
            borderSide: const BorderSide(color: Color(0xFF185FA5), width: 2),
          ),
        ),
      ),
    );
  }
}
