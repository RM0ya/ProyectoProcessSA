package com.merproyecto.service.impl;

import com.lowagie.text.*;
import com.lowagie.text.pdf.*;
import com.merproyecto.model.Organizacion;
import com.merproyecto.model.Reporte;
import com.merproyecto.model.Tarea;
import com.merproyecto.repository.OrganizacionRepository;
import com.merproyecto.repository.ReporteRepository;
import com.merproyecto.repository.TareaRepository;
import com.merproyecto.service.ReporteService;
import lombok.RequiredArgsConstructor;
import org.springframework.stereotype.Service;

import java.awt.Color;
import java.io.ByteArrayOutputStream;
import java.time.LocalDateTime;
import java.time.format.DateTimeFormatter;
import java.util.List;

@Service
@RequiredArgsConstructor
public class ReporteServiceImpl implements ReporteService {

    private final ReporteRepository reporteRepository;
    private final TareaRepository tareaRepository;
    private final OrganizacionRepository organizacionRepository;

    @Override
    public byte[] generarReporteTareasPdf(Integer idOrganizacion) {
        return generarReporteTareasOrganizacionPdf(idOrganizacion);
    }

    @Override
    public byte[] generarReporteTareasOrganizacionPdf(Integer idOrganizacion) {
        Organizacion organizacion = organizacionRepository.findById(idOrganizacion)
                .orElseThrow(() -> new RuntimeException("Organización no encontrada"));

        List<Tarea> tareas = tareaRepository
                .findByProcesoOrganizacionIdOrganizacionOrderByFechaCreacionTDesc(idOrganizacion);

        byte[] pdf = construirPdfTareas(
                "Reporte General de Tareas",
                "Todas las tareas registradas en la organización",
                organizacion.getNombre(),
                tareas
        );

        guardarRegistroReporte("Reporte general de tareas", organizacion);

        return pdf;
    }

    @Override
    public byte[] generarReporteTareasUsuarioPdf(Integer idUsuario) {
        List<Tarea> tareas = tareaRepository
                .findByUsuarioIdUsuarioOrderByFechaCreacionTDesc(idUsuario);

        String nombreOrganizacion = "Sin organización";
        Organizacion organizacion = null;

        if (!tareas.isEmpty()
                && tareas.get(0).getProceso() != null
                && tareas.get(0).getProceso().getOrganizacion() != null) {
            organizacion = tareas.get(0).getProceso().getOrganizacion();
            nombreOrganizacion = organizacion.getNombre();
        }

        byte[] pdf = construirPdfTareas(
                "Reporte de Mis Tareas",
                "Tareas asignadas al usuario",
                nombreOrganizacion,
                tareas
        );

        if (organizacion != null) {
            guardarRegistroReporte("Reporte de tareas por usuario", organizacion);
        }

        return pdf;
    }

    @Override
    public List<Reporte> listarPorOrganizacion(Integer idOrganizacion) {
        return reporteRepository.findByOrganizacionIdOrganizacionOrderByGeneradoEnDesc(idOrganizacion);
    }

    private void guardarRegistroReporte(String nombre, Organizacion organizacion) {
        if (organizacion == null) return;

        Reporte reporte = new Reporte();
        reporte.setNombre(nombre);
        reporte.setFormatoReporte("PDF");
        reporte.setS3Key("local/reporte_tareas_" + System.currentTimeMillis() + ".pdf");
        reporte.setGeneradoEn(LocalDateTime.now());
        reporte.setOrganizacion(organizacion);
        reporteRepository.save(reporte);
    }

