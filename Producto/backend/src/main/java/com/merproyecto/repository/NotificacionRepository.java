package com.merproyecto.repository;

import com.merproyecto.model.Notificacion;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;

@Repository
public interface NotificacionRepository extends JpaRepository<Notificacion, Integer> {

    // NUEVO: notificaciones de un usuario específico, las más recientes primero
    List<Notificacion> findByUsuario_IdUsuarioOrderByFechaEnvioDesc(Integer idUsuario);
}