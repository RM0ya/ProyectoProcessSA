package com.merproyecto.controller;

import com.merproyecto.model.Organizacion;
import com.merproyecto.model.Rol;
import com.merproyecto.model.Usuario;
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

    @GetMapping
    public List<Usuario> listarUsuarios() {
        return usuarioService.findAll();
    }

    @DeleteMapping("/{id}")
    public ResponseEntity<?> eliminarUsuario(
            @PathVariable Integer id
    ) {

        Usuario usuario = usuarioService.findById(id)
                .orElseThrow(() ->
                        new RuntimeException("Usuario no encontrado"));

        usuarioService.deleteById(id);

        return ResponseEntity.ok(
                "Usuario eliminado correctamente"
        );
    }

    @PutMapping("/{id}")
    public ResponseEntity<?> actualizarUsuario(
            @PathVariable Integer id,
            @RequestBody Usuario usuarioActualizado
    ) {

        Usuario usuario = usuarioService.findById(id)
                .orElseThrow(() ->
                        new RuntimeException("Usuario no encontrado"));

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
            ).orElseThrow(() ->
                    new RuntimeException("Rol no encontrado"));

            usuario.setRol(rol);
        }

        if (usuarioActualizado.getOrganizacion() != null &&
                usuarioActualizado.getOrganizacion().getIdOrganizacion() != null) {

            Organizacion org = organizacionRepository.findById(
                    usuarioActualizado.getOrganizacion().getIdOrganizacion()
            ).orElseThrow(() ->
                    new RuntimeException("Organización no encontrada"));

            usuario.setOrganizacion(org);
        }

        Usuario actualizado = usuarioService.save(usuario);

        return ResponseEntity.ok(actualizado);
    }
}