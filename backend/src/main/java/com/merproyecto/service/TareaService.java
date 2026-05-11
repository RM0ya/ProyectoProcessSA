package com.merproyecto.service;

import com.merproyecto.model.Tarea;
import java.util.List;
import java.util.Optional;

public interface TareaService {
    List<Tarea> findAll();
    Optional<Tarea> findById(Integer id);
    Tarea save(Tarea entity);
    void deleteById(Integer id);
}
