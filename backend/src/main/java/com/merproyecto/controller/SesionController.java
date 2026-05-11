package com.merproyecto.controller;

import com.merproyecto.model.Sesion;
import com.merproyecto.service.SesionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/sesions")
@RequiredArgsConstructor
public class SesionController {

    private final SesionService service;

    @GetMapping
    public List<Sesion> getAll() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Sesion> getById(@PathVariable Integer id) {
        return service.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Sesion create(@RequestBody Sesion entity) {
        return service.save(entity);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Sesion> update(@PathVariable Integer id, @RequestBody Sesion entity) {
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
