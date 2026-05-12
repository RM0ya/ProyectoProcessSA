package com.merproyecto.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;

@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
@Entity
@Table(name = "NOTIFICACION")
@Data @NoArgsConstructor @AllArgsConstructor
public class Notificacion {

    @Id
    @Column(name = "id_notificacion")
    private Integer idNotificacion;

    @Column(name = "tipo_noti", nullable = false, length = 25)
    private String tipoNoti;

    @Column(name = "mensaje_noti", nullable = false, length = 50)
    private String mensajeNoti;

    @Column(name = "noti_leida", nullable = false, length = 1)
    private Character notiLeida;

    @Column(name = "fecha_envio", nullable = false)
    private LocalDate fechaEnvio;

    @Column(name = "fecha_lectura")
    private LocalDateTime fechaLectura;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_usuario", nullable = false)
    private Usuario usuario;
}