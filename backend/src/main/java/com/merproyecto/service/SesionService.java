package com.merproyecto.service;

import com.merproyecto.model.Sesion;
import java.util.List;
import java.util.Optional;

public interface SesionService {
    List<Sesion> findAll();
    Optional<Sesion> findById(Integer id);
    Sesion save(Sesion entity);
    void deleteById(Integer id);
}
