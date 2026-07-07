package com.merproyecto.controller;

import com.google.api.client.googleapis.auth.oauth2.GoogleIdToken;
import com.google.api.client.googleapis.auth.oauth2.GoogleIdTokenVerifier;
import com.google.api.client.http.javanet.NetHttpTransport;
import com.google.api.client.json.gson.GsonFactory;
import com.merproyecto.model.Rol;
import com.merproyecto.model.Usuario;
import com.merproyecto.repository.OrganizacionRepository;
import com.merproyecto.repository.RolRepository;
import com.merproyecto.security.JwtUtil;
import com.merproyecto.service.NotificacionService;
import com.merproyecto.service.UsuarioService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.ResponseEntity;
import org.springframework.security.crypto.password.PasswordEncoder;
import org.springframework.web.bind.annotation.*;

import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.Collections;
import java.util.List;
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
    private final NotificacionService notificacionService;

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

                // Notificar a los superadmin, igual que en el registro manual
                try {
                    List<Usuario> superadmins = usuarioService.findByRolNombre("SuperAdmin");
                    String mensaje = "Nuevo usuario registrado con Google: " + usuario.getNombre() + " "
                            + usuario.getApellidoP() + " (" + usuario.getEmailUsuario()
                            + ") está pendiente de asignación de organización.";

                    for (Usuario superadmin : superadmins) {
                        notificacionService.crearParaUsuario(
                                superadmin,
                                "REGISTRO_PENDIENTE",
                                mensaje
                        );
                    }
                } catch (Exception e) {
                    System.out.println("ERROR AL CREAR NOTIFICACION DE REGISTRO GOOGLE: " + e.getMessage());
                }
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

    // ───────────────── CREAR USUARIO (REGISTRO PÚBLICO) ─────────────────
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

        // Ya no se asigna una organización por defecto (antes era siempre
        // id=1 / "Mi Empresa"). Un usuario que se autorregistra no debe
        // quedar vinculado a ninguna organización hasta que un superadmin
        // se la asigne explícitamente. Se fuerza a null sin importar lo
        // que haya llegado en el body, por seguridad: el registro público
        // nunca debe poder autoasignarse una organización.
        usuario.setOrganizacion(null);

        System.out.println("PASSWORD ANTES DE SAVE: " + usuario.getPassword());

        Usuario nuevo = usuarioService.save(usuario);

        System.out.println("PASSWORD DESPUES DE SAVE: " + nuevo.getPassword());

        // Notificar a todos los superadmin para que asignen organización
        // al usuario recién registrado.
        try {
            List<Usuario> superadmins = usuarioService.findByRolNombre("SuperAdmin");
            String mensaje = "Nuevo usuario registrado: " + nuevo.getNombre() + " "
                    + nuevo.getApellidoP() + " (" + nuevo.getEmailUsuario()
                    + ") está pendiente de asignación de organización.";

            for (Usuario superadmin : superadmins) {
                notificacionService.crearParaUsuario(
                        superadmin,
                        "REGISTRO_PENDIENTE",
                        mensaje
                );
            }
        } catch (Exception e) {
            // No se debe romper el registro del usuario si falla la
            // creación de la notificación; solo se deja registrado en log.
            System.out.println("ERROR AL CREAR NOTIFICACION DE REGISTRO: " + e.getMessage());
        }

        return ResponseEntity.ok(Map.of(
                "mensaje", "Usuario creado correctamente",
                "usuario", nuevo
        ));
    }
}