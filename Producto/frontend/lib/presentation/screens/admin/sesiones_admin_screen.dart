import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/models/sesion_model.dart';
import '../../../data/providers/usuario_provider.dart';
import '../../../data/services/sesion_service.dart';

class SesionesAdminScreen extends StatefulWidget {
  const SesionesAdminScreen({super.key});

  @override
  State<SesionesAdminScreen> createState() => _SesionesAdminScreenState();
}

class _SesionesAdminScreenState extends State<SesionesAdminScreen> {
  Future<List<SesionModel>>? _futureSesiones;

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _cargarSesiones();
    });
  }

  void _cargarSesiones() {
    final token = Provider.of<UsuarioProvider>(context, listen: false).token;

    final dio = Dio(
      BaseOptions(
        baseUrl: 'http://10.0.2.2:8080/api',
        headers: {if (token != null) 'Authorization': 'Bearer $token'},
      ),
    );

    setState(() {
      _futureSesiones = SesionService(dio).listarTodas();
    });
  }

  Future<void> _recargar() async {
    _cargarSesiones();
  }

  @override
  Widget build(BuildContext context) {
    if (_futureSesiones == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Sesiones de usuarios'),
        backgroundColor: const Color(0xFF185FA5),
        foregroundColor: Colors.white,
      ),
      body: RefreshIndicator(
        onRefresh: _recargar,
        child: FutureBuilder<List<SesionModel>>(
          future: _futureSesiones,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: [
                  const Icon(Icons.error_outline, size: 56, color: Colors.red),
                  const SizedBox(height: 12),
                  const Text(
                    'Error al cargar sesiones',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    snapshot.error.toString(),
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              );
            }

            final sesiones = snapshot.data ?? [];

            if (sesiones.isEmpty) {
              return ListView(
                padding: const EdgeInsets.all(24),
                children: const [
                  SizedBox(height: 80),
                  Icon(
                    Icons.manage_accounts_outlined,
                    size: 64,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'No hay sesiones registradas',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                ],
              );
            }

            final activas = sesiones.where((s) => s.activa).length;
            final cerradas = sesiones.length - activas;

            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: _ResumenSesionCard(
                        titulo: 'Activas',
                        valor: activas.toString(),
                        icono: Icons.online_prediction,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _ResumenSesionCard(
                        titulo: 'Cerradas',
                        valor: cerradas.toString(),
                        icono: Icons.logout,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                const Text(
                  'Historial de sesiones',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: 12),
                ...sesiones.map((s) {
                  final usuario = s.usuario;
                  final nombre = usuario?['nombre']?.toString() ?? 'Usuario';
                  final apellido = usuario?['apellidoP']?.toString() ?? '';
                  final email =
                      usuario?['emailUsuario']?.toString() ?? 'Sin correo';

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: BorderSide(color: Colors.grey.shade200),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(14),
                      leading: CircleAvatar(
                        backgroundColor: s.activa ? Colors.green : Colors.grey,
                        child: Icon(
                          s.activa ? Icons.online_prediction : Icons.logout,
                          color: Colors.white,
                          size: 20,
                        ),
                      ),
                      title: Text(
                        '$nombre $apellido',
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          'Correo: $email\n'
                          'IP: ${s.ipOrigen}\n'
                          'Inicio: ${s.fechaInicioS}\n'
                          'Fin: ${s.fechaFinS ?? 'Sesión activa'}',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ),
                      trailing: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 5,
                        ),
                        decoration: BoxDecoration(
                          color: s.activa
                              ? Colors.green.withOpacity(0.12)
                              : Colors.grey.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          s.activa ? 'ACTIVA' : 'CERRADA',
                          style: TextStyle(
                            color: s.activa ? Colors.green : Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ResumenSesionCard extends StatelessWidget {
  final String titulo;
  final String valor;
  final IconData icono;
  final Color color;

  const _ResumenSesionCard({
    required this.titulo,
    required this.valor,
    required this.icono,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: Row(
        children: [
          Icon(icono, color: color),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                titulo,
                style: const TextStyle(fontSize: 12, color: Colors.grey),
              ),
              Text(
                valor,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
