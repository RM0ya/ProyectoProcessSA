package com.merproyecto.security;

import lombok.RequiredArgsConstructor;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.config.annotation.web.builders.HttpSecurity;
import org.springframework.security.config.annotation.web.configuration.EnableWebSecurity;
import org.springframework.security.config.http.SessionCreationPolicy;
import org.springframework.security.crypto.bcrypt.BCryptPasswordEncoder;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.security.web.SecurityFilterChain;
import org.springframework.security.web.authentication.UsernamePasswordAuthenticationFilter;
import org.springframework.web.cors.CorsConfiguration;
import org.springframework.web.cors.CorsConfigurationSource;
import org.springframework.web.cors.UrlBasedCorsConfigurationSource;

import java.util.List;

@Configuration
@EnableWebSecurity
@RequiredArgsConstructor
public class SecurityConfig {

    private final JwtFilter jwtFilter;

    @Bean
    public SecurityFilterChain filterChain(HttpSecurity http) throws Exception {
        http
                .csrf(csrf -> csrf.disable())
                .cors(cors -> cors.configurationSource(corsConfigurationSource()))
                .sessionManagement(session ->
                        session.sessionCreationPolicy(SessionCreationPolicy.STATELESS)
                )
                .authorizeHttpRequests(auth -> auth
                        // 1. Endpoints públicos
                        .requestMatchers(
                                "/api/usuarios/login",
                                "/api/usuarios/login-google",
                                "/api/usuarios/crear",
                                "/api/usuarios/registro-google",
                                "/api/sesiones/iniciar",
                                "/api/sesiones/cerrar"
                        ).permitAll()

                        // 2. Endpoints protegidos por roles (Específicos primero)
                        .requestMatchers("/api/organizaciones/**").hasAuthority("ROLE_SUPERADMIN")
                        .requestMatchers("/api/reportes/**").permitAll()
                        .requestMatchers("/api/sesiones/**").hasAnyAuthority("ROLE_SUPERADMIN", "ROLE_ADMIN")
                        .requestMatchers("/api/usuarios/**").hasAnyAuthority("ROLE_SUPERADMIN", "ROLE_ADMIN")
                        .requestMatchers("/api/procesos/**").hasAnyAuthority("ROLE_SUPERADMIN", "ROLE_ADMIN", "ROLE_USUARIO")
                        .requestMatchers("/api/tareas/**").hasAnyAuthority("ROLE_SUPERADMIN", "ROLE_ADMIN", "ROLE_USUARIO")
                        .requestMatchers("/api/departamentos/**").hasAnyAuthority("ROLE_SUPERADMIN", "ROLE_ADMIN")

                        // 3. TODO lo demás requiere autenticación (Siempre al final)
                        .anyRequest().authenticated()
                )
                .addFilterBefore(jwtFilter, UsernamePasswordAuthenticationFilter.class);

        return http.build();
    }

    @Bean
    public PasswordEncoder passwordEncoder() {
        return new BCryptPasswordEncoder();
    }

    @Bean
    public CorsConfigurationSource corsConfigurationSource() {
        CorsConfiguration config = new CorsConfiguration();
        config.setAllowedOriginPatterns(List.of("*"));
        config.setAllowedMethods(List.of("GET", "POST", "PUT", "DELETE", "OPTIONS"));
        config.setAllowedHeaders(List.of("*"));
        config.setAllowCredentials(true);

        UrlBasedCorsConfigurationSource source = new UrlBasedCorsConfigurationSource();
        source.registerCorsConfiguration("/**", config);
        return source;
    }
}