package com.merproyecto.model;

import jakarta.persistence.Column;
import jakarta.persistence.Embeddable;
import lombok.*;

import java.io.Serializable;

@Embeddable
@Data
@NoArgsConstructor
@AllArgsConstructor
public class TareaId implements Serializable {

    @Column(name = "id_tarea")
    private Integer idTarea;

    @Column(name = "id_proceso")
    private Integer idProceso;
}