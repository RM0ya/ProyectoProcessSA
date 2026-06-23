package com.merproyecto.repository;

import com.merproyecto.model.Sesion;
import org.springframework.data.jpa.repository.JpaRepository;

import java.util.List;
import java.util.Optional;

public interface SesionRepository extends JpaRepository<Sesion, Integer> {

    List<Sesion> findByUsuarioIdUsuarioOrderByFechaInicioSDesc(Integer idUsuario);

    Optional<Sesion> findTopByUsuarioIdUsuarioAndFechaFinSIsNullOrderByFechaInicioSDesc(Integer idUsuario);
    List<Sesion> findAllByOrderByFechaInicioSDesc();
}