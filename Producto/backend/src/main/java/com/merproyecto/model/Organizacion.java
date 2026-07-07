package com.merproyecto.model;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;

@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
@Entity
@Table(name = "ORGANIZACION")
@Data
@NoArgsConstructor
@AllArgsConstructor
public class Organizacion {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_organizacion")
    private Integer idOrganizacion;

    @Column(name = "nombre", nullable = false, length = 25)
    private String nombre;

    @Column(name = "rut", nullable = false)
    private Integer rut;

    @Column(name = "dv", nullable = false, length = 1)
    private Character dv;

    @Column(name = "email_contacto", nullable = false, length = 50)
    private String emailContacto;

    @Column(name = "estado", nullable = false, length = 25)
    private String estado;

    @Column(name = "fecha_creacion", nullable = false)
    private LocalDate fechaCreacion;
}