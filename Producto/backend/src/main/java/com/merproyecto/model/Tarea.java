package com.merproyecto.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;

import java.time.LocalDate;
import java.time.LocalDateTime;

@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
@Entity
@Table(name = "TAREA")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Tarea {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_tarea")
    private Integer idTarea;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_proceso", nullable = false)
    @JsonIgnoreProperties({"tareas", "hibernateLazyInitializer", "handler"})
    private Proceso proceso;

    @Column(name = "nombre_tarea", nullable = false, length = 30)
    private String nombreTarea;

    @Column(name = "descripcion_t", nullable = false, length = 50)
    private String descripcionT;

    @Column(name = "orden_t", nullable = false)
    private Integer ordenT;

    @Column(name = "fecha_limite_s", nullable = false)
    private LocalDate fechaLimiteS;

    @Column(name = "fecha_completada")
    private LocalDateTime fechaCompletada;

    @Column(name = "fecha_creacion_t", nullable = false)
    private LocalDate fechaCreacionT;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_usuario", nullable = false)
    @JsonIgnoreProperties({"tareas", "password", "hibernateLazyInitializer", "handler"})
    private Usuario usuario;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_estado", nullable = false)
    @JsonIgnoreProperties({"tareas", "procesos", "hibernateLazyInitializer", "handler"})
    private Estado estado;
}