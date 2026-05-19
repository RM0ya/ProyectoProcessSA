package com.merproyecto.repository;

import com.merproyecto.model.Proceso;
import org.springframework.data.jpa.repository.JpaRepository;

public interface ProcesoRepository extends JpaRepository<Proceso, Integer> {
}