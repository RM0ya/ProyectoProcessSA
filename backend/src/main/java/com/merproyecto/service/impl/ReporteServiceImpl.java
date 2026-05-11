package com.merproyecto.service.impl;

import com.merproyecto.model.Reporte;
import com.merproyecto.repository.ReporteRepository;
import com.merproyecto.service.ReporteService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class ReporteServiceImpl implements ReporteService {

    private final ReporteRepository repository;

    @Override
    public List<Reporte> findAll() {
        return repository.findAll();
    }

    @Override
    public Optional<Reporte> findById(Integer id) {
        return repository.findById(id);
    }

    @Override
    public Reporte save(Reporte entity) {
        return repository.save(entity);
    }

    @Override
    public void deleteById(Integer id) {
        repository.deleteById(id);
    }
}
