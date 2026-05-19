package com.merproyecto.repository;

import com.merproyecto.model.Tarea;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.time.LocalDate;
import java.util.List;

@Repository
public interface TareaRepository extends JpaRepository<Tarea, Integer> {

    List<Tarea> findByProceso_IdProceso(Integer idProceso);

    List<Tarea> findByUsuario_IdUsuario(Integer idUsuario);

    List<Tarea> findByEstado_NombreEstado(String nombreEstado);

    List<Tarea> findByFechaLimiteSBefore(LocalDate fecha);
}