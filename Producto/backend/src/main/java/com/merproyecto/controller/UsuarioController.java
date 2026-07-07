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

import java.util.List;

@RestController
@RequestMapping("/api/usuarios")
@RequiredArgsConstructor
public class UsuarioController {

    private final UsuarioService usuarioService;
    private final RolRepository rolRepository;
    private final OrganizacionRepository organizacionRepository;
    private final DepartamentoRepository departamentoRepository; // NUEVO

    @GetMapping
    public List<Usuario> listarUsuarios() {
        return usuarioService.findAll();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> eliminarUsuario(@PathVariable Integer id) {

        usuarioService.findById(id)
                .orElseThrow(() -> new RuntimeException("Usuario no encontrado"));

        usuarioService.deleteById(id);

        return ResponseEntity.ok("Usuario eliminado correctamente");
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

        // Rol
        if (usuarioActualizado.getRol() != null &&
                usuarioActualizado.getRol().getIdRol() != null) {

            Rol rol = rolRepository.findById(
                    usuarioActualizado.getRol().getIdRol()
            ).orElseThrow(() -> new RuntimeException("Rol no encontrado"));

            usuario.setRol(rol);
        }

        // Organización
        if (usuarioActualizado.getOrganizacion() != null &&
                usuarioActualizado.getOrganizacion().getIdOrganizacion() != null) {

            Organizacion org = organizacionRepository.findById(
                    usuarioActualizado.getOrganizacion().getIdOrganizacion()
            ).orElseThrow(() -> new RuntimeException("Organización no encontrada"));

            usuario.setOrganizacion(org);
        }

        // ── NUEVO: Departamento ──────────────────────────────────────────
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