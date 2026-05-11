import 'package:flutter/material.dart';

class EditarPerfilScreen extends StatefulWidget {
  const EditarPerfilScreen({super.key});

  @override
  State<EditarPerfilScreen> createState() => _EditarPerfilScreenState();
}

class _EditarPerfilScreenState extends State<EditarPerfilScreen> {
  final _nombreController = TextEditingController(text: 'Sebastián');
  final _apellidoController = TextEditingController(text: 'Mardones');
  final _correoController = TextEditingController(text: 'se.mardones@process.cl');
  final _telefonoController = TextEditingController(text: '+56 9 1234 5678');
  final _passwordActualController = TextEditingController();
  final _passwordNuevoController = TextEditingController();
  final _passwordConfirmarController = TextEditingController();

  bool _verPasswordActual = false;
  bool _verPasswordNuevo = false;
  bool _verPasswordConfirmar = false;
  bool _guardando = false;

  void _guardarCambios() async {
    setState(() => _guardando = true);
    await Future.delayed(const Duration(seconds: 2));
    setState(() => _guardando = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Perfil actualizado correctamente'),
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
        title: const Text('Editar perfil',
            style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF185FA5),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [


            Center(
              child: Column(
                children: [
                  Stack(
                    children: [
                      CircleAvatar(
                        radius: 45,
                        backgroundColor: const Color(0xFFE6F1FB),
                        child: const Text(
                          'SM',
                          style: TextStyle(
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
                              border: Border.all(
                                  color: Colors.white, width: 2),
                            ),
                            child: const Icon(Icons.camera_alt,
                                size: 14, color: Colors.white),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  TextButton(
                    onPressed: () {},
                    child: const Text('Cambiar foto',
                        style: TextStyle(
                            color: Color(0xFF185FA5), fontSize: 13)),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 8),


            _SeccionTitulo(titulo: 'Datos personales'),
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

            const SizedBox(height: 8),


            _SeccionTitulo(titulo: 'Cambiar contraseña'),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFE6F1FB),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: const [
                  Icon(Icons.info_outline,
                      size: 16, color: Color(0xFF185FA5)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Deja estos campos vacíos si no deseas cambiar tu contraseña.',
                      style: TextStyle(
                          fontSize: 11, color: Color(0xFF185FA5)),
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
              onToggle: () => setState(
                  () => _verPasswordActual = !_verPasswordActual),
            ),
            _CampoPassword(
              label: 'Nueva contraseña',
              controller: _passwordNuevoController,
              verPassword: _verPasswordNuevo,
              onToggle: () => setState(
                  () => _verPasswordNuevo = !_verPasswordNuevo),
            ),
            _CampoPassword(
              label: 'Confirmar nueva contraseña',
              controller: _passwordConfirmarController,
              verPassword: _verPasswordConfirmar,
              onToggle: () => setState(
                  () => _verPasswordConfirmar = !_verPasswordConfirmar),
            ),

            const SizedBox(height: 24),


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
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text(
                        'Guardar cambios',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600),
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
            borderSide: const BorderSide(
                color: Color(0xFF185FA5), width: 2),
          ),
        ),
      ),
    );
  }
}

// Widget reutilizable para campos de contraseña
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
          prefixIcon: const Icon(Icons.lock_outline,
              color: Color(0xFF185FA5)),
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
            borderSide: const BorderSide(
                color: Color(0xFF185FA5), width: 2),
          ),
        ),
      ),
    );
  }
}