package com.merproyecto.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.util.List;

@Entity
@Table(name = "PROCESO")
@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Proceso {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_proceso")
    private Integer idProceso;

    @Column(name = "nombre", nullable = false, length = 25)
    private String nombre;

    @Column(name = "descripcion_proceso", nullable = false, length = 50)
    private String descripcionProceso;

    @Column(name = "fecha_inicio", nullable = false)
    private LocalDate fechaInicio;

    @Column(name = "fecha_limite", nullable = false)
    private LocalDate fechaLimite;

    @Column(name = "fecha_creacion", nullable = false)
    private LocalDate fechaCreacion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_organizacion", nullable = false)
    @JsonIgnoreProperties({"procesos", "usuarios", "departamentos", "hibernateLazyInitializer", "handler"})
    private Organizacion organizacion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_kpi", nullable = false)
    @JsonIgnoreProperties({"procesos", "hibernateLazyInitializer", "handler"})
    private Kpi kpi;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_estado", nullable = false)
    @JsonIgnoreProperties({"procesos", "tareas", "hibernateLazyInitializer", "handler"})
    private Estado estado;

    @OneToMany(mappedBy = "proceso")
    @JsonIgnoreProperties({"proceso", "hibernateLazyInitializer", "handler"})
    private List<Tarea> tareas;
}