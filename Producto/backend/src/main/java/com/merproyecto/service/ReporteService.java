package com.merproyecto.service;

import com.merproyecto.model.Reporte;

import java.util.List;

public interface ReporteService {

    byte[] generarReporteTareasPdf(Integer idOrganizacion);

    byte[] generarReporteTareasOrganizacionPdf(Integer idOrganizacion);

    byte[] generarReporteTareasUsuarioPdf(Integer idUsuario);

    List<Reporte> listarPorOrganizacion(Integer idOrganizacion);
}