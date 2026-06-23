package com.merproyecto.service.impl;

import com.merproyecto.model.Sesion;
import com.merproyecto.model.Usuario;
import com.merproyecto.repository.SesionRepository;
import com.merproyecto.repository.UsuarioRepository;
import com.merproyecto.service.SesionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;

@Service
@RequiredArgsConstructor
public class SesionServiceImpl implements SesionService {

    private final SesionRepository sesionRepository;
    private final UsuarioRepository usuarioRepository;

    @Override
    public Sesion iniciarSesion(Integer idUsuario, String token, String ip) {
        Usuario usuario = usuarioRepository.findById(idUsuario)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        Sesion sesion = new Sesion();
        sesion.setUsuario(usuario);
        sesion.setToken(token);
        sesion.setIpOrigen(ip);
        sesion.setFechaInicioS(LocalDateTime.now());
        sesion.setTipoEvento("LOGIN");
        sesion.setFechaFinS(null);

        return sesionRepository.save(sesion);
    }

    @Override
    public Sesion cerrarSesion(Integer idUsuario) {
        Sesion sesion = sesionRepository
                .findTopByUsuarioIdUsuarioAndFechaFinSIsNullOrderByFechaInicioSDesc(idUsuario)
                .orElseThrow(() -> new RuntimeException("No hay sesión activa"));

        sesion.setFechaFinS(LocalDateTime.now());
        sesion.setTipoEvento("LOGOUT");

        return sesionRepository.save(sesion);
    }

    @Override
    public List<Sesion> listarPorUsuario(Integer idUsuario) {
        return sesionRepository.findByUsuarioIdUsuarioOrderByFechaInicioSDesc(idUsuario);
    }
    @Override
    public List<Sesion> listarTodas() {
        return sesionRepository.findAllByOrderByFechaInicioSDesc();
    }
}