package com.merproyecto.controller;

import com.merproyecto.model.Sesion;
import com.merproyecto.service.SesionService;
import jakarta.servlet.http.HttpServletRequest;
import lombok.RequiredArgsConstructor;
import org.springframework.web.bind.annotation.*;

import java.util.List;
import java.util.Map;

@RestController
@RequestMapping("/api/sesiones")
@RequiredArgsConstructor
public class SesionController {

    private final SesionService sesionService;

    @PostMapping("/iniciar")
    public Sesion iniciarSesion(
            @RequestBody Map<String, Object> body,
            HttpServletRequest request
    ) {
        Integer idUsuario = Integer.valueOf(body.get("idUsuario").toString());
        String token = body.get("token").toString();
        String ip = request.getRemoteAddr();

        return sesionService.iniciarSesion(idUsuario, token, ip);
    }

    @PostMapping("/cerrar")
    public Sesion cerrarSesion(@RequestBody Map<String, Object> body) {
        Integer idUsuario = Integer.valueOf(body.get("idUsuario").toString());
        return sesionService.cerrarSesion(idUsuario);
    }

    @GetMapping("/usuario/{idUsuario}")
    public List<Sesion> listarPorUsuario(@PathVariable Integer idUsuario) {
        return sesionService.listarPorUsuario(idUsuario);
    }
    @GetMapping
    public List<Sesion> listarTodas() {
        return sesionService.listarTodas();
    }
}