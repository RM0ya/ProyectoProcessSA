package com.merproyecto.service;

import com.merproyecto.model.Kpi;
import java.util.List;
import java.util.Optional;

public interface KpiService {
    List<Kpi> findAll();
    Optional<Kpi> findById(Integer id);
    Kpi save(Kpi entity);
    void deleteById(Integer id);
}
