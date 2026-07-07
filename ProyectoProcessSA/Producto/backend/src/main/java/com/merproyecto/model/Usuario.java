package com.merproyecto.model;

import com.fasterxml.jackson.annotation.JsonIgnore;
import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonProperty;
import jakarta.persistence.*;
import lombok.*;
import java.time.LocalDate;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

@JsonIgnoreProperties({"hibernateLazyInitializer", "handler"})
@Entity
@Table(name = "USUARIO")
@Getter @Setter @NoArgsConstructor @AllArgsConstructor
@ToString(exclude = {"sesiones", "rol", "organizacion", "departamento"})
@EqualsAndHashCode(exclude = {"sesiones", "rol", "organizacion", "departamento"})
public class Usuario {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    @Column(name = "id_usuario")
    private Integer idUsuario;

    @Column(name = "nombre", nullable = false, length = 25)
    private String nombre;

    @Column(name = "apellido_p", nullable = false, length = 25)
    private String apellidoP;

    @Column(name = "apellido_m", length = 25)
    private String apellidoM;

    @Column(name = "email_usuario", nullable = false, length = 50)
    private String emailUsuario;

    @JsonProperty(access = JsonProperty.Access.WRITE_ONLY)
    @Column(name = "password", nullable = false, columnDefinition = "TEXT")
    private String password;

    @Column(name = "intentos_fallidos")
    private Integer intentosFallidos;

    @Column(name = "bloqueado", nullable = false, length = 1)
    private Character bloqueado;

    @Column(name = "ultimo_login", nullable = false)
    private LocalDateTime ultimoLogin;

    @Column(name = "fecha_creacion", nullable = false)
    private LocalDate fechaCreacion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_rol", nullable = false)
    private Rol rol;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_organizacion", nullable = true)
    private Organizacion organizacion;

    @ManyToOne(fetch = FetchType.LAZY)
    @JoinColumn(name = "id_departamento", nullable = true)
    private Departamento departamento;

    @Column(name = "telefono", length = 12)
    private String telefono;

    @JsonIgnore
    @OneToMany(mappedBy = "usuario", cascade = CascadeType.ALL, orphanRemoval = true)
    private List<Sesion> sesiones = new ArrayList<>();
}