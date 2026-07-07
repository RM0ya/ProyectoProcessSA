package com.merproyecto.controller;

import com.merproyecto.model.Notificacion;
import com.merproyecto.service.NotificacionService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import java.util.List;

@RestController
@RequestMapping("/api/notificaciones")
@RequiredArgsConstructor
public class NotificacionController {

    private final NotificacionService service;

    @GetMapping
    public List<Notificacion> getAll() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Notificacion> getById(@PathVariable Integer id) {
        return service.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // NUEVO: notificaciones dirigidas a un usuario en particular
    // (ej. el superadmin consultando sus notificaciones pendientes)
    @GetMapping("/usuario/{idUsuario}")
    public List<Notificacion> getByUsuario(@PathVariable Integer idUsuario) {
        return service.findByUsuario(idUsuario);
    }

    // NUEVO: marcar una notificación como leída
    @PutMapping("/{id}/marcar-leida")
    public ResponseEntity<?> marcarLeida(@PathVariable Integer id) {
        try {
            Notificacion actualizada = service.marcarLeida(id);
            return ResponseEntity.ok(actualizada);
        } catch (RuntimeException e) {
            return ResponseEntity.notFound().build();
        }
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