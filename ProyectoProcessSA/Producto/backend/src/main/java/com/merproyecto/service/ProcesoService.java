package com.merproyecto.service;

import com.merproyecto.model.Proceso;
import com.merproyecto.model.Usuario;
import java.util.List;
import java.util.Optional;

public interface ProcesoService {
    List<Proceso> findAll();
    Optional<Proceso> findById(Integer id);
    Proceso save(Proceso entity);
    void deleteById(Integer id);
    List<Proceso> findByOrganizacion(Integer idOrganizacion);

    // NUEVO: solo procesos no completados (para Usuario normal)
    List<Proceso> findActivosByOrganizacion(Integer idOrganizacion);

    // NUEVO: cambia el estado de un proceso y registra auditoría si
    // el nuevo estado es "Completada"
    Proceso cambiarEstado(Integer idProceso, Integer idEstado, Usuario editor, String ip);
}