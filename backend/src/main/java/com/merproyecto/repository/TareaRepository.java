package com.merproyecto.repository;

import com.merproyecto.model.Tarea;
import com.merproyecto.model.TareaId;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;
import java.util.List;

@Repository
public interface TareaRepository extends JpaRepository<Tarea, TareaId> {
    List<Tarea> findByIdIdProceso(Integer idProceso);
    List<Tarea> findByUsuarioIdUsuario(Integer idUsuario);
}
