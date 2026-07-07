package com.merproyecto.controller;

import com.merproyecto.model.Proceso;
import com.merproyecto.service.ProcesoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/procesos")
@RequiredArgsConstructor
public class ProcesoController {

    private final ProcesoService service;

    @GetMapping
    public List<Proceso> getAll() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Proceso> getById(@PathVariable Integer id) {
        return service.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Proceso create(@RequestBody Proceso entity) {
        return service.save(entity);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Proceso> update(@PathVariable Integer id, @RequestBody Proceso entity) {
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
