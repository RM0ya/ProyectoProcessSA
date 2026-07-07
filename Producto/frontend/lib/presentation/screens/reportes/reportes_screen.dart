import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../data/providers/usuario_provider.dart';
import '../../../data/services/reporte_service.dart';

class ReportesScreen extends StatefulWidget {
  const ReportesScreen({super.key});

  @override
  State<ReportesScreen> createState() => _ReportesScreenState();
}

class _ReportesScreenState extends State<ReportesScreen> {
  bool _descargando = false;

  Future<void> _descargarReporte() async {
    final provider = Provider.of<UsuarioProvider>(context, listen: false);
    final usuario = provider.usuarioLogueado;

    if (usuario == null) return;

    setState(() => _descargando = true);

    try {
      final service = ReporteService(provider.token);

      if (provider.esAdmin) {
        final idOrg = usuario.organizacion?['idOrganizacion'];

        if (idOrg == null) {
          throw Exception('El usuario no tiene organización asignada');
        }

        await service.descargarReporteOrganizacion(idOrg);
      } else {
        if (usuario.idUsuario == null) {
          throw Exception('No se pudo identificar el usuario');
        }

        await service.descargarReporteUsuario(usuario.idUsuario!);
      }

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reporte generado correctamente'),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error al generar reporte: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }

    if (mounted) {
      setState(() => _descargando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<UsuarioProvider>();
    final esAdmin = provider.esAdmin;

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: const Text('Reportes'),
        backgroundColor: const Color(0xFF185FA5),
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.grey.shade200),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Icon(
                  Icons.picture_as_pdf,
                  size: 42,
                  color: esAdmin ? const Color(0xFF185FA5) : Colors.green,
                ),
                const SizedBox(height: 12),
                Text(
                  esAdmin
                      ? 'Reporte general de tareas'
                      : 'Reporte de mis tareas',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  esAdmin
                      ? 'Como administrador puedes descargar el reporte de todas las tareas de la organización.'
                      : 'Puedes descargar solamente el reporte de tus propias tareas asignadas.',
                  style: const TextStyle(fontSize: 13, color: Colors.grey),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    onPressed: _descargando ? null : _descargarReporte,
                    icon: _descargando
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(Icons.download, color: Colors.white),
                    label: Text(
                      _descargando ? 'Generando...' : 'Generar y descargar PDF',
                      style: const TextStyle(color: Colors.white),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF185FA5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
