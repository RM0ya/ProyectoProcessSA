package com.merproyecto.controller;

import com.merproyecto.model.Organizacion;
import com.merproyecto.service.OrganizacionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/organizaciones")
@RequiredArgsConstructor
public class OrganizacionController {

    private final OrganizacionService service;

    @GetMapping
    public List<Organizacion> getAll() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Organizacion> getById(@PathVariable Integer id) {
        return service.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Organizacion create(@RequestBody Organizacion entity) {
        return service.save(entity);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Organizacion> update(@PathVariable Integer id, @RequestBody Organizacion entity) {
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
