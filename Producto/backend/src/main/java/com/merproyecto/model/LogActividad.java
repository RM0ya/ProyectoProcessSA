package com.merproyecto.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
@Entity
@Table(name = "LOG_ACTIVIDAD")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class LogActividad {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_log")
    private Integer idLog;

    @Column(name = "accion_log", nullable = false, length = 50)
    private String accionLog;

    @Column(name = "modulo_log", nullable = false, length = 25)
    private String moduloLog;

    @Column(name = "detalle_log", nullable = false, length = 200)
    private String detalleLog;

    @Column(name = "ip_log", nullable = false, length = 45)
    private String ipLog;

    @Column(name = "fecha_hora", nullable = false)
    private LocalDateTime fechaHora;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_usuario", nullable = false)
    private Usuario usuario;
}