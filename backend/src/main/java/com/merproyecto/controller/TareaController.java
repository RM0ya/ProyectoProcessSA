package com.merproyecto.controller;

import com.merproyecto.model.Tarea;
import com.merproyecto.model.TareaId;
import com.merproyecto.service.impl.TareaServiceImpl;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/tareas")
@RequiredArgsConstructor
public class TareaController {

    private final TareaServiceImpl service;

    @GetMapping
    public List<Tarea> getAll() {
        return service.findAll();
    }

    @GetMapping("/{idTarea}/{idProceso}")
    public ResponseEntity<Tarea> getById(@PathVariable Integer idTarea,
                                          @PathVariable Integer idProceso) {
        return service.findById(new TareaId(idTarea, idProceso))
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/proceso/{idProceso}")
    public List<Tarea> getByProceso(@PathVariable Integer idProceso) {
        return service.findByProceso(idProceso);
    }

    @GetMapping("/usuario/{idUsuario}")
    public List<Tarea> getByUsuario(@PathVariable Integer idUsuario) {
        return service.findByUsuario(idUsuario);
    }

    @PostMapping
    public Tarea create(@RequestBody Tarea tarea) {
        return service.save(tarea);
    }

    @DeleteMapping("/{idTarea}/{idProceso}")
    public ResponseEntity<Void> delete(@PathVariable Integer idTarea,
                                       @PathVariable Integer idProceso) {

        TareaId id = new TareaId(idTarea, idProceso);

        if (service.findById(id).isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        service.deleteById(id);

        return ResponseEntity.noContent().build();
    }
}
