package com.merproyecto.service;

import com.merproyecto.model.Organizacion;
import java.util.List;
import java.util.Optional;

public interface OrganizacionService {
    List<Organizacion> findAll();
    Optional<Organizacion> findById(Integer id);
    Organizacion save(Organizacion entity);
    void deleteById(Integer id);
}
