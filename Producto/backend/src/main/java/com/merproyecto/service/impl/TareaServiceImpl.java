package com.merproyecto.service.impl;

import com.merproyecto.model.Tarea;
import com.merproyecto.repository.TareaRepository;
import com.merproyecto.service.TareaService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.time.LocalDate;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class TareaServiceImpl implements TareaService {

    private final TareaRepository repository;

    @Override
    public List<Tarea> findAll() {
        return repository.findAll();
    }

    @Override
    public Optional<Tarea> findById(Integer id) {
        return repository.findById(id);
    }

    @Override
    public Tarea save(Tarea entity) {
        return repository.save(entity);
    }

    @Override
    public void deleteById(Integer id) {
        repository.deleteById(id);
    }

    @Override
    public List<Tarea> findByProceso(Integer idProceso) {
        return repository.findByProceso_IdProceso(idProceso);
    }

    @Override
    public List<Tarea> findByUsuario(Integer idUsuario) {
        return repository.findByUsuario_IdUsuario(idUsuario);
    }

    @Override
    public List<Tarea> findByEstado(String estado) {
        return repository.findByEstado_NombreEstado(estado);
    }

    @Override
    public List<Tarea> findTareasVencidas() {
        return repository.findByFechaLimiteSBefore(LocalDate.now());
    }
}