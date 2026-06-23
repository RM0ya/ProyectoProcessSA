package com.merproyecto.service;

import com.merproyecto.model.Sesion;

import java.util.List;

public interface SesionService {
    Sesion iniciarSesion(Integer idUsuario, String token, String ip);
    Sesion cerrarSesion(Integer idUsuario);
    List<Sesion> listarPorUsuario(Integer idUsuario);
    List<Sesion> listarTodas();
}