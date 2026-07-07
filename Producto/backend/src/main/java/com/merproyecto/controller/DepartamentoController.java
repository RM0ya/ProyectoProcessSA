package com.merproyecto.controller;

import com.merproyecto.model.Departamento;
import com.merproyecto.service.DepartamentoService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/departamentos")
@RequiredArgsConstructor
public class DepartamentoController {

    private final DepartamentoService departamentoService;

    // GET /api/departamentos → todos
    @GetMapping
    public List<Departamento> listar() {
        return departamentoService.findAll();
    }

    // GET /api/departamentos/por-organizacion/{idOrganizacion} → filtrado
    @GetMapping("/por-organizacion/{idOrganizacion}")
    public List<Departamento> listarPorOrganizacion(@PathVariable Integer idOrganizacion) {
        return departamentoService.findByOrganizacion(idOrganizacion);
    }

    // GET /api/departamentos/{id}
    @GetMapping("/{id}")
    public ResponseEntity<Departamento> obtener(@PathVariable Integer id) {
        return departamentoService.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    // POST /api/departamentos
    @PostMapping
    public ResponseEntity<Departamento> crear(@RequestBody Departamento departamento) {
        return ResponseEntity.ok(departamentoService.save(departamento));
    }

    // PUT /api/departamentos/{id}
    @PutMapping("/{id}")
    public ResponseEntity<Departamento> actualizar(
            @PathVariable Integer id,
            @RequestBody Departamento datos) {
        return departamentoService.findById(id).map(dep -> {
            dep.setNombre(datos.getNombre());
            dep.setDescripcion(datos.getDescripcion());
            return ResponseEntity.ok(departamentoService.save(dep));
        }).orElse(ResponseEntity.notFound().build());
    }

    // DELETE /api/departamentos/{id}
    @DeleteMapping("/{id}")
    public ResponseEntity<Void> eliminar(@PathVariable Integer id) {
        if (departamentoService.findById(id).isEmpty()) {
            return ResponseEntity.notFound().build();
        }
        departamentoService.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}