package com.merproyecto.model;

import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDateTime;

@Entity
@Table(name = "KPI")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Kpi {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_kpi")
    private Integer idKpi;

    @Column(name = "nombre_kpi", nullable = false, length = 50)
    private String nombreKpi;

    @Column(name = "valor_actual", nullable = false)
    private Integer valorActual;

    @Column(name = "valor_objetivo", nullable = false)
    private Integer valorObjetivo;


    @Column(name = "unidad_kpi", length = 20)
    private String unidadKpi;


    @Column(name = "calculado_en")
    private LocalDateTime calculadoEn;
}