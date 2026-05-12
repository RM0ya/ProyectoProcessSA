package com.merproyecto.service.impl;

import com.merproyecto.model.Organizacion;
import com.merproyecto.model.Rol;
import com.merproyecto.model.Usuario;
import com.merproyecto.repository.OrganizacionRepository;
import com.merproyecto.repository.RolRepository;
import com.merproyecto.repository.UsuarioRepository;
import com.merproyecto.service.UsuarioService;
import lombok.RequiredArgsConstructor;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.stereotype.Service;

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
    public Optional<Usuario> findById(Integer id) {
        return repository.findById(id);
    }

    @Override
    public Optional<Usuario> findByEmail(String email) {
        return repository.findByEmailUsuario(email);
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
    public void deleteById(Integer id) {
        repository.deleteById(id);
    }

    @Override
    public Usuario login(String emailUsuario, String password) {

        Optional<Usuario> usuarioOpt =
                repository.findByEmailUsuario(emailUsuario);

        if (usuarioOpt.isEmpty()) {
            return null;
        }

        Usuario usuario = usuarioOpt.get();

        boolean passwordOk =
                passwordEncoder.matches(password, usuario.getPassword());

        if (!passwordOk) {
            return null;
        }

        return usuario;
    }

    @Override
    public Usuario registrarConGoogle(
            String email,
            String nombre,
            String apellido
    ) {

        Rol rol = rolRepository.findById(2).orElseThrow();

        Organizacion org =
                organizacionRepository.findById(1).orElseThrow();

        Usuario nuevo = new Usuario();

        nuevo.setNombre(nombre);

        nuevo.setApellidoP(
                apellido.isEmpty() ? "Usuario" : apellido
        );

        nuevo.setEmailUsuario(email);

        nuevo.setPassword(
                passwordEncoder.encode("google_oauth_" + email)
        );

        nuevo.setBloqueado('N');

        nuevo.setIntentosFallidos(0);

        nuevo.setUltimoLogin(LocalDateTime.now());

        nuevo.setFechaCreacion(LocalDate.now());

        nuevo.setRol(rol);

        nuevo.setOrganizacion(org);

        return repository.save(nuevo);
    }
}