    private byte[] construirPdfTareas(
            String tituloReporte,
            String subtitulo,
            String nombreOrganizacion,
            List<Tarea> tareas
    ) {
        try {
            ByteArrayOutputStream out = new ByteArrayOutputStream();

            Document document = new Document(PageSize.A4.rotate(), 24, 24, 30, 24);
            PdfWriter.getInstance(document, out);
            document.open();

            // ===== COLORES =====
            Color azul = new Color(24, 95, 165);
            Color azulOscuro = new Color(18, 68, 120);
            Color verde = new Color(76, 175, 80);
            Color naranja = new Color(255, 152, 0);
            Color rojo = new Color(220, 53, 69);
            Color grisClaro = new Color(245, 247, 250);
            Color grisBorde = new Color(220, 225, 230);
            Color grisTexto = new Color(80, 80, 80);
            Color negro = Color.BLACK;

            // ===== FUENTES =====
            Font tituloFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 20, Color.WHITE);
            Font subtituloFont = FontFactory.getFont(FontFactory.HELVETICA, 10, Color.WHITE);
            Font seccionFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 13, azulOscuro);
            Font textoFont = FontFactory.getFont(FontFactory.HELVETICA, 9, grisTexto);
            Font textoBold = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 9, negro);
            Font tablaHeaderFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 8, Color.WHITE);
            Font tablaFont = FontFactory.getFont(FontFactory.HELVETICA, 8, Color.DARK_GRAY);
            Font footerFont = FontFactory.getFont(FontFactory.HELVETICA_OBLIQUE, 8, grisTexto);

            // =========================
            // HEADER SUPERIOR
            // =========================
            PdfPTable header = new PdfPTable(2);
            header.setWidthPercentage(100);
            header.setWidths(new float[]{1.2f, 5f});

            PdfPCell logoCell = new PdfPCell();
            logoCell.setBackgroundColor(azul);
            logoCell.setBorder(Rectangle.NO_BORDER);
            logoCell.setPadding(14);

            Paragraph logo = new Paragraph(
                    "PSA",
                    FontFactory.getFont(FontFactory.HELVETICA_BOLD, 22, Color.WHITE)
            );
            logo.setAlignment(Element.ALIGN_CENTER);
            logoCell.addElement(logo);

            PdfPCell titleCell = new PdfPCell();
            titleCell.setBackgroundColor(azul);
            titleCell.setBorder(Rectangle.NO_BORDER);
            titleCell.setPadding(14);

            Paragraph titulo = new Paragraph(tituloReporte, tituloFont);
            Paragraph sub = new Paragraph(subtitulo, subtituloFont);

            titleCell.addElement(titulo);
            titleCell.addElement(sub);

            header.addCell(logoCell);
            header.addCell(titleCell);

            document.add(header);
            document.add(new Paragraph(" "));

            // =========================
            // RESUMEN
            // =========================
            String fecha = LocalDateTime.now().format(DateTimeFormatter.ofPattern("dd-MM-yyyy HH:mm"));

            PdfPTable resumen = new PdfPTable(3);
            resumen.setWidthPercentage(100);
            resumen.setWidths(new float[]{2f, 1f, 1.4f});

            agregarResumen(resumen, "Organización", nombreOrganizacion, azulOscuro);
            agregarResumen(resumen, "Total tareas", String.valueOf(tareas.size()), verde);
            agregarResumen(resumen, "Generado", fecha, azulOscuro);

            document.add(resumen);
            document.add(new Paragraph(" "));

            // =========================
            // TÍTULO SECCIÓN
            // =========================
            Paragraph detalleTitulo = new Paragraph("Detalle de tareas", seccionFont);
            document.add(detalleTitulo);
            document.add(new Paragraph(" "));

            // =========================
            // TABLA DETALLE
            // =========================
            PdfPTable tabla = new PdfPTable(9);
            tabla.setWidthPercentage(100);
            tabla.setWidths(new float[]{0.7f, 2.2f, 2.8f, 2f, 1.8f, 1.3f, 1.3f, 1.4f, 1.6f});

            agregarHeader(tabla, "ID", tablaHeaderFont, azulOscuro);
            agregarHeader(tabla, "Tarea", tablaHeaderFont, azulOscuro);
            agregarHeader(tabla, "Descripción", tablaHeaderFont, azulOscuro);
            agregarHeader(tabla, "Responsable", tablaHeaderFont, azulOscuro);
            agregarHeader(tabla, "Proceso", tablaHeaderFont, azulOscuro);
            agregarHeader(tabla, "Creación", tablaHeaderFont, azulOscuro);
            agregarHeader(tabla, "Límite", tablaHeaderFont, azulOscuro);
            agregarHeader(tabla, "Estado", tablaHeaderFont, azulOscuro);
            agregarHeader(tabla, "Completada", tablaHeaderFont, azulOscuro);

            if (tareas.isEmpty()) {
                PdfPCell vacio = new PdfPCell(new Phrase("No hay tareas para mostrar", textoFont));
                vacio.setColspan(9);
                vacio.setPadding(12);
                vacio.setHorizontalAlignment(Element.ALIGN_CENTER);
                vacio.setBackgroundColor(Color.WHITE);
                vacio.setBorderColor(grisBorde);
                tabla.addCell(vacio);
            } else {
                boolean alterna = false;

                for (Tarea t : tareas) {
                    String responsable = obtenerResponsable(t);
                    String proceso = obtenerProceso(t);
                    String estado = obtenerEstadoTexto(t);
                    String fechaCreacion = t.getFechaCreacionT() != null ? t.getFechaCreacionT().toString() : "-";
                    String fechaLimite = t.getFechaLimiteS() != null ? t.getFechaLimiteS().toString() : "-";
                    String fechaCompletada = t.getFechaCompletada() != null ? t.getFechaCompletada().toString() : "No completada";

                    Color fondoFila = alterna ? grisClaro : Color.WHITE;
                    alterna = !alterna;

                    agregarCelda(tabla, String.valueOf(t.getIdTarea()), tablaFont, fondoFila);
                    agregarCelda(tabla, safe(t.getNombreTarea()), tablaFont, fondoFila);
                    agregarCelda(tabla, safe(t.getDescripcionT()), tablaFont, fondoFila);
                    agregarCelda(tabla, responsable, tablaFont, fondoFila);
                    agregarCelda(tabla, proceso, tablaFont, fondoFila);
                    agregarCelda(tabla, fechaCreacion, tablaFont, fondoFila);
                    agregarCelda(tabla, fechaLimite, tablaFont, fondoFila);

                    // Estado con color visual
                    agregarCeldaEstado(tabla, estado, tablaFont, fondoFila, verde, naranja, rojo);

                    agregarCelda(tabla, fechaCompletada, tablaFont, fondoFila);
                }
            }

            document.add(tabla);

            document.add(new Paragraph(" "));

            Paragraph nota = new Paragraph(
                    "Documento generado automáticamente por Process SA.",
                    footerFont
            );
            nota.setAlignment(Element.ALIGN_CENTER);
            document.add(nota);

            document.close();
            return out.toByteArray();

        } catch (Exception e) {
            throw new RuntimeException("Error al generar reporte PDF: " + e.getMessage(), e);
        }
    }

    // =========================================================
    // HELPERS PDF
    // =========================================================

    private void agregarResumen(PdfPTable tabla, String titulo, String valor, Color color) {
        Font tituloFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 8, color);
        Font valorFont = FontFactory.getFont(FontFactory.HELVETICA_BOLD, 10, Color.BLACK);

        PdfPCell cell = new PdfPCell();
        cell.setPadding(10);
        cell.setBackgroundColor(new Color(245, 247, 250));
        cell.setBorderColor(new Color(220, 225, 230));

        cell.addElement(new Paragraph(titulo, tituloFont));
        cell.addElement(new Paragraph(valor, valorFont));

        tabla.addCell(cell);
    }

    private void agregarHeader(PdfPTable tabla, String texto, Font font, Color color) {
        PdfPCell cell = new PdfPCell(new Phrase(texto, font));
        cell.setBackgroundColor(color);
        cell.setPadding(7);
        cell.setHorizontalAlignment(Element.ALIGN_CENTER);
        cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
        cell.setBorderColor(Color.WHITE);
        tabla.addCell(cell);
    }

    private void agregarCelda(PdfPTable tabla, String texto, Font font, Color fondo) {
        PdfPCell cell = new PdfPCell(new Phrase(texto, font));
        cell.setPadding(6);
        cell.setBackgroundColor(fondo);
        cell.setBorderColor(new Color(220, 225, 230));
        cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
        tabla.addCell(cell);
    }

    private void agregarCeldaEstado(
            PdfPTable tabla,
            String estado,
            Font font,
            Color fondoBase,
            Color verde,
            Color naranja,
            Color rojo
    ) {
        Color fondoEstado = fondoBase;

        if ("Activa".equalsIgnoreCase(estado)) {
            fondoEstado = new Color(232, 245, 233); // verde clarito
        } else if ("Completada".equalsIgnoreCase(estado)) {
            fondoEstado = new Color(227, 242, 253); // azul clarito
        } else if ("Inactiva".equalsIgnoreCase(estado)) {
            fondoEstado = new Color(255, 243, 224); // naranjo clarito
        }

        PdfPCell cell = new PdfPCell(new Phrase(estado, font));
        cell.setPadding(6);
        cell.setBackgroundColor(fondoEstado);
        cell.setBorderColor(new Color(220, 225, 230));
        cell.setVerticalAlignment(Element.ALIGN_MIDDLE);
        tabla.addCell(cell);
    }

    private String safe(String texto) {
        if (texto == null || texto.trim().isEmpty()) {
            return "-";
        }
        return texto;
    }

    private String obtenerResponsable(Tarea t) {
        if (t.getUsuario() == null) {
            return "Sin responsable";
        }

        String nombre = t.getUsuario().getNombre() != null ? t.getUsuario().getNombre() : "";
        String apellido = t.getUsuario().getApellidoP() != null ? t.getUsuario().getApellidoP() : "";
        String full = (nombre + " " + apellido).trim();

        return full.isBlank() ? "Sin responsable" : full;
    }

    private String obtenerProceso(Tarea t) {
        if (t.getProceso() == null || t.getProceso().getNombre() == null || t.getProceso().getNombre().isBlank()) {
            return "Sin proceso";
        }
        return t.getProceso().getNombre();
    }

    private String obtenerEstadoTexto(Tarea t) {
        if (t == null || t.getEstado() == null || t.getEstado().getIdEstado() == null) {
            return "Sin estado";
        }

        Integer idEstado = t.getEstado().getIdEstado();

        return switch (idEstado) {
            case 1 -> "Activa";
            case 2 -> "Completada";
            case 3 -> "Inactiva";
            default -> "Estado " + idEstado;
        };
    }
}