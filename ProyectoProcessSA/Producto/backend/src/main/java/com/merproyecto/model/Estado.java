package com.merproyecto.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;

import java.util.List;

@Entity
@Table(name = "ESTADO")
@Data
@NoArgsConstructor
@AllArgsConstructor
@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
public class Estado {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_estado")
    private Integer idEstado;

    @Column(name = "nombre_estado", nullable = false, length = 25)
    private String nombreEstado;

    @Column(name = "valor_estado", nullable = false, length = 1)
    private Character valorEstado;

    @JsonIgnore
    @OneToMany(mappedBy = "estado")
    private List<Tarea> tareas;

    @JsonIgnore
    @OneToMany(mappedBy = "estado")
    private List<Proceso> procesos;
}