package com.merproyecto.service.impl;

import com.merproyecto.model.Kpi;
import com.merproyecto.repository.KpiRepository;
import com.merproyecto.service.KpiService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class KpiServiceImpl implements KpiService {

    private final KpiRepository repository;

    @Override
    public List<Kpi> findAll() {
        return repository.findAll();
    }

    @Override
    public Optional<Kpi> findById(Integer id) {
        return repository.findById(id);
    }

    @Override
    public Kpi save(Kpi entity) {
        return repository.save(entity);
    }

    @Override
    public void deleteById(Integer id) {
        repository.deleteById(id);
    }
}
