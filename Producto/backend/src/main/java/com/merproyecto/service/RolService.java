package com.merproyecto.service;

import com.merproyecto.model.Rol;
import java.util.List;
import java.util.Optional;

public interface RolService {
    List<Rol> findAll();
    Optional<Rol> findById(Integer id);
    Rol save(Rol entity);
    void deleteById(Integer id);
}
