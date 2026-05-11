package com.merproyecto.model;

import jakarta.persistence.*;
import lombok.*;

@Entity
@Table(name = "ESTADO")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Estado {

    @Id
    @Column(name = "id_estado")
    private Integer idEstado;

    @Column(name = "nombre_estado", nullable = false, length = 25)
    private String nombreEstado;

    @Column(name = "valor_estado", nullable = false, length = 1)
    private Character valorEstado;
}
