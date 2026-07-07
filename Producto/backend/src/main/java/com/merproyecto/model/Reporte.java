package com.merproyecto.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDateTime;

@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
@Entity
@Table(name = "REPORTE")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Reporte {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_reporte")
    private Integer idReporte;

    @Column(name = "nombre", nullable = false, length = 50)
    private String nombre;

    @Column(name = "formato_reporte", nullable = false, length = 25)
    private String formatoReporte;

    @Column(name = "s3_key", nullable = false, length = 100)
    private String s3Key;

    @Column(name = "generado_en", nullable = false)
    private LocalDateTime generadoEn;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_organizacion", nullable = false)
    private Organizacion organizacion;
}