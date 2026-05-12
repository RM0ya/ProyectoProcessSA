package com.merproyecto.service.impl;

import com.merproyecto.model.Proceso;
import com.merproyecto.repository.ProcesoRepository;
import com.merproyecto.service.ProcesoService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ProcesoServiceImpl implements ProcesoService {

    private final ProcesoRepository repository;

    @Override
    public List<Proceso> findAll() {
        return repository.findAll();
    }

    @Override
    public Optional<Proceso> findById(Integer id) {
        return repository.findById(id);
    }

    @Override
    public Proceso save(Proceso entity) {
        return repository.save(entity);
    }

    @Override
    public void deleteById(Integer id) {
        repository.deleteById(id);
    }
}
