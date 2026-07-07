package com.merproyecto.controller;

import com.merproyecto.model.Departamento;
import com.merproyecto.model.Organizacion;
import com.merproyecto.model.Rol;
import com.merproyecto.model.Usuario;
import com.merproyecto.repository.DepartamentoRepository;
import com.merproyecto.repository.OrganizacionRepository;
import com.merproyecto.repository.RolRepository;
import com.merproyecto.service.UsuarioService;

import lombok.RequiredArgsConstructor;

import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.security.Principal;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/usuarios")
@RequiredArgsConstructor
public class UsuarioController {

    private final UsuarioService usuarioService;
    private final RolRepository rolRepository;
    private final OrganizacionRepository organizacionRepository;
    private final DepartamentoRepository departamentoRepository;

    @GetMapping
    public List<Usuario> listarUsuarios() {
        return usuarioService.findAll();
    }

    @GetMapping("/organizacion/{idOrganizacion}")
    public List<Usuario> listarPorOrganizacion(@PathVariable Integer idOrganizacion) {
        return usuarioService.findByOrganizacion(idOrganizacion);
    }

    @GetMapping("/pendientes")
    public List<Usuario> listarPendientesDeOrganizacion() {
        return usuarioService.findAll().stream()
                .filter(u -> u.getOrganizacion() == null)
                .toList();
    }

    // NUEVO: creación de usuarios por Admin/SuperAdmin desde el panel.
    // Distinto del registro público (/crear), este endpoint SÍ respeta
    // el rol, organización y departamento que el creador seleccionó en
    // el formulario, en vez de forzar valores por defecto. Requiere
    // autenticación (no está en la lista de rutas públicas del JwtFilter).
    @PostMapping("/crear-staff")
    public ResponseEntity<?> crearUsuarioPorStaff(
            @RequestBody Usuario nuevoUsuario,
            Principal principal) {

        if (usuarioService.findByEmail(nuevoUsuario.getEmailUsuario()).isPresent()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "El correo ya existe"));
        }

        Usuario creador = usuarioService.findByEmail(principal.getName())
                .orElseThrow(() -> new RuntimeException("Usuario creador no encontrado"));

        nuevoUsuario.setBloqueado('N');
        nuevoUsuario.setIntentosFallidos(0);
        nuevoUsuario.setFechaCreacion(LocalDate.now());
        nuevoUsuario.setUltimoLogin(LocalDateTime.now());

        Integer idRol = nuevoUsuario.getRol() != null ? nuevoUsuario.getRol().getIdRol() : null;
        Rol rol = rolRepository.findById(idRol != null ? idRol : 2)
                .orElseThrow(() -> new RuntimeException("Rol no encontrado"));
        nuevoUsuario.setRol(rol);

        if (nuevoUsuario.getOrganizacion() != null &&
                nuevoUsuario.getOrganizacion().getIdOrganizacion() != null) {

            Organizacion org = organizacionRepository.findById(
                    nuevoUsuario.getOrganizacion().getIdOrganizacion()
            ).orElseThrow(() -> new RuntimeException("Organización no encontrada"));

            nuevoUsuario.setOrganizacion(org);
        } else {
            nuevoUsuario.setOrganizacion(null);
        }

        if (nuevoUsuario.getDepartamento() != null &&
                nuevoUsuario.getDepartamento().getIdDepartamento() != null) {

            Departamento dep = departamentoRepository.findById(
                    nuevoUsuario.getDepartamento().getIdDepartamento()
            ).orElseThrow(() -> new RuntimeException("Departamento no encontrado"));

            nuevoUsuario.setDepartamento(dep);
        } else {
            nuevoUsuario.setDepartamento(null);
        }

        Usuario creado = usuarioService.crearUsuario(nuevoUsuario, creador);

        return ResponseEntity.ok(creado);
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> eliminarUsuario(@PathVariable Integer id) {

        usuarioService.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        usuarioService.deleteById(id);

        return ResponseEntity.ok(Map.of("mensaje", "Usuario eliminado correctamente"));
    }

    @PutMapping("/{id}/asignar-organizacion")
    public ResponseEntity<?> asignarOrganizacion(
            @PathVariable Integer id,
            @RequestBody Map<String, Integer> body) {

        Integer idOrganizacion = body.get("idOrganizacion");

        if (idOrganizacion == null) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "Debes indicar idOrganizacion"));
        }

        Usuario usuario = usuarioService.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        Organizacion org = organizacionRepository.findById(idOrganizacion)
                .orElseThrow(() -> new RuntimeException("Organización no encontrada"));

        usuario.setOrganizacion(org);

        Usuario actualizado = usuarioService.save(usuario);

        return ResponseEntity.ok(actualizado);
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> actualizarUsuario(
            @PathVariable Integer id,
            @RequestBody Usuario usuarioActualizado) {

        Usuario usuario = usuarioService.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        usuario.setNombre(usuarioActualizado.getNombre());
        usuario.setApellidoP(usuarioActualizado.getApellidoP());
        usuario.setApellidoM(usuarioActualizado.getApellidoM());
        usuario.setEmailUsuario(usuarioActualizado.getEmailUsuario());

        if (usuarioActualizado.getPassword() != null &&
                !usuarioActualizado.getPassword().isEmpty()) {
            usuario.setPassword(usuarioActualizado.getPassword());
        }

        usuario.setTelefono(usuarioActualizado.getTelefono());
        usuario.setBloqueado(usuarioActualizado.getBloqueado());

        if (usuarioActualizado.getRol() != null &&
                usuarioActualizado.getRol().getIdRol() != null) {

            Rol rol = rolRepository.findById(
                    usuarioActualizado.getRol().getIdRol()
            ).orElseThrow(() -> new RuntimeException("Rol no encontrado"));

            usuario.setRol(rol);
        }

        if (usuarioActualizado.getOrganizacion() != null &&
                usuarioActualizado.getOrganizacion().getIdOrganizacion() != null) {

            Organizacion org = organizacionRepository.findById(
                    usuarioActualizado.getOrganizacion().getIdOrganizacion()
            ).orElseThrow(() -> new RuntimeException("Organización no encontrada"));

            usuario.setOrganizacion(org);
        } else {
            usuario.setOrganizacion(null);
        }

        if (usuarioActualizado.getDepartamento() != null &&
                usuarioActualizado.getDepartamento().getIdDepartamento() != null) {

            Departamento dep = departamentoRepository.findById(
                    usuarioActualizado.getDepartamento().getIdDepartamento()
            ).orElseThrow(() -> new RuntimeException("Departamento no encontrado"));

            usuario.setDepartamento(dep);

        } else {
            usuario.setDepartamento(null);
        }

        Usuario actualizado = usuarioService.save(usuario);

        return ResponseEntity.ok(actualizado);
    }
}