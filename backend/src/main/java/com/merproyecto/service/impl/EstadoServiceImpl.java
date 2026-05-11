package com.merproyecto.service.impl;

import com.merproyecto.model.Estado;
import com.merproyecto.repository.EstadoRepository;
import com.merproyecto.service.EstadoService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class EstadoServiceImpl implements EstadoService {

    private final EstadoRepository repository;

    @Override
    public List<Estado> findAll() {
        return repository.findAll();
    }

    @Override
    public Optional<Estado> findById(Integer id) {
        return repository.findById(id);
    }

    @Override
    public Estado save(Estado entity) {
        return repository.save(entity);
    }

    @Override
    public void deleteById(Integer id) {
        repository.deleteById(id);
    }
}
