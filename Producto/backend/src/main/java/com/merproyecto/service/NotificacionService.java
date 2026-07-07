package com.merproyecto.service;

import com.merproyecto.model.Notificacion;
import java.util.List;
import java.util.Optional;

public interface NotificacionService {
    List<Notificacion> findAll();
    Optional<Notificacion> findById(Integer id);
    Notificacion save(Notificacion entity);
    void deleteById(Integer id);
}
