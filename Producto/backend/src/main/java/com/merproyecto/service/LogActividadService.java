package com.merproyecto.service;

import com.merproyecto.model.LogActividad;
import java.util.List;
import java.util.Optional;

public interface LogActividadService {
    List<LogActividad> findAll();
    Optional<LogActividad> findById(Integer id);
    LogActividad save(LogActividad entity);
    void deleteById(Integer id);
}
