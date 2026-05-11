package com.merproyecto.service.impl;

import com.merproyecto.model.Sesion;
import com.merproyecto.repository.SesionRepository;
import com.merproyecto.service.SesionService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class SesionServiceImpl implements SesionService {

    private final SesionRepository repository;

    @Override
    public List<Sesion> findAll() {
        return repository.findAll();
    }

    @Override
    public Optional<Sesion> findById(Integer id) {
        return repository.findById(id);
    }

    @Override
    public Sesion save(Sesion entity) {
        return repository.save(entity);
    }

    @Override
    public void deleteById(Integer id) {
        repository.deleteById(id);
    }
}
