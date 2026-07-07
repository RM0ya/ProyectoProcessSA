package com.merproyecto.controller;

import com.merproyecto.model.Estado;
import com.merproyecto.model.Tarea;
import com.merproyecto.model.Usuario;
import com.merproyecto.service.TareaService;
import com.merproyecto.service.UsuarioService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/tareas")
@RequiredArgsConstructor
@CrossOrigin("*")
public class TareaController {

    private final TareaService service;
    private final UsuarioService usuarioService;

    private static final int LIMITE_TAREAS_DIARIAS = 10;

    private Usuario usuarioActual(Principal principal) {
        return usuarioService.findByEmail(principal.getName())
                .orElseThrow(() -> new RuntimeException("Usuario autenticado no encontrado"));
    }

    private boolean esAdminOSuperAdmin(Usuario usuario) {
        if (usuario.getRol() == null) return false;
        String rol = usuario.getRol().getNombre();
        return "Admin".equalsIgnoreCase(rol) || "SuperAdmin".equalsIgnoreCase(rol);
    }

    private boolean esEstadoCompletada(Tarea tarea) {
        Estado estado = tarea.getEstado();
        return estado != null && "Completada".equalsIgnoreCase(estado.getNombreEstado());
    }

    @GetMapping
    public List<Tarea> listar() {
        return service.findAll();
    }

    @GetMapping("/{id}")
    public ResponseEntity<Tarea> buscar(@PathVariable Integer id) {
        return service.findById(id)
                .map(ResponseEntity::ok)
                .orElse(ResponseEntity.notFound().build());
    }

    @GetMapping("/organizacion/{idOrganizacion}")
    public List<Tarea> tareasPorOrganizacion(@PathVariable Integer idOrganizacion) {
        return service.findByOrganizacion(idOrganizacion);
    }

    @GetMapping("/proceso/{idProceso}")
    public List<Tarea> tareasPorProceso(@PathVariable Integer idProceso) {
        return service.findByProceso(idProceso);
    }

    @GetMapping("/usuario/{idUsuario}")
    public List<Tarea> tareasPorUsuario(@PathVariable Integer idUsuario) {
        return service.findByUsuario(idUsuario);
    }

    @PostMapping
    public ResponseEntity<?> guardar(@RequestBody Tarea tarea, Principal principal) {

        Usuario creador = usuarioActual(principal);
        boolean esAdmin = esAdminOSuperAdmin(creador);

        // El usuario dueño de la tarea es el que viene en el body (puede
        // ser el propio usuario autoasignándose, o un usuario distinto si
        // quien crea es Admin asignando a alguien de su organización).
        if (tarea.getUsuario() == null || tarea.getUsuario().getIdUsuario() == null) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Debes indicar el usuario asignado a la tarea"));
        }

        Integer idUsuarioDestino = tarea.getUsuario().getIdUsuario();

        // Un usuario normal solo puede crear tareas para sí mismo, nunca
        // para otro usuario.
        if (!esAdmin && !idUsuarioDestino.equals(creador.getIdUsuario())) {
            return ResponseEntity.status(403)
                    .body(Map.of("error", "No puedes asignar tareas a otro usuario"));
        }

        // Límite de 10 tareas creadas en el día, tanto si se autoasigna el
        // usuario como si el Admin se las asigna a otro.
        long creadasHoy = service.contarTareasCreadasHoy(idUsuarioDestino);
        if (creadasHoy >= LIMITE_TAREAS_DIARIAS) {
            return ResponseEntity.status(409)
                    .body(Map.of("error", "Usuario con máximo de tareas alcanzadas"));
        }

        Tarea guardada = service.save(tarea);
        return ResponseEntity.ok(guardada);
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> actualizar(
            @PathVariable Integer id,
            @RequestBody Tarea tarea,
            Principal principal) {

        Usuario editor = usuarioActual(principal);
        boolean esAdmin = esAdminOSuperAdmin(editor);

        return service.findById(id).map(existing -> {

            boolean esDueno = existing.getUsuario() != null &&
                    existing.getUsuario().getIdUsuario().equals(editor.getIdUsuario());

            // Solo el Admin o el dueño de la tarea pueden editarla.
            if (!esAdmin && !esDueno) {
                return ResponseEntity.status(403)
                        .body(Map.of("error", "No puedes modificar tareas de otros usuarios"));
            }

            // Una tarea ya completada solo puede ser modificada por un
            // Admin (por ejemplo para reabrirla si quedó algo pendiente).
            if (!esAdmin && esEstadoCompletada(existing)) {
                return ResponseEntity.status(403)
                        .body(Map.of("error", "Esta tarea ya está completada; solo un administrador puede modificarla"));
            }

            existing.setNombreTarea(tarea.getNombreTarea());
            existing.setDescripcionT(tarea.getDescripcionT());
            existing.setOrdenT(tarea.getOrdenT());
            existing.setFechaLimiteS(tarea.getFechaLimiteS());
            existing.setFechaCompletada(tarea.getFechaCompletada());
            existing.setFechaCreacionT(tarea.getFechaCreacionT());
            existing.setProceso(tarea.getProceso());
            existing.setUsuario(tarea.getUsuario());
            existing.setEstado(tarea.getEstado());

            return ResponseEntity.ok(service.save(existing));
        }).orElse(ResponseEntity.notFound().build());
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> eliminar(@PathVariable Integer id, Principal principal) {

        Usuario editor = usuarioActual(principal);
        boolean esAdmin = esAdminOSuperAdmin(editor);

        return service.findById(id).map(existing -> {

            boolean esDueno = existing.getUsuario() != null &&
                    existing.getUsuario().getIdUsuario().equals(editor.getIdUsuario());

            if (!esAdmin && !esDueno) {
                return ResponseEntity.status(403)
                        .body(Map.of("error", "No puedes eliminar tareas de otros usuarios"));
            }

            if (!esAdmin && esEstadoCompletada(existing)) {
                return ResponseEntity.status(403)
                        .body(Map.of("error", "Esta tarea ya está completada; solo un administrador puede eliminarla"));
            }

            service.deleteById(id);
            return ResponseEntity.noContent().build();
        }).orElse(ResponseEntity.notFound().build());
    }
    // NUEVO: solo Admin/SuperAdmin pueden reasignar una tarea existente a
// otro usuario de la organización.
    @PutMapping("/{id}/reasignar")
    public ResponseEntity<?> reasignar(
            @PathVariable Integer id,
            @RequestBody Map<String, Integer> body,
            Principal principal) {

        Usuario editor = usuarioActual(principal);

        if (!esAdminOSuperAdmin(editor)) {
            return ResponseEntity.status(403)
                    .body(Map.of("error", "Solo un administrador puede reasignar tareas"));
        }

        Integer idUsuarioNuevo = body.get("idUsuario");
        if (idUsuarioNuevo == null) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Debes indicar idUsuario"));
        }

        return service.findById(id).map(tarea -> {
            Usuario nuevoUsuario = usuarioService.findById(idUsuarioNuevo)
                    .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

            tarea.setUsuario(nuevoUsuario);
            return ResponseEntity.ok(service.save(tarea));
        }).orElse(ResponseEntity.notFound().build());
    }
}