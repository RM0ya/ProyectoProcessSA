import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/usuario_provider.dart';

class RegistroScreen extends StatefulWidget {
  const RegistroScreen({super.key});

  @override
  State<RegistroScreen> createState() => _RegistroScreenState();
}

class _RegistroScreenState extends State<RegistroScreen>
    with SingleTickerProviderStateMixin {
  final _nombreController = TextEditingController();
  final _apellidoController = TextEditingController();
  final _correoController = TextEditingController();
  final _telefonoController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmarController = TextEditingController();

  bool _verPassword = false;
  bool _verConfirmar = false;
  bool _aceptaTerminos = false;
  bool _registrando = false;

  late AnimationController _animController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.2), end: Offset.zero).animate(
          CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
        );
    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _animController, curve: Curves.easeIn));
    _animController.forward();

    _passwordController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _animController.dispose();
    _nombreController.dispose();
    _apellidoController.dispose();
    _correoController.dispose();
    _telefonoController.dispose();
    _passwordController.dispose();
    _confirmarController.dispose();
    super.dispose();
  }

  void _registrar() async {
    if (_nombreController.text.trim().isEmpty ||
        _apellidoController.text.trim().isEmpty ||
        _correoController.text.trim().isEmpty ||
        _passwordController.text.trim().isEmpty) {
      _mostrarError('Completa todos los campos obligatorios');
      return;
    }
    if (_passwordController.text != _confirmarController.text) {
      _mostrarError('Las contraseñas no coinciden');
      return;
    }
    if (!_aceptaTerminos) {
      _mostrarError('Debes aceptar los términos y condiciones');
      return;
    }

    setState(() => _registrando = true);

    final provider = Provider.of<UsuarioProvider>(context, listen: false);

    final exito = await provider.registrar(
      nombre: _nombreController.text.trim(),
      apellido: _apellidoController.text.trim(),
      email: _correoController.text.trim(),
      password: _passwordController.text.trim(),
      telefono: _telefonoController.text.trim(),
    );

    setState(() => _registrando = false);

    if (mounted) {
      if (exito) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white, size: 18),
                SizedBox(width: 8),
                Text('Cuenta creada correctamente'),
              ],
            ),
            backgroundColor: const Color(0xFF639922),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
        );
        Navigator.pop(context);
      } else {
        _mostrarError(provider.error ?? 'Error al registrar usuario');
      }
    }
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 8),
            Expanded(child: Text(mensaje)),
          ],
        ),
        backgroundColor: Colors.red.shade700,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF0D3B6E),
                  Color(0xFF185FA5),
                  Color(0xFF2196F3),
                ],
              ),
            ),
          ),

          Positioned(
            top: -40,
            right: -40,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.05),
              ),
            ),
          ),

          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: SlideTransition(
                  position: _slideAnimation,
                  child: Column(
                    children: [
                      const SizedBox(height: 30),

                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: const Icon(
                                Icons.arrow_back,
                                color: Colors.white,
                                size: 20,
                              ),
                            ),
                          ),
                          const SizedBox(width: 14),
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Crear cuenta',
                                style: TextStyle(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              Text(
                                'Completa tus datos para registrarte',
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),

                      const SizedBox(height: 24),

                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(24),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.15),
                              blurRadius: 30,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _SeccionTitulo(titulo: 'Datos personales'),

                            Row(
                              children: [
                                Expanded(
                                  child: _CampoReg(
                                    label: 'Nombre *',
                                    controller: _nombreController,
                                    icono: Icons.person_outline,
                                    tipo: TextInputType.name,
                                  ),
                                ),
                                const SizedBox(width: 10),
                                Expanded(
                                  child: _CampoReg(
                                    label: 'Apellido *',
                                    controller: _apellidoController,
                                    icono: Icons.person_outline,
                                    tipo: TextInputType.name,
                                  ),
                                ),
                              ],
                            ),

                            _CampoReg(
                              label: 'Correo electrónico *',
                              controller: _correoController,
                              icono: Icons.email_outlined,
                              tipo: TextInputType.emailAddress,
                            ),

                            _CampoReg(
                              label: 'Teléfono (opcional)',
                              controller: _telefonoController,
                              icono: Icons.phone_outlined,
                              tipo: TextInputType.phone,
                            ),

                            const _SeccionTitulo(titulo: 'Contraseña'),

                            _CampoPassword(
                              label: 'Contraseña *',
                              controller: _passwordController,
                              ver: _verPassword,
                              onToggle: () =>
                                  setState(() => _verPassword = !_verPassword),
                            ),

                            _CampoPassword(
                              label: 'Confirmar contraseña *',
                              controller: _confirmarController,
                              ver: _verConfirmar,
                              onToggle: () => setState(
                                () => _verConfirmar = !_verConfirmar,
                              ),
                            ),

                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Colors.grey.shade50,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: Colors.grey.shade200),
                              ),
                              child: Column(
                                children: [
                                  _ReqItem(
                                    texto: 'Mínimo 8 caracteres',
                                    cumple:
                                        _passwordController.text.length >= 8,
                                  ),
                                  _ReqItem(
                                    texto: 'Al menos una mayúscula',
                                    cumple: _passwordController.text.contains(
                                      RegExp(r'[A-Z]'),
                                    ),
                                  ),
                                  _ReqItem(
                                    texto: 'Al menos un número',
                                    cumple: _passwordController.text.contains(
                                      RegExp(r'[0-9]'),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 16),

                            GestureDetector(
                              onTap: () => setState(
                                () => _aceptaTerminos = !_aceptaTerminos,
                              ),
                              child: Row(
                                children: [
                                  AnimatedContainer(
                                    duration: const Duration(milliseconds: 200),
                                    width: 22,
                                    height: 22,
                                    decoration: BoxDecoration(
                                      color: _aceptaTerminos
                                          ? const Color(0xFF185FA5)
                                          : Colors.white,
                                      borderRadius: BorderRadius.circular(6),
                                      border: Border.all(
                                        color: _aceptaTerminos
                                            ? const Color(0xFF185FA5)
                                            : Colors.grey.shade400,
                                        width: 1.5,
                                      ),
                                    ),
                                    child: _aceptaTerminos
                                        ? const Icon(
                                            Icons.check,
                                            size: 14,
                                            color: Colors.white,
                                          )
                                        : null,
                                  ),
                                  const SizedBox(width: 10),
                                  Expanded(
                                    child: RichText(
                                      text: const TextSpan(
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey,
                                        ),
                                        children: [
                                          TextSpan(text: 'Acepto los '),
                                          TextSpan(
                                            text: 'Términos y condiciones',
                                            style: TextStyle(
                                              color: Color(0xFF185FA5),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                          TextSpan(text: ' y la '),
                                          TextSpan(
                                            text: 'Política de privacidad',
                                            style: TextStyle(
                                              color: Color(0xFF185FA5),
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            const SizedBox(height: 20),

                            SizedBox(
                              width: double.infinity,
                              height: 50,
                              child: ElevatedButton(
                                onPressed: _registrando ? null : _registrar,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF185FA5),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  elevation: 3,
                                  shadowColor: const Color(
                                    0xFF185FA5,
                                  ).withOpacity(0.4),
                                ),
                                child: _registrando
                                    ? const SizedBox(
                                        width: 22,
                                        height: 22,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2.5,
                                        ),
                                      )
                                    : const Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Icon(
                                            Icons.person_add,
                                            color: Colors.white,
                                            size: 18,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Crear cuenta',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                              fontWeight: FontWeight.w600,
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            ),

                            const SizedBox(height: 14),

                            Center(
                              child: TextButton(
                                onPressed: () => Navigator.pop(context),
                                child: const Text(
                                  '¿Ya tienes cuenta? Inicia sesión',
                                  style: TextStyle(
                                    color: Color(0xFF185FA5),
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 30),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
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
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        titulo,
        style: const TextStyle(
          fontSize: 13,
          fontWeight: FontWeight.w600,
          color: Color(0xFF185FA5),
        ),
      ),
    );
  }
}

class _CampoReg extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final IconData icono;
  final TextInputType tipo;

  const _CampoReg({
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
          labelStyle: const TextStyle(fontSize: 13),
          prefixIcon: Icon(icono, color: const Color(0xFF185FA5), size: 20),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
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
        ),
      ),
    );
  }
}

class _CampoPassword extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final bool ver;
  final VoidCallback onToggle;

  const _CampoPassword({
    required this.label,
    required this.controller,
    required this.ver,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: TextField(
        controller: controller,
        obscureText: !ver,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(fontSize: 13),
          prefixIcon: const Icon(
            Icons.lock_outline,
            color: Color(0xFF185FA5),
            size: 20,
          ),
          suffixIcon: IconButton(
            icon: Icon(
              ver ? Icons.visibility_off : Icons.visibility,
              color: Colors.grey,
              size: 20,
            ),
            onPressed: onToggle,
          ),
          filled: true,
          fillColor: Colors.grey.shade50,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 14,
          ),
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
        ),
      ),
    );
  }
}

class _ReqItem extends StatelessWidget {
  final String texto;
  final bool cumple;

  const _ReqItem({required this.texto, required this.cumple});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        children: [
          Icon(
            cumple ? Icons.check_circle : Icons.radio_button_unchecked,
            size: 14,
            color: cumple ? Colors.green : Colors.grey,
          ),
          const SizedBox(width: 6),
          Text(
            texto,
            style: TextStyle(
              fontSize: 11,
              color: cumple ? Colors.green : Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
