package com.merproyecto.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;

@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
@Entity
@Table(name = "DEPENDENCIA_TAREA")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class DependenciaTarea {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_dependencia")
    private Integer idDependencia;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_tarea_origen", nullable = false)
    private Tarea tareaOrigen;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_tarea_dependiente", nullable = false)
    private Tarea tareaDependiente;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_estado", nullable = false)
    private Estado estado;
}