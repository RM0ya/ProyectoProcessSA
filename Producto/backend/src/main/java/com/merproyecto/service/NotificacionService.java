package com.merproyecto.service;

import com.merproyecto.model.Notificacion;
import com.merproyecto.model.Usuario;

import java.util.List;
import java.util.Optional;

public interface NotificacionService {
    List<Notificacion> findAll();
    Optional<Notificacion> findById(Integer id);
    Notificacion save(Notificacion entity);
    void deleteById(Integer id);

    // NUEVO
    List<Notificacion> findByUsuario(Integer idUsuario);
    Notificacion crearParaUsuario(Usuario usuario, String tipoNoti, String mensaje);
    Notificacion marcarLeida(Integer id);
}