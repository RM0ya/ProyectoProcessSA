package com.merproyecto.service;

import com.merproyecto.model.Usuario;

import java.util.List;
import java.util.Optional;

public interface UsuarioService {

    List<Usuario> findAll();

    Optional<Usuario> findById(Integer id);

    Optional<Usuario> findByEmail(String email);

    Usuario save(Usuario entity);

    void deleteById(Integer id);

    Usuario login(String emailUsuario, String password);

    Usuario registrarConGoogle(String email, String nombre, String apellido);
}