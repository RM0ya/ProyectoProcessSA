import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/notificacion_provider.dart';
import '../../../data/providers/usuario_provider.dart';
import 'usuarios_pendientes_screen.dart';

class NotificacionesScreen extends StatefulWidget {
  const NotificacionesScreen({super.key});

  @override
  State<NotificacionesScreen> createState() => _NotificacionesScreenState();
}

class _NotificacionesScreenState extends State<NotificacionesScreen> {
  @override
  void initState() {
    super.initState();
    // Se difiere al siguiente frame para evitar notificar listeners
    // mientras el árbol de widgets todavía se está construyendo.
    WidgetsBinding.instance.addPostFrameCallback((_) => _cargar());
  }

  Future<void> _cargar() async {
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

  String _formatFecha(String? fecha) {
    if (fecha == null) return '';
    // fecha llega como "2026-07-05"
    final partes = fecha.split('-');
    if (partes.length != 3) return fecha;
    return '${partes[2]}/${partes[1]}/${partes[0]}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Notificaciones'),
        backgroundColor: const Color(0xFF185FA5),
        foregroundColor: Colors.white,
      ),
      body: Consumer<NotificacionProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.notificaciones.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.notificaciones.isEmpty) {
            return const Center(
              child: Text(
                'No tienes notificaciones',
                style: TextStyle(color: Colors.grey),
              ),
            );
          }

          return RefreshIndicator(
            onRefresh: _cargar,
            child: ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: provider.notificaciones.length,
              itemBuilder: (context, index) {
                final noti = provider.notificaciones[index];
                final esRegistroPendiente =
                    noti.tipoNoti == 'REGISTRO_PENDIENTE';

                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  color: noti.leida ? Colors.white : const Color(0xFFEAF2FA),
                  child: ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8,
                    ),
                    leading: Icon(
                      esRegistroPendiente
                          ? Icons.person_add_alt_1
                          : Icons.notifications,
                      color: const Color(0xFF185FA5),
                    ),
                    title: Text(
                      noti.mensajeNoti,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: noti.leida
                            ? FontWeight.normal
                            : FontWeight.w600,
                      ),
                    ),
                    subtitle: Padding(
                      padding: const EdgeInsets.only(top: 6),
                      child: Text(
                        _formatFecha(noti.fechaEnvio),
                        style: const TextStyle(
                          fontSize: 11,
                          color: Colors.grey,
                        ),
                      ),
                    ),
                    trailing: esRegistroPendiente
                        ? TextButton(
                            onPressed: () async {
                              if (!noti.leida) {
                                await provider.marcarLeida(noti.idNotificacion);
                                if (context.mounted) await _cargar();
                              }
                              if (!context.mounted) return;
                              await Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      const UsuariosPendientesScreen(),
                                ),
                              );
                              if (context.mounted) _cargar();
                            },
                            child: const Text('Asignar'),
                          )
                        : null,
                    onTap: () async {
                      if (!noti.leida) {
                        await provider.marcarLeida(noti.idNotificacion);
                        if (context.mounted) _cargar();
                      }
                    },
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
