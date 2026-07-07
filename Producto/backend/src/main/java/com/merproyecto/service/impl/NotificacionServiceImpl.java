package com.merproyecto.service.impl;

import com.merproyecto.model.Notificacion;
import com.merproyecto.model.Usuario;
import com.merproyecto.repository.NotificacionRepository;
import com.merproyecto.service.NotificacionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class NotificacionServiceImpl implements NotificacionService {

    private final NotificacionRepository repository;

    @Override
    public List<Notificacion> findAll() {
        return repository.findAll();
    }

    @Override
    public Optional<Notificacion> findById(Integer id) {
        return repository.findById(id);
    }

    @Override
    public Notificacion save(Notificacion entity) {
        return repository.save(entity);
    }

    @Override
    public void deleteById(Integer id) {
        repository.deleteById(id);
    }

    @Override
    public List<Notificacion> findByUsuario(Integer idUsuario) {
        return repository.findByUsuario_IdUsuarioOrderByFechaEnvioDesc(idUsuario);
    }

    @Override
    public Notificacion crearParaUsuario(Usuario usuario, String tipoNoti, String mensaje) {
        Notificacion notificacion = new Notificacion();
        notificacion.setUsuario(usuario);
        notificacion.setTipoNoti(tipoNoti);
        notificacion.setMensajeNoti(mensaje);
        notificacion.setNotiLeida('N');
        notificacion.setFechaEnvio(LocalDate.now());
        return repository.save(notificacion);
    }

    @Override
    public Notificacion marcarLeida(Integer id) {
        Notificacion notificacion = repository.findById(id)
                .orElseThrow(() -> new RuntimeException("Notificación no encontrada"));

        notificacion.setNotiLeida('S');
        notificacion.setFechaLectura(LocalDateTime.now());
        return repository.save(notificacion);
    }
}