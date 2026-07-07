package com.merproyecto.service;

import com.merproyecto.model.Tarea;

import java.util.List;
import java.util.Optional;

public interface TareaService {

    List<Tarea> findAll();

    Optional<Tarea> findById(Integer id);

    Tarea save(Tarea entity);

    void deleteById(Integer id);

    List<Tarea> findByProceso(Integer idProceso);

    List<Tarea> findByUsuario(Integer idUsuario);

    List<Tarea> findByEstado(String estado);

    List<Tarea> findTareasVencidas();
}