package com.merproyecto.controller;

import com.merproyecto.model.Reporte;
import com.merproyecto.service.ReporteService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/reportes")
@RequiredArgsConstructor
public class ReporteController {

    private final ReporteService service;

    @GetMapping
    public List<Reporte> getAll() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Reporte> getById(@PathVariable Integer id) {
        return service.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Reporte create(@RequestBody Reporte entity) {
        return service.save(entity);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Reporte> update(@PathVariable Integer id, @RequestBody Reporte entity) {
        return service.findById(id).map(existing -> {
            return ResponseEntity.ok(service.save(entity));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<Void> delete(@PathVariable Integer id) {

        if (service.findById(id).isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        service.deleteById(id);

        return ResponseEntity.noContent().build();
    }
}
