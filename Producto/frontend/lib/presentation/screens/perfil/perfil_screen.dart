import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/usuario_provider.dart';
import '../editar_perfil/editar_perfil_screen.dart';
import '../notificaciones/notificaciones_config_screen.dart';

class PerfilScreen extends StatelessWidget {
  const PerfilScreen({super.key});

  String _iniciales(String nombre, String apellido) {
    final n = nombre.isNotEmpty ? nombre[0] : '';
    final a = apellido.isNotEmpty ? apellido[0] : '';
    return '$n$a'.toUpperCase();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UsuarioProvider>(context);
    final usuario = provider.usuarioLogueado;

    if (usuario == null) {
      return const Scaffold(
        body: Center(
          child: Text('No hay usuario conectado'),
        ),
      );
    }

    final nombreCompleto =
        '${usuario.nombre} ${usuario.apellidoP}'.trim();

    final rol = usuario.rol?['nombre']?.toString() ?? 'Usuario';

    final organizacion =
        usuario.organizacion?['nombre']?.toString() ?? 'Sin organización';

    final departamento =
        usuario.departamento?['nombre']?.toString() ?? 'Sin departamento';

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Perfil', style: TextStyle(color: Colors.white)),
        backgroundColor: const Color(0xFF185FA5),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: Colors.white),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditarPerfilScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 36,
                    backgroundColor: const Color(0xFFE6F1FB),
                    child: Text(
                      _iniciales(usuario.nombre, usuario.apellidoP),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w600,
                        color: Color(0xFF185FA5),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    nombreCompleto,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    usuario.emailUsuario,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFFE6F1FB),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      rol,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Color(0xFF0C447C),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    height: 40,
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const EditarPerfilScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text('Editar perfil'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF185FA5),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _InfoRow(
                    icono: Icons.email_outlined,
                    label: 'Correo',
                    valor: usuario.emailUsuario,
                  ),
                  _InfoRow(
                    icono: Icons.phone_outlined,
                    label: 'Teléfono',
                    valor: usuario.telefono ?? 'Sin teléfono',
                  ),
                  _InfoRow(
                    icono: Icons.work_outline,
                    label: 'Rol',
                    valor: rol,
                  ),
                  _InfoRow(
                    icono: Icons.business_outlined,
                    label: 'Organización',
                    valor: organizacion,
                  ),
                  _InfoRow(
                    icono: Icons.apartment_outlined,
                    label: 'Departamento',
                    valor: departamento,
                  ),
                  _InfoRow(
                    icono: Icons.access_time,
                    label: 'Último acceso',
                    valor: usuario.ultimoLogin ?? 'Sin registro',
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              const NotificacionesConfigScreen(),
                        ),
                      );
                    },
                    child: const _MenuRow(
                      icono: Icons.notifications_outlined,
                      label: 'Notificaciones',
                      color: Colors.orange,
                    ),
                  ),
                  const _MenuRow(
                    icono: Icons.bar_chart,
                    label: 'Reportes',
                    color: Colors.green,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    provider.cerrarSesion();
                    Navigator.pushReplacementNamed(context, '/login');
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red.shade50,
                    foregroundColor: Colors.red,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                      side: BorderSide(color: Colors.red.shade200),
                    ),
                  ),
                  child: const Text(
                    'Cerrar sesión',
                    style: TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        selectedItemColor: const Color(0xFF185FA5),
        currentIndex: 3,
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
            Navigator.pushReplacementNamed(context, '/tareas');
          } else if (index == 2) {
            Navigator.pushReplacementNamed(context, '/procesos');
          }
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Inicio'),
          BottomNavigationBarItem(icon: Icon(Icons.task), label: 'Tareas'),
          BottomNavigationBarItem(
            icon: Icon(Icons.account_tree),
            label: 'Procesos',
          ),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Perfil'),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icono;
  final String label;
  final String valor;

  const _InfoRow({
    required this.icono,
    required this.label,
    required this.valor,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Icon(icono, size: 18, color: const Color(0xFF185FA5)),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          const Spacer(),
          Flexible(
            child: Text(
              valor,
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}

class _MenuRow extends StatelessWidget {
  final IconData icono;
  final String label;
  final Color color;

  const _MenuRow({
    required this.icono,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 11),
      child: Row(
        children: [
          Icon(icono, size: 18, color: color),
          const SizedBox(width: 12),
          Text(label, style: const TextStyle(fontSize: 13)),
          const Spacer(),
          const Icon(Icons.chevron_right, size: 18, color: Colors.grey),
        ],
      ),
    );
  }
}