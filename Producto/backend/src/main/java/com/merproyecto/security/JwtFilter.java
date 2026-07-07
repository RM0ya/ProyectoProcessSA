package com.merproyecto.security;

import jakarta.servlet.FilterChain;
import jakarta.servlet.ServletException;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import lombok.RequiredArgsConstructor;
import org.springframework.security.authentication.UsernamePasswordAuthenticationToken;
import org.springframework.security.core.authority.SimpleGrantedAuthority;
import org.springframework.security.core.context.SecurityContextHolder;
import org.springframework.stereotype.Component;
import org.springframework.web.filter.OncePerRequestFilter;

import java.io.IOException;
import java.util.List;

@Component
@RequiredArgsConstructor
public class JwtFilter extends OncePerRequestFilter {

    private final JwtUtil jwtUtil;

    @Override
    protected void doFilterInternal(HttpServletRequest request,
                                    HttpServletResponse response,
                                    FilterChain filterChain)
            throws ServletException, IOException {

        String path = request.getServletPath();

        if (path.startsWith("/api/reportes/")
                || path.startsWith("/api/usuarios/login")
                || path.startsWith("/api/usuarios/login-google")
                || path.startsWith("/api/usuarios/crear")
                || path.startsWith("/api/usuarios/registro-google")
                || path.equals("/api/sesiones/iniciar")
                || path.equals("/api/sesiones/cerrar")) {
            filterChain.doFilter(request, response);
            return;
        }

        String authHeader = request.getHeader("Authorization");

        if (authHeader != null && authHeader.startsWith("Bearer ")) {
            String token = authHeader.substring(7);

// Dentro de tu JwtFilter.java, en el bloque donde extraes el rol:
            // En tu JwtFilter.java
            if (jwtUtil.isTokenValid(token)) {
                String email = jwtUtil.extractEmail(token);
                String rol = jwtUtil.extractRol(token);

                // DEBUG: Esto es vital
                System.out.println("DEBUG: Email: " + email + " | Rol extraído: '" + rol + "'");

                String authority = "ROLE_" + rol.trim().toUpperCase();
                System.out.println("DEBUG: Authority generada: " + authority);

                var auth = new UsernamePasswordAuthenticationToken(email, null,
                        List.of(new SimpleGrantedAuthority(authority)));
                SecurityContextHolder.getContext().setAuthentication(auth);
            }
        }

        filterChain.doFilter(request, response);
    }
}