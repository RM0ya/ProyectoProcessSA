package com.merproyecto.service.impl;

import com.merproyecto.model.Organizacion;
import com.merproyecto.model.Rol;
import com.merproyecto.model.Usuario;
import com.merproyecto.repository.OrganizacionRepository;
import com.merproyecto.repository.RolRepository;
import com.merproyecto.repository.UsuarioRepository;
import com.merproyecto.service.UsuarioService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.List;
import java.util.Optional;

@Service
@RequiredArgsConstructor
public class UsuarioServiceImpl implements UsuarioService {

    private final UsuarioRepository repository;
    private final PasswordEncoder passwordEncoder;
    private final RolRepository rolRepository;
    private final OrganizacionRepository organizacionRepository;

    @Override
    public List<Usuario> findAll() {
        return repository.findAll();
    }

    @Override
    public List<Usuario> findByOrganizacion(Integer idOrganizacion) {
        return repository.findByOrganizacion_IdOrganizacion(idOrganizacion);
    }

    @Override
    public List<Usuario> findByRolNombre(String nombreRol) {
        return repository.findByRol_NombreIgnoreCase(nombreRol);
    }

    @Override
    public Optional<Usuario> findById(Integer id) {
        return repository.findById(id);
    }

    @Override
    public Optional<Usuario> findByEmail(String email) {
        return repository.findByEmailUsuario(email);
    }

    @Override
    public Usuario crearUsuario(Usuario nuevoUsuario, Usuario creador) {
        // Validar si intentan asignar rol 3 (SuperAdmin)
        if (nuevoUsuario.getRol() != null && nuevoUsuario.getRol().getIdRol() == 3) {
            if (creador == null || creador.getRol() == null || creador.getRol().getIdRol() != 3) {
                throw new AccessDeniedException("No autorizado: Solo un Super Admin puede crear otro Super Admin.");
            }
        }
        return save(nuevoUsuario);
    }

    @Override
    public Usuario save(Usuario entity) {
        if (entity.getPassword() != null &&
                !entity.getPassword().startsWith("$2a$") &&
                !entity.getPassword().equals("google_oauth")) {

            entity.setPassword(
                    passwordEncoder.encode(entity.getPassword())
            );
        }
        return repository.save(entity);
    }

    @Override
    @Transactional
    public void deleteById(Integer id) {
        repository.deleteById(id);
    }

    @Override
    public Usuario login(String emailUsuario, String password) {
        Optional<Usuario> usuarioOpt = repository.findByEmailUsuario(emailUsuario);

        if (usuarioOpt.isEmpty()) {
            return null;
        }

        Usuario usuario = usuarioOpt.get();
        boolean passwordOk = passwordEncoder.matches(password, usuario.getPassword());

        if (!passwordOk) {
            return null;
        }

        return usuario;
    }

    @Override
    public Usuario registrarConGoogle(String email, String nombre, String apellido) {
        Rol rol = rolRepository.findById(2).orElseThrow();

        Usuario nuevo = new Usuario();
        nuevo.setNombre(nombre);
        nuevo.setApellidoP(apellido.isEmpty() ? "Usuario" : apellido);
        nuevo.setEmailUsuario(email);
        nuevo.setPassword(passwordEncoder.encode("google_oauth_" + email));
        nuevo.setBloqueado('N');
        nuevo.setIntentosFallidos(0);
        nuevo.setUltimoLogin(LocalDateTime.now());
        nuevo.setFechaCreacion(LocalDate.now());
        nuevo.setRol(rol);
        // CORREGIDO: ya no se asigna organización por defecto. Un usuario
        // que se registra con Google queda igual que el registro manual:
        // sin organización, pendiente de asignación por un Super Admin.
        nuevo.setOrganizacion(null);

        return repository.save(nuevo);
    }
}