package com.merproyecto.controller;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.merproyecto.model.Organizacion;
import com.merproyecto.model.Rol;
import com.merproyecto.model.Usuario;
import com.merproyecto.repository.OrganizacionRepository;
import com.merproyecto.repository.RolRepository;
import com.merproyecto.security.JwtUtil;
import com.merproyecto.service.UsuarioService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/usuarios")
@RequiredArgsConstructor
public class AuthController {

    private final UsuarioService usuarioService;
    private final JwtUtil jwtUtil;
    private final PasswordEncoder passwordEncoder;
    private final RolRepository rolRepository;
    private final OrganizacionRepository organizacionRepository;

    private static final String GOOGLE_CLIENT_ID =
            "986429467737-333gr9k40rds0m9nod84v0or8s7833d1.apps.googleusercontent.com";

    @PostMapping("/login")
    public ResponseEntity<?> login(@RequestBody Map<String, String> body) {

        String email = body.get("emailUsuario");
        String password = body.get("password");

        Optional<Usuario> usuarioOpt = usuarioService.findByEmail(email);

        if (usuarioOpt.isEmpty()) {
            return ResponseEntity.status(401)
                    .body(Map.of("error", "Credenciales incorrectas"));
        }

        Usuario usuario = usuarioOpt.get();

        if (!passwordEncoder.matches(password, usuario.getPassword())) {
            return ResponseEntity.status(401)
                    .body(Map.of("error", "Credenciales incorrectas"));
        }

        String rol = usuario.getRol() != null
                ? usuario.getRol().getNombre()
                : "Usuario";

        String token = jwtUtil.generateToken(email, rol);

        return ResponseEntity.ok(Map.of(
                "token", token,
                "usuario", usuario
        ));
    }

    @PostMapping("/login-google")
    public ResponseEntity<?> loginGoogle(@RequestBody Map<String, String> body) {

        String idToken = body.get("idToken");

        try {
            GoogleIdTokenVerifier verifier = new GoogleIdTokenVerifier.Builder(
                    new NetHttpTransport(),
                    GsonFactory.getDefaultInstance())
                    .setAudience(Collections.singletonList(GOOGLE_CLIENT_ID))
                    .build();

            GoogleIdToken googleToken = verifier.verify(idToken);

            if (googleToken == null) {
                return ResponseEntity.status(401)
                        .body(Map.of("error", "Token de Google inválido"));
            }

            GoogleIdToken.Payload payload = googleToken.getPayload();

            String email = payload.getEmail();
            String nombre = (String) payload.get("given_name");
            String apellido = (String) payload.get("family_name");

            Optional<Usuario> usuarioOpt = usuarioService.findByEmail(email);

            Usuario usuario;

            if (usuarioOpt.isPresent()) {
                usuario = usuarioOpt.get();
            } else {
                usuario = usuarioService.registrarConGoogle(
                        email,
                        nombre != null ? nombre : "Usuario",
                        apellido != null ? apellido : ""
                );
            }

            String rol = usuario.getRol() != null
                    ? usuario.getRol().getNombre()
                    : "Usuario";

            String token = jwtUtil.generateToken(email, rol);

            return ResponseEntity.ok(Map.of(
                    "token", token,
                    "usuario", usuario
            ));

        } catch (Exception e) {
            return ResponseEntity.status(500)
                    .body(Map.of("error", "Error al verificar token de Google"));
        }
    }

    @GetMapping("/test")
    public String testPassword() {
        return passwordEncoder.encode("123456");
    }

    // ───────────────── CREAR USUARIO ─────────────────
    @PostMapping("/crear")
    public ResponseEntity<?> crearUsuario(@RequestBody Usuario usuario) {

        System.out.println("=== CREAR USUARIO ===");
        System.out.println("EMAIL RECIBIDO: " + usuario.getEmailUsuario());
        System.out.println("PASSWORD RECIBIDO: " + usuario.getPassword());
        System.out.println("NOMBRE RECIBIDO: " + usuario.getNombre());

        // Verificar si el correo ya existe
        if (usuarioService.findByEmail(usuario.getEmailUsuario()).isPresent()) {
            return ResponseEntity.badRequest()
                    .body(Map.of("error", "El correo ya existe"));
        }

        usuario.setBloqueado('N');
        usuario.setIntentosFallidos(0);
        usuario.setFechaCreacion(LocalDate.now());
        usuario.setUltimoLogin(LocalDateTime.now());

        Rol rol = rolRepository.findById(2)
                .orElseThrow(() -> new RuntimeException("Rol no encontrado"));
        usuario.setRol(rol);

        Organizacion org = organizacionRepository.findById(1)
                .orElseThrow(() -> new RuntimeException("Organización no encontrada"));
        usuario.setOrganizacion(org);

        System.out.println("PASSWORD ANTES DE SAVE: " + usuario.getPassword());

        Usuario nuevo = usuarioService.save(usuario);

        System.out.println("PASSWORD DESPUES DE SAVE: " + nuevo.getPassword());

        return ResponseEntity.ok(Map.of(
                "mensaje", "Usuario creado correctamente",
                "usuario", nuevo
        ));
    }
}