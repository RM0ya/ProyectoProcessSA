package com.merproyecto.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
@Entity
@Table(name = "PROCESO")
@Data @NoArgsConstructor @AllArgsConstructor
public class Proceso {

    @Id
    @Column(name = "id_proceso")
    private Integer idProceso;

    @Column(name = "nombre", nullable = false, length = 25)
    private String nombre;

    @Column(name = "descripcion_proceso", nullable = false, length = 50)
    private String descripcionProceso;

    @Column(name = "estado_proceso", nullable = false, length = 10)
    private String estadoProceso;

    @Column(name = "fecha_inicio", nullable = false)
    private LocalDate fechaInicio;

    @Column(name = "fecha_limite", nullable = false)
    private LocalDate fechaLimite;

    @Column(name = "fecha_creacion", nullable = false)
    private LocalDate fechaCreacion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_organizacion", nullable = false)
    private Organizacion organizacion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_kpi", nullable = false)
    private Kpi kpi;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_estado", nullable = false)
    private Estado estado;
}