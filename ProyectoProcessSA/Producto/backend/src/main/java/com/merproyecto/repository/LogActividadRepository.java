package com.merproyecto.repository;

import com.merproyecto.model.LogActividad;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

@Repository
public interface LogActividadRepository extends JpaRepository<LogActividad, Integer> {
}
