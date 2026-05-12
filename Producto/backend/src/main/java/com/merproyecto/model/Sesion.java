package com.merproyecto.model;

import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@Entity
@Table(name = "SESION")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Sesion {

    @Id
    @Column(name = "id_sesion")
    private Integer idSesion;

    @Column(name = "token", nullable = false, length = 255)
    private String token;

    @Column(name = "fecha_inicio_s", nullable = false)
    private LocalDate fechaInicioS;

    @Column(name = "fecha_fin_s", nullable = false)
    private LocalDate fechaFinS;

    @Column(name = "ip_origen", nullable = false, length = 255)
    private String ipOrigen;

    @Column(name = "tipo_evento", nullable = false, length = 255)
    private String tipoEvento;
}
