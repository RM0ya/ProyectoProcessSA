package com.merproyecto.controller;

import com.merproyecto.model.Estado;
import com.merproyecto.service.EstadoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/estados")
@RequiredArgsConstructor
public class EstadoController {

    private final EstadoService service;

    @GetMapping
    public List<Estado> getAll() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Estado> getById(@PathVariable Integer id) {
        return service.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Estado create(@RequestBody Estado entity) {
        return service.save(entity);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Estado> update(@PathVariable Integer id, @RequestBody Estado entity) {
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
