package com.merproyecto.service.impl;

import com.merproyecto.model.Estado;
import com.merproyecto.model.LogActividad;
import com.merproyecto.model.Proceso;
import com.merproyecto.model.Usuario;
import com.merproyecto.repository.EstadoRepository;
import com.merproyecto.repository.ProcesoRepository;
import com.merproyecto.service.LogActividadService;
import com.merproyecto.service.ProcesoService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ProcesoServiceImpl implements ProcesoService {

    private final ProcesoRepository repository;
    private final EstadoRepository estadoRepository;
    private final LogActividadService logActividadService;

    @Override
    public List<Proceso> findAll() {
        return repository.findAll();
    }

    @Override
    public Optional<Proceso> findById(Integer id) {
        return repository.findById(id);
    }

    @Override
    public Proceso save(Proceso entity) {
        return repository.save(entity);
    }

    @Override
    public void deleteById(Integer id) {
        repository.deleteById(id);
    }

    @Override
    public List<Proceso> findByOrganizacion(Integer idOrganizacion) {
        return repository.findByOrganizacion_IdOrganizacion(idOrganizacion);
    }

    @Override
    public List<Proceso> findActivosByOrganizacion(Integer idOrganizacion) {
        return repository.findByOrganizacion_IdOrganizacionAndEstado_NombreEstadoNot(
                idOrganizacion, "Completada");
    }

    @Override
    public Proceso cambiarEstado(Integer idProceso, Integer idEstado, Usuario editor, String ip) {
        Proceso proceso = repository.findById(idProceso)
                .orElseThrow(() -> new RuntimeException("Proceso no encontrado"));

        Estado estado = estadoRepository.findById(idEstado)
                .orElseThrow(() -> new RuntimeException("Estado no encontrado"));

        proceso.setEstado(estado);
        Proceso guardado = repository.save(proceso);


        if ("Completada".equalsIgnoreCase(estado.getNombreEstado())) {
            LogActividad log = new LogActividad();
            log.setAccionLog("PROCESO_COMPLETADO");
            log.setModuloLog("PROCESOS");
            log.setDetalleLog(
                    "Proceso '" + proceso.getNombre() + "' marcado como completado por "
                            + editor.getNombre() + " " + editor.getApellidoP()
            );
            log.setIpLog(ip != null ? ip : "N/A");
            log.setFechaHora(LocalDateTime.now());
            log.setUsuario(editor);
            logActividadService.save(log);
        }

        return guardado;
    }
}