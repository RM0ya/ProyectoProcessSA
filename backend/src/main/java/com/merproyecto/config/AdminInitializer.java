package com.merproyecto.config;

import com.merproyecto.model.Organizacion;
import com.merproyecto.model.Rol;
import com.merproyecto.model.Usuario;
import com.merproyecto.repository.OrganizacionRepository;
import com.merproyecto.repository.RolRepository;
import com.merproyecto.repository.UsuarioRepository;

import lombok.RequiredArgsConstructor;

import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Configuration
@RequiredArgsConstructor
public class AdminInitializer {

    private final UsuarioRepository usuarioRepository;
    private final RolRepository rolRepository;
    private final OrganizacionRepository organizacionRepository;
    private final PasswordEncoder passwordEncoder;

    @Bean
    CommandLineRunner initAdmin() {

        return args -> {


            Organizacion organizacion;

            if (organizacionRepository.findById(1).isEmpty()) {

                Organizacion nuevaOrg =
                        new Organizacion();

                nuevaOrg.setIdOrganizacion(1);

                nuevaOrg.setNombre(
                        "MERPROYECTO");

                nuevaOrg.setRut(11111111);

                nuevaOrg.setDv('1');

                nuevaOrg.setEmailContacto(
                        "admin@merproyecto.com");

                nuevaOrg.setEstado("ACTIVA");

                nuevaOrg.setFechaCreacion(
                        LocalDate.now());

                organizacion =
                        organizacionRepository.save(
                                nuevaOrg);

                System.out.println(
                        "ORGANIZACION CREADA");

            } else {

                organizacion =
                        organizacionRepository
                                .findById(1)
                                .get();
            }


            Rol rolAdmin;

            if (rolRepository.findById(1).isEmpty()) {

                Rol nuevoRol = new Rol();

                nuevoRol.setIdRol(1);

                nuevoRol.setNombre("ADMIN");

                nuevoRol.setDescripcion(
                        "Administrador del sistema");

                nuevoRol.setUsuario(null);

                rolAdmin =
                        rolRepository.save(nuevoRol);

                System.out.println(
                        "ROL ADMIN CREADO");

            } else {

                rolAdmin =
                        rolRepository.findById(1).get();
            }



            if (rolRepository.findById(2).isEmpty()) {

                Rol rolUsuario = new Rol();

                rolUsuario.setIdRol(2);

                rolUsuario.setNombre("USUARIO");

                rolUsuario.setDescripcion(
                        "Usuario normal");

                rolUsuario.setUsuario(null);

                rolRepository.save(rolUsuario);

                System.out.println(
                        "ROL USUARIO CREADO");
            }

            if (usuarioRepository
                    .findByEmailUsuario(
                            "admin@admin.com")
                    .isEmpty()) {

                Usuario admin =
                        new Usuario();

                admin.setNombre(
                        "Administrador");

                admin.setApellidoP(
                        "Sistema");

                admin.setApellidoM(
                        "Principal");

                admin.setEmailUsuario(
                        "admin@admin.com");

                admin.setPassword(
                        passwordEncoder.encode(
                                "admin123"));

                admin.setIntentosFallidos(0);

                admin.setBloqueado('N');

                admin.setUltimoLogin(
                        LocalDateTime.now());

                admin.setFechaCreacion(
                        LocalDate.now());

                admin.setTelefono(
                        "999999999");

                admin.setRol(rolAdmin);

                admin.setOrganizacion(
                        organizacion);

                usuarioRepository.save(admin);

                System.out.println(
                        "ADMIN CREADO");
            }
        };
    }
}