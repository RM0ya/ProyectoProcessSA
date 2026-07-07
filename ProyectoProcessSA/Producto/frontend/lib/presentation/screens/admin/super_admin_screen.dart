import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/usuario_provider.dart';
import '../../../data/providers/notificacion_provider.dart';
import 'sesiones_admin_screen.dart';
import '../notificaciones/notificaciones_screen.dart';
import '../reportes/reportes_screen.dart';

class SuperAdminScreen extends StatefulWidget {
  const SuperAdminScreen({super.key});

  @override
  State<SuperAdminScreen> createState() => _SuperAdminScreenState();
}

class _SuperAdminScreenState extends State<SuperAdminScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _cargarNotificaciones(),
    );
  }

  Future<void> _cargarNotificaciones() async {
    final usuarioProvider = context.read<UsuarioProvider>();
    final notificacionProvider = context.read<NotificacionProvider>();

    final token = usuarioProvider.token;
    final idUsuario = usuarioProvider.usuarioLogueado?.idUsuario;

    if (token != null) {
      notificacionProvider.setToken(token);
    }

    if (idUsuario != null) {
      await notificacionProvider.cargarNotificaciones(idUsuario);
    }
  }

  Future<void> _confirmarLogout(
    BuildContext context,
    UsuarioProvider provider,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas cerrar sesión?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text(
              'Confirmar',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    await provider.cerrarSesion();

    if (!context.mounted) return;

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final usuarioProvider = context.read<UsuarioProvider>();

    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Panel de Super Admin'),
        backgroundColor: const Color(0xFF185FA5),
        foregroundColor: Colors.white,
        actions: [
          Consumer<NotificacionProvider>(
            builder: (context, notiProvider, _) {
              final count = notiProvider.noLeidasCount;
              return Stack(
                clipBehavior: Clip.none,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications_outlined),
                    tooltip: 'Notificaciones',
                    onPressed: () async {
                      await Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const NotificacionesScreen(),
                        ),
                      );
                      if (context.mounted) _cargarNotificaciones();
                    },
                  ),
                  if (count > 0)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        padding: const EdgeInsets.all(3),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        constraints: const BoxConstraints(
                          minWidth: 16,
                          minHeight: 16,
                        ),
                        child: Text(
                          count > 9 ? '9+' : '$count',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 9,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            tooltip: 'Cerrar sesión',
            onPressed: () => _confirmarLogout(context, usuarioProvider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Gestión Global',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              children: [
                _MenuCard(
                  title: 'Organizaciones',
                  icon: Icons.business,
                  color: Colors.indigo,
                  onTap: () => Navigator.pushNamed(context, '/organizaciones'),
                ),
                _MenuCard(
                  title: 'Usuarios',
                  icon: Icons.people,
                  color: Colors.teal,
                  onTap: () => Navigator.pushNamed(context, '/usuarios'),
                ),
                _MenuCard(
                  title: 'Departamentos',
                  icon: Icons.account_tree,
                  color: Colors.orange,
                  onTap: () => Navigator.pushNamed(context, '/departamentos'),
                ),
                _MenuCard(
                  title: 'Sesiones',
                  icon: Icons.manage_accounts,
                  color: Colors.purple,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const SesionesAdminScreen(),
                      ),
                    );
                  },
                ),
                _MenuCard(
                  title: 'Reportes',
                  icon: Icons.analytics,
                  color: Colors.red,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ReportesScreen()),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _MenuCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _MenuCard({
    required this.title,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: color),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
