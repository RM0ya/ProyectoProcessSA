package com.merproyecto.repository;

import com.merproyecto.model.Departamento;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface DepartamentoRepository extends JpaRepository<Departamento, Integer> {

    // ── NUEVO: buscar departamentos por organización ──
    List<Departamento> findByOrganizacion_IdOrganizacion(Integer idOrganizacion);
}