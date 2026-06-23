package com.merproyecto.repository;

import com.merproyecto.model.Reporte;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;

public interface ReporteRepository extends JpaRepository<Reporte, Integer> {
    List<Reporte> findByOrganizacionIdOrganizacionOrderByGeneradoEnDesc(Integer idOrganizacion);
}