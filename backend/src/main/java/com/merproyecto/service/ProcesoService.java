package com.merproyecto.service;

import com.merproyecto.model.Proceso;
import java.util.List;
import java.util.Optional;

public interface ProcesoService {
    List<Proceso> findAll();
    Optional<Proceso> findById(Integer id);
    Proceso save(Proceso entity);
    void deleteById(Integer id);
}
