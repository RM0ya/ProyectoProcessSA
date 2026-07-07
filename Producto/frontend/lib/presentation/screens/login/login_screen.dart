import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:provider/provider.dart';
import '../../../data/providers/usuario_provider.dart';
import '../registro/registro_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _correoController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _verPassword = false;
  bool _cargandoGoogle = false;
  bool _cargandoLogin = false;

  late AnimationController _fadeController;
  late AnimationController _slideController;
  late AnimationController _logoController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _logoScaleAnimation;
  late Animation<double> _logoRotateAnimation;

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
    serverClientId:
        '986429467737-333gr9k40rds0m9nod84v0or8s7833d1.apps.googleusercontent.com',
  );

  @override
  void initState() {
    super.initState();
    _iniciarAnimaciones();
  }

  void _iniciarAnimaciones() {
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    _fadeAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(parent: _fadeController, curve: Curves.easeIn));

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    _slideAnimation =
        Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
          CurvedAnimation(parent: _slideController, curve: Curves.easeOutCubic),
        );

    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );

    _logoScaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _logoController, curve: Curves.elasticOut),
    );

    _logoRotateAnimation = Tween<double>(
      begin: -0.1,
      end: 0,
    ).animate(CurvedAnimation(parent: _logoController, curve: Curves.easeOut));

    _logoController.forward();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      _fadeController.forward();
      _slideController.forward();
    });
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _slideController.dispose();
    _logoController.dispose();
    _correoController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _correoEsValido(String correo) {
    final regex = RegExp(r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$');
    return regex.hasMatch(correo);
  }

  void _loginManual() async {
    final correo = _correoController.text.trim();
    final password = _passwordController.text.trim();

    if (correo.isEmpty || password.isEmpty) {
      _mostrarError('Completa correo y contraseña');
      return;
    }

    if (!_correoEsValido(correo)) {
      _mostrarError('Ingresa un correo válido');
      return;
    }

    setState(() => _cargandoLogin = true);

    final provider = Provider.of<UsuarioProvider>(context, listen: false);
    final ok = await provider.login(correo, password);

    if (!mounted) return;

    setState(() => _cargandoLogin = false);

    if (ok) {
      Navigator.pushReplacementNamed(context, '/dashboard');
    } else {
      _mostrarError('Correo o contraseña incorrectos');
    }
  }

  void _loginConGoogle() async {
    print('CP-05: iniciando login con Google');
    setState(() => _cargandoGoogle = true);

    try {
      // Cierra sesión Google anterior para obligar a elegir cuenta nuevamente
      try {
        await _googleSignIn.signOut();
        await _googleSignIn.disconnect();
        print('CP-05: sesión Google anterior cerrada');
      } catch (e) {
        print('CP-05: no había sesión Google previa o ya estaba cerrada');
      }

      final cuenta = await _googleSignIn.signIn();

      if (cuenta == null) {
        print('CP-05: usuario canceló selección de cuenta Google');
        if (mounted) setState(() => _cargandoGoogle = false);
        return;
      }

      print('CP-05: cuenta Google seleccionada: ${cuenta.email}');

      final auth = await cuenta.authentication;
      final idToken = auth.idToken;

      print('CP-05: idToken recibido: ${idToken != null}');

      if (idToken == null) {
        print('CP-05 ERROR: idToken es null');
        _mostrarError('No se pudo obtener el token de Google');
        if (mounted) setState(() => _cargandoGoogle = false);
        return;
      }

      if (!mounted) return;

      final provider = Provider.of<UsuarioProvider>(context, listen: false);
      final ok = await provider.loginConGoogle(idToken);

      print('CP-05: respuesta backend login Google: $ok');

      if (!mounted) return;

      if (ok) {
        print('CP-05 OK: login Google exitoso, navega a dashboard');
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        print('CP-05 ERROR: backend rechazó login Google');
        _mostrarError('Error al iniciar sesión con Google');
      }
    } catch (e) {
      print('CP-05 EXCEPCIÓN LOGIN GOOGLE: $e');
      if (mounted) _mostrarError('Error al iniciar sesión con Google');
    } finally {
      if (mounted) setState(() => _cargandoGoogle = false);
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
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: Column(
                  children: [
                    const SizedBox(height: 60),
                    ScaleTransition(
                      scale: _logoScaleAnimation,
                      child: RotationTransition(
                        turns: _logoRotateAnimation,
                        child: Column(
                          children: [
                            Container(
                              width: 90,
                              height: 90,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(24),
                              ),
                              child: const Icon(
                                Icons.account_tree,
                                color: Color(0xFF185FA5),
                                size: 48,
                              ),
                            ),
                            const SizedBox(height: 20),
                            const Text(
                              'Process SA',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.w700,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Ingresa con tu correo o Google',
                              style: TextStyle(color: Colors.white70),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    FadeTransition(
                      opacity: _fadeAnimation,
                      child: SlideTransition(
                        position: _slideAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(28),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(28),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withOpacity(0.15),
                                blurRadius: 30,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              TextField(
                                key: const Key('emailField'),
                                controller: _correoController,
                                keyboardType: TextInputType.emailAddress,
                                decoration: InputDecoration(
                                  labelText: 'Correo electrónico',
                                  prefixIcon: const Icon(
                                    Icons.email_outlined,
                                    color: Color(0xFF185FA5),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF185FA5),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 16),
                              TextField(
                                key: const Key('passwordField'),
                                controller: _passwordController,
                                obscureText: !_verPassword,
                                decoration: InputDecoration(
                                  labelText: 'Contraseña',
                                  prefixIcon: const Icon(
                                    Icons.lock_outline,
                                    color: Color(0xFF185FA5),
                                  ),
                                  suffixIcon: IconButton(
                                    icon: Icon(
                                      _verPassword
                                          ? Icons.visibility_off
                                          : Icons.visibility,
                                    ),
                                    onPressed: () => setState(
                                      () => _verPassword = !_verPassword,
                                    ),
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                  ),
                                  focusedBorder: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(14),
                                    borderSide: const BorderSide(
                                      color: Color(0xFF185FA5),
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 52,
                                child: ElevatedButton(
                                  key: const Key('loginButton'),
                                  onPressed: _cargandoLogin
                                      ? null
                                      : _loginManual,
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF185FA5),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                  ),
                                  child: _cargandoLogin
                                      ? const CircularProgressIndicator(
                                          color: Colors.white,
                                        )
                                      : const Text(
                                          'Iniciar sesión',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              Row(
                                children: [
                                  const Expanded(child: Divider()),
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                    ),
                                    child: Text(
                                      'O',
                                      style: TextStyle(
                                        color: Colors.grey.shade500,
                                      ),
                                    ),
                                  ),
                                  const Expanded(child: Divider()),
                                ],
                              ),
                              const SizedBox(height: 20),
                              SizedBox(
                                width: double.infinity,
                                height: 54,
                                child: OutlinedButton(
                                  onPressed: _cargandoGoogle
                                      ? null
                                      : _loginConGoogle,
                                  style: OutlinedButton.styleFrom(
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(14),
                                    ),
                                    side: BorderSide(
                                      color: Colors.grey.shade300,
                                    ),
                                  ),
                                  child: _cargandoGoogle
                                      ? const CircularProgressIndicator()
                                      : Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SizedBox(
                                              width: 22,
                                              height: 22,
                                              child: CustomPaint(
                                                painter: _GoogleLogoPainter(),
                                              ),
                                            ),
                                            const SizedBox(width: 12),
                                            const Text(
                                              'Continuar con Google',
                                              style: TextStyle(
                                                color: Colors.black87,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ],
                                        ),
                                ),
                              ),
                              const SizedBox(height: 20),
                              TextButton(
                                onPressed: () => Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) => const RegistroScreen(),
                                  ),
                                ),
                                child: const Text(
                                  '¿No tienes cuenta? Crear cuenta',
                                  style: TextStyle(
                                    color: Color(0xFF185FA5),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleLogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2;

    paint.color = Colors.grey.shade100;
    canvas.drawCircle(center, radius, paint);

    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.8),
      -1.57,
      2.1,
      true,
      paint,
    );

    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.8),
      0.53,
      1.57,
      true,
      paint,
    );

    paint.color = const Color(0xFF34A853);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.8),
      2.1,
      1.57,
      true,
      paint,
    );

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius * 0.8),
      3.67,
      0.84,
      true,
      paint,
    );

    paint.color = Colors.white;
    canvas.drawCircle(center, radius * 0.5, paint);

    paint.color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset(center.dx + radius * 0.2, center.dy),
        width: radius * 0.8,
        height: radius * 0.25,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
