package com.merproyecto.controller;

import com.merproyecto.model.LogActividad;
import com.merproyecto.service.LogActividadService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/logs")
@RequiredArgsConstructor
public class LogActividadController {

    private final LogActividadService service;

    @GetMapping
    public List<LogActividad> getAll() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<LogActividad> getById(@PathVariable Integer id) {
        return service.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
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
