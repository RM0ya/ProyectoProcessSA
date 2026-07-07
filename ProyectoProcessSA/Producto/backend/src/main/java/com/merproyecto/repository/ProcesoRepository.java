package com.merproyecto.repository;

import com.merproyecto.model.Proceso;
import org.springframework.data.jpa.repository.JpaRepository;
import java.util.List;

public interface ProcesoRepository extends JpaRepository<Proceso, Integer> {
    List<Proceso> findByOrganizacion_IdOrganizacion(Integer idOrganizacion);


    List<Proceso> findByOrganizacion_IdOrganizacionAndEstado_NombreEstadoNot(
            Integer idOrganizacion, String nombreEstado);
}