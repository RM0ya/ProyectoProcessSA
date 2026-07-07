package com.merproyecto.service.impl;

import com.merproyecto.model.Notificacion;
import com.merproyecto.repository.NotificacionRepository;
import com.merproyecto.service.NotificacionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
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
}
