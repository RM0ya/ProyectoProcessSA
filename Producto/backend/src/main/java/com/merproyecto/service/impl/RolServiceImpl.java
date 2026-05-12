package com.merproyecto.service.impl;

import com.merproyecto.model.Rol;
import com.merproyecto.repository.RolRepository;
import com.merproyecto.service.RolService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class RolServiceImpl implements RolService {

    private final RolRepository repository;

    @Override
    public List<Rol> findAll() {
        return repository.findAll();
    }

    @Override
    public Optional<Rol> findById(Integer id) {
        return repository.findById(id);
    }

    @Override
    public Rol save(Rol entity) {
        return repository.save(entity);
    }

    @Override
    public void deleteById(Integer id) {
        repository.deleteById(id);
    }
}
