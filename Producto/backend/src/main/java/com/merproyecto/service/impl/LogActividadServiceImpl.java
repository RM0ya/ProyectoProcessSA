package com.merproyecto.service.impl;

import com.merproyecto.model.LogActividad;
import com.merproyecto.repository.LogActividadRepository;
import com.merproyecto.service.LogActividadService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class LogActividadServiceImpl implements LogActividadService {

    private final LogActividadRepository repository;

    @Override
    public List<LogActividad> findAll() {
        return repository.findAll();
    }

    @Override
    public Optional<LogActividad> findById(Integer id) {
        return repository.findById(id);
    }

    @Override
    public LogActividad save(LogActividad entity) {
        return repository.save(entity);
    }

    @Override
    public void deleteById(Integer id) {
        repository.deleteById(id);
    }
}
