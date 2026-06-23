package com.merproyecto.controller;

import com.merproyecto.model.Reporte;
import com.merproyecto.service.ReporteService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

import java.util.List;

@RestController
@RequestMapping("/api/reportes")
@RequiredArgsConstructor
public class ReporteController {

    private final ReporteService reporteService;

    @GetMapping("/tareas/pdf/organizacion/{idOrganizacion}")
    public ResponseEntity<byte[]> reporteOrganizacion(@PathVariable Integer idOrganizacion) {
        byte[] pdf = reporteService.generarReporteTareasOrganizacionPdf(idOrganizacion);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=reporte_tareas_organizacion.pdf")
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdf);
    }

    @GetMapping("/tareas/pdf/usuario/{idUsuario}")
    public ResponseEntity<byte[]> reporteUsuario(@PathVariable Integer idUsuario) {
        byte[] pdf = reporteService.generarReporteTareasUsuarioPdf(idUsuario);

        return ResponseEntity.ok()
                .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=reporte_mis_tareas.pdf")
                .contentType(MediaType.APPLICATION_PDF)
                .body(pdf);
    }
}