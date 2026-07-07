package com.merproyecto.controller;

import com.merproyecto.model.Proceso;
import com.merproyecto.model.Usuario;
import com.merproyecto.service.ProcesoService;
import com.merproyecto.service.UsuarioService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/procesos")
@RequiredArgsConstructor
public class ProcesoController {

    private final ProcesoService service;
    private final UsuarioService usuarioService;

    private Usuario usuarioActual(Principal principal) {
        return usuarioService.findByEmail(principal.getName())
                .orElseThrow(() -> new RuntimeException("Usuario autenticado no encontrado"));
    }

    private boolean esAdminOSuperAdmin(Usuario usuario) {
        if (usuario.getRol() == null) return false;
        String rol = usuario.getRol().getNombre();
        return "Admin".equalsIgnoreCase(rol) || "SuperAdmin".equalsIgnoreCase(rol);
    }

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

    // Un Usuario normal solo recibe procesos no completados (los "activos").
    // Admin/SuperAdmin reciben la lista completa, incluyendo el historial
    // de procesos completados.
    @GetMapping("/organizacion/{idOrganizacion}")
    public List<Proceso> procesosPorOrganizacion(
            @PathVariable Integer idOrganizacion,
            Principal principal) {

        Usuario usuario = usuarioActual(principal);

        if (esAdminOSuperAdmin(usuario)) {
            return service.findByOrganizacion(idOrganizacion);
        }

        return service.findActivosByOrganizacion(idOrganizacion);
    }

    @PostMapping
    public ResponseEntity<?> create(@RequestBody Proceso entity, Principal principal) {
        Usuario creador = usuarioActual(principal);

        if (!esAdminOSuperAdmin(creador)) {
            return ResponseEntity.status(403)
                    .body(Map.of("error", "Solo un administrador puede crear procesos"));
        }

        return ResponseEntity.ok(service.save(entity));
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> update(
            @PathVariable Integer id,
            @RequestBody Proceso entity,
            Principal principal) {

        Usuario editor = usuarioActual(principal);

        if (!esAdminOSuperAdmin(editor)) {
            return ResponseEntity.status(403)
                    .body(Map.of("error", "Solo un administrador puede editar procesos"));
        }

        return service.findById(id)
                .map(existing -> ResponseEntity.ok(service.save(entity)))
                .orElse(ResponseEntity.notFound().build());
    }

    // NUEVO: cambio de estado dedicado (Activo / En revisión / Completada),
    // separado de la edición general para poder registrar auditoría solo
    // cuando corresponde.
    @PutMapping("/{id}/estado")
    public ResponseEntity<?> cambiarEstado(
            @PathVariable Integer id,
            @RequestBody Map<String, Integer> body,
            HttpServletRequest request,
            Principal principal) {

        Usuario editor = usuarioActual(principal);

        if (!esAdminOSuperAdmin(editor)) {
            return ResponseEntity.status(403)
                    .body(Map.of("error", "Solo un administrador puede cambiar el estado del proceso"));
        }

        Integer idEstado = body.get("idEstado");
        if (idEstado == null) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Debes indicar idEstado"));
        }

        Proceso actualizado = service.cambiarEstado(id, idEstado, editor, request.getRemoteAddr());
        return ResponseEntity.ok(actualizado);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> delete(@PathVariable Integer id, Principal principal) {

        Usuario editor = usuarioActual(principal);

        if (!esAdminOSuperAdmin(editor)) {
            return ResponseEntity.status(403)
                    .body(Map.of("error", "Solo un administrador puede eliminar procesos"));
        }

        if (service.findById(id).isEmpty()) {
            return ResponseEntity.notFound().build();
        }

        service.deleteById(id);
        return ResponseEntity.noContent().build();
    }
}