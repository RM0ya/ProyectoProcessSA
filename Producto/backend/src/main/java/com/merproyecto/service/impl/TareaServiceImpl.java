package com.merproyecto.service.impl;

import com.merproyecto.model.Tarea;
import com.merproyecto.model.TareaId;
import com.merproyecto.repository.TareaRepository;
import com.merproyecto.service.TareaService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;
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
        // Para búsqueda simple solo por id_tarea no aplica directamente
        return Optional.empty();
    }

    public Optional<Tarea> findById(TareaId tareaId) {
        return repository.findById(tareaId);
    }

    @Override
    public Tarea save(Tarea entity) {
        return repository.save(entity);
    }

    @Override
    public void deleteById(Integer id) {
        // Requiere ambas partes de la clave - usar deleteById(TareaId) en su lugar
    }

    public void deleteById(TareaId tareaId) {
        repository.deleteById(tareaId);
    }

    public List<Tarea> findByProceso(Integer idProceso) {
        return repository.findByIdIdProceso(idProceso);
    }

    public List<Tarea> findByUsuario(Integer idUsuario) {
        return repository.findByUsuarioIdUsuario(idUsuario);
    }
}
