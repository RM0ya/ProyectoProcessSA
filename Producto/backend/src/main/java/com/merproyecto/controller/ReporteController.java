package com.merproyecto.controller;

import com.merproyecto.service.ReporteService;
import lombok.RequiredArgsConstructor;
import org.springframework.http.HttpHeaders;
import org.springframework.http.HttpStatus;
import org.springframework.http.MediaType;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;

@RestController
@RequestMapping("/api/reportes")
@RequiredArgsConstructor
public class ReporteController {

    private final ReporteService reporteService;

    @GetMapping("/tareas/pdf/organizacion/{idOrganizacion}")
    public ResponseEntity<?> reporteOrganizacion(@PathVariable Integer idOrganizacion) {
        try {
            byte[] pdf = reporteService.generarReporteTareasOrganizacionPdf(idOrganizacion);
            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=reporte_tareas_organizacion.pdf")
                    .contentType(MediaType.APPLICATION_PDF)
                    .body(pdf);
        } catch (Exception e) {
            // ESTO ES LO QUE NECESITAMOS VER EN EL LOG PARA SABER POR QUÉ FALLA
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error al generar PDF: " + e.getMessage());
        }
    }

    @GetMapping("/tareas/pdf/usuario/{idUsuario}")
    public ResponseEntity<?> reporteUsuario(@PathVariable Integer idUsuario) {
        try {
            byte[] pdf = reporteService.generarReporteTareasUsuarioPdf(idUsuario);
            return ResponseEntity.ok()
                    .header(HttpHeaders.CONTENT_DISPOSITION, "attachment; filename=reporte_mis_tareas.pdf")
                    .contentType(MediaType.APPLICATION_PDF)
                    .body(pdf);
        } catch (Exception e) {
            e.printStackTrace();
            return ResponseEntity.status(HttpStatus.INTERNAL_SERVER_ERROR)
                    .body("Error al generar PDF: " + e.getMessage());
        }
    }
}