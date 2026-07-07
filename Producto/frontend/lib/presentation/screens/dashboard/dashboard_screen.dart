import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/usuario_provider.dart';
import '../../../data/providers/tarea_provider.dart';
import '../../../data/providers/proceso_provider.dart';
import '../admin/admin_screen.dart';
import '../reportes/reportes_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  int _currentIndex = 0;
  bool _cargado = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_cargado) {
      _cargado = true;
      // Se difiere la carga al siguiente frame para evitar el error
      // "setState() or markNeedsBuild() called during build", ya que
      // didChangeDependencies() se ejecuta durante la fase de build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _cargarDatos();
      });
    }
  }

  Future<void> _cargarDatos() async {
    final usuarioProvider = context.read<UsuarioProvider>();
    final tareaProvider = context.read<TareaProvider>();
    final procesoProvider = context.read<ProcesoProvider>();

    final esAdmin = usuarioProvider.esAdmin;
    final idUsuario = usuarioProvider.usuarioLogueado?.idUsuario;
    final idOrganizacion =
        usuarioProvider.usuarioLogueado?.organizacion?['idOrganizacion'];
    final token = usuarioProvider.token;

    await Future.wait([
      tareaProvider.cargarTareas(
        esAdmin: esAdmin,
        idUsuario: idUsuario,
        idOrganizacion: idOrganizacion,
        token: token,
      ),
      procesoProvider.cargarProcesos(
        idOrganizacion: idOrganizacion,
        token: token,
      ),
    ]);
  }

  Future<void> _confirmarLogout(UsuarioProvider provider) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Cerrar sesión'),
        content: const Text('¿Deseas cerrar sesión?'),
        actions: [
          TextButton(
            key: const Key('cancelarLogoutButton'),
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            key: const Key('confirmarLogoutButton'),
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

    if (!mounted) return;

    Navigator.of(
      context,
    ).pushNamedAndRemoveUntil('/login', (Route<dynamic> route) => false);
  }

  void _onItemTapped(int index, bool esAdmin) async {
    if (index == 1) {
      await Navigator.pushNamed(context, '/tareas');
      if (mounted) _cargarDatos();
      return;
    }

    if (index == 2) {
      await Navigator.pushNamed(context, '/procesos');
      if (mounted) _cargarDatos();
      return;
    }

    if (index == 3) {
      Navigator.pushNamed(context, '/perfil');
      return;
    }

    if (index == 4) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const ReportesScreen()),
      );
      return;
    }

    if (esAdmin && index == 5) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const AdminScreen()),
      );
      return;
    }

    setState(() => _currentIndex = index);
  }

  String _formatEstado(String? nombreEstado) {
    switch (nombreEstado) {
      case 'Activo':
        return 'En curso';
      case 'Completada':
        return 'Completada';
      case 'Inactivo':
        return 'Pendiente';
      default:
        return nombreEstado ?? 'Sin estado';
    }
  }

  Color _colorEstado(String? nombreEstado) {
    switch (nombreEstado) {
      case 'Activo':
        return Colors.blue;
      case 'Completada':
        return Colors.green;
      case 'Inactivo':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer3<UsuarioProvider, TareaProvider, ProcesoProvider>(
      builder: (context, usuarioProvider, tareaProvider, procesoProvider, _) {
        final usuario = usuarioProvider.usuarioLogueado;
        final esAdmin = usuarioProvider.esAdmin;
        final nombre = usuario?.nombre ?? 'Usuario';
        final rolNombre = usuario?.rol?['nombre'] ?? 'Usuario';
        final apellido = usuario?.apellidoP ?? '';
        final iniciales = nombre.isNotEmpty
            ? nombre[0].toUpperCase() +
                  (apellido.isNotEmpty ? apellido[0].toUpperCase() : '')
            : 'US';

        final safeIndex = _currentIndex > (esAdmin ? 5 : 4) ? 0 : _currentIndex;

        final cargandoDatos =
            tareaProvider.isLoading || procesoProvider.isLoading;

        return Scaffold(
          backgroundColor: Colors.grey[50],
          appBar: AppBar(
            title: const Text('Process SA'),
            backgroundColor: const Color(0xFF185FA5),
            foregroundColor: Colors.white,
            automaticallyImplyLeading: false,
            actions: [
              CircleAvatar(
                backgroundColor: Colors.white24,
                child: Text(
                  iniciales,
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                key: const Key('dashboardLogoutButton'),
                icon: const Icon(Icons.logout, color: Colors.white),
                tooltip: 'Cerrar sesión',
                onPressed: () => _confirmarLogout(usuarioProvider),
              ),
            ],
          ),
          body: RefreshIndicator(
            onRefresh: _cargarDatos,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Hola, $nombre',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '$rolNombre · Process SA',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  if (esAdmin) ...[
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: const Color(0xFF185FA5).withOpacity(0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: const Color(0xFF185FA5).withOpacity(0.3),
                        ),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.shield,
                            size: 14,
                            color: Color(0xFF185FA5),
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Acceso administrador',
                            style: TextStyle(
                              fontSize: 11,
                              color: Color(0xFF185FA5),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 20),
                  _QuickActionCard(
                    icono: Icons.picture_as_pdf,
                    titulo: esAdmin
                        ? 'Generar reporte general'
                        : 'Generar mi reporte',
                    subtitulo: esAdmin
                        ? 'Descarga el PDF con todas las tareas de la organización'
                        : 'Descarga el PDF solo con tus tareas asignadas',
                    color: Colors.red,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => const ReportesScreen(),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  if (cargandoDatos)
                    const Center(
                      child: Padding(
                        padding: EdgeInsets.symmetric(vertical: 24),
                        child: CircularProgressIndicator(),
                      ),
                    )
                  else
                    GridView.count(
                      crossAxisCount: 2,
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio: 1.5,
                      children: [
                        _KpiCard(
                          titulo: 'Tareas activas',
                          valor: '${tareaProvider.tareasActivas}',
                          color: const Color(0xFF185FA5),
                        ),
                        _KpiCard(
                          titulo: 'Cumplimiento',
                          valor: '${tareaProvider.cumplimientoPorcentaje}%',
                          color: const Color(0xFF639922),
                        ),
                        _KpiCard(
                          titulo: 'Procesos',
                          valor: '${procesoProvider.totalProcesos}',
                          color: const Color(0xFF534AB7),
                        ),
                        _KpiCard(
                          titulo: 'Completadas',
                          valor: '${tareaProvider.tareasCompletadas}',
                          color: const Color(0xFF0F6E56),
                        ),
                      ],
                    ),
                  const SizedBox(height: 24),
                  const Text(
                    'Tareas recientes',
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  const SizedBox(height: 12),
                  if (!cargandoDatos && tareaProvider.tareasRecientes.isEmpty)
                    const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'No hay tareas registradas',
                        style: TextStyle(color: Colors.grey),
                      ),
                    )
                  else if (!cargandoDatos)
                    ...tareaProvider.tareasRecientes.map(
                      (tarea) => _TareaItem(
                        titulo: tarea.nombreTarea,
                        estado: _formatEstado(tarea.nombreEstado),
                        colorEstado: _colorEstado(tarea.nombreEstado),
                      ),
                    ),
                ],
              ),
            ),
          ),
          bottomNavigationBar: BottomNavigationBar(
            type: BottomNavigationBarType.fixed,
            selectedItemColor: const Color(0xFF185FA5),
            unselectedItemColor: Colors.grey,
            currentIndex: safeIndex,
            onTap: (i) => _onItemTapped(i, esAdmin),
            items: esAdmin
                ? const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Inicio',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.task),
                      label: 'Tareas',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.account_tree),
                      label: 'Procesos',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Perfil',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.picture_as_pdf),
                      label: 'Reportes',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.admin_panel_settings),
                      label: 'Admin',
                    ),
                  ]
                : const [
                    BottomNavigationBarItem(
                      icon: Icon(Icons.home),
                      label: 'Inicio',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.task),
                      label: 'Tareas',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.account_tree),
                      label: 'Procesos',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.person),
                      label: 'Perfil',
                    ),
                    BottomNavigationBarItem(
                      icon: Icon(Icons.picture_as_pdf),
                      label: 'Reportes',
                    ),
                  ],
          ),
        );
      },
    );
  }
}

class _QuickActionCard extends StatelessWidget {
  final IconData icono;
  final String titulo;
  final String subtitulo;
  final Color color;
  final VoidCallback onTap;

  const _QuickActionCard({
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

class _KpiCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final Color color;

  const _KpiCard({
    required this.titulo,
    required this.valor,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            titulo,
            style: const TextStyle(fontSize: 12, color: Colors.grey),
          ),
          Text(
            valor,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _TareaItem extends StatelessWidget {
  final String titulo;
  final String estado;
  final Color colorEstado;

  const _TareaItem({
    required this.titulo,
    required this.estado,
    required this.colorEstado,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: colorEstado,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(child: Text(titulo, style: const TextStyle(fontSize: 13))),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
            decoration: BoxDecoration(
              color: colorEstado.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              estado,
              style: TextStyle(fontSize: 10, color: colorEstado),
            ),
          ),
        ],
      ),
    );
  }
}
