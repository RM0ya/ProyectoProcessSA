package com.merproyecto.controller;

import com.merproyecto.model.Kpi;
import com.merproyecto.service.KpiService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/kpis")
@RequiredArgsConstructor
public class KpiController {

    private final KpiService service;

    @GetMapping
    public List<Kpi> getAll() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Kpi> getById(@PathVariable Integer id) {
        return service.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @PostMapping
    public Kpi create(@RequestBody Kpi entity) {
        return service.save(entity);
    }

    @PutMapping("/{id}")
    public ResponseEntity<Kpi> update(@PathVariable Integer id, @RequestBody Kpi entity) {
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
