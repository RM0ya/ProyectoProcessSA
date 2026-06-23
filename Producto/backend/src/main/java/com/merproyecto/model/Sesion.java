package com.merproyecto.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
@Entity
@Table(name = "SESION")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Sesion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_sesion")
    private Integer idSesion;

    @Column(name = "token", nullable = false, length = 255)
    private String token;

    @Column(name = "fecha_inicio_s", nullable = false)
    private LocalDateTime fechaInicioS;

    @Column(name = "fecha_fin_s")
    private LocalDateTime fechaFinS;

    @Column(name = "ip_origen", nullable = false, length = 255)
    private String ipOrigen;

    @Column(name = "tipo_evento", nullable = false, length = 255)
    private String tipoEvento;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_usuario", nullable = false)
    private Usuario usuario;
}