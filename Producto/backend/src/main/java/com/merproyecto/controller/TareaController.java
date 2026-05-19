package com.merproyecto.controller;

import com.merproyecto.model.Tarea;
import com.merproyecto.service.TareaService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/tareas")
@RequiredArgsConstructor
@CrossOrigin("*")
public class TareaController {

    private final TareaService service;

    @GetMapping
    public List<Tarea> listar() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Tarea> buscar(@PathVariable Integer id) {

        return service.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Tarea guardar(@RequestBody Tarea tarea) {
        return service.save(tarea);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Integer id) {

        service.deleteById(id);

        return ResponseEntity.noContent().build();
    }

    @GetMapping("/proceso/{idProceso}")
    public List<Tarea> tareasPorProceso(@PathVariable Integer idProceso) {
        return service.findByProceso(idProceso);
    }

    @GetMapping("/usuario/{idUsuario}")
    public List<Tarea> tareasPorUsuario(@PathVariable Integer idUsuario) {
        return service.findByUsuario(idUsuario);
    }
    @PutMapping("/{id}")
    public ResponseEntity<Tarea> actualizar(
            @PathVariable Integer id,
            @RequestBody Tarea tarea) {

        return service.findById(id).map(existing -> {

            existing.setNombreTarea(tarea.getNombreTarea());
            existing.setDescripcionT(tarea.getDescripcionT());
            existing.setOrdenT(tarea.getOrdenT());
            existing.setFechaLimiteS(tarea.getFechaLimiteS());
            existing.setFechaCompletada(tarea.getFechaCompletada());
            existing.setFechaCreacionT(tarea.getFechaCreacionT());
            existing.setProceso(tarea.getProceso());
            existing.setUsuario(tarea.getUsuario());
            existing.setEstado(tarea.getEstado());

            return ResponseEntity.ok(service.save(existing));
        }).orElse(ResponseEntity.notFound().build());
    }
}