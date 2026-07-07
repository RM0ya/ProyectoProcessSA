package com.merproyecto.repository;

import com.merproyecto.model.Usuario;
import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.stereotype.Repository;

import java.util.List;
import java.util.Optional;

@Repository
public interface UsuarioRepository
        extends JpaRepository<Usuario, Integer> {

    Optional<Usuario> findByEmailUsuario(
            String emailUsuario
    );

    List<Usuario> findByOrganizacion_IdOrganizacion(Integer idOrganizacion);

    // NUEVO: para poder ubicar a todos los superadmin y notificarles
    // cuando se registra un usuario sin organización asignada.
    List<Usuario> findByRol_NombreIgnoreCase(String nombreRol);
}