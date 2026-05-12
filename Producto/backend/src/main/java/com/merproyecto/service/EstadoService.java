package com.merproyecto.service;

import com.merproyecto.model.Estado;
import java.util.List;
import java.util.Optional;

public interface EstadoService {
    List<Estado> findAll();
    Optional<Estado> findById(Integer id);
    Estado save(Estado entity);
    void deleteById(Integer id);
}
