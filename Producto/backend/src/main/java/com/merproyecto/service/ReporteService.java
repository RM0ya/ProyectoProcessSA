package com.merproyecto.service;

import com.merproyecto.model.Reporte;
import java.util.List;
import java.util.Optional;

public interface ReporteService {
    List<Reporte> findAll();
    Optional<Reporte> findById(Integer id);
    Reporte save(Reporte entity);
    void deleteById(Integer id);
}
