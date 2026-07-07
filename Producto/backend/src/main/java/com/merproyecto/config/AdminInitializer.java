package com.merproyecto.config;

import com.merproyecto.model.*;
import com.merproyecto.repository.*;
import lombok.RequiredArgsConstructor;
import org.springframework.boot.CommandLineRunner;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.security.crypto.password.PasswordEncoder;

import java.time.LocalDate;
import java.time.LocalDateTime;

@Configuration
@RequiredArgsConstructor
public class AdminInitializer {

    private final UsuarioRepository usuarioRepository;
    private final RolRepository rolRepository;
    private final OrganizacionRepository organizacionRepository;
    private final DepartamentoRepository departamentoRepository;
    private final EstadoRepository estadoRepository;
    private final KpiRepository kpiRepository;
    private final ProcesoRepository procesoRepository;
    private final TareaRepository tareaRepository;
    private final PasswordEncoder passwordEncoder;

    @Bean
    CommandLineRunner initAdmin() {
        return args -> {

            // ROLES
            Rol rolAdmin = crearRolSiNoExiste("Admin", "Administrador del sistema");
            Rol rolUsuario = crearRolSiNoExiste("Usuario", "Usuario normal");

            // ESTADOS
            Estado estadoActivo = crearEstadoSiNoExiste("Activo", 'A');
            Estado estadoInactivo = crearEstadoSiNoExiste("Inactivo", 'I');
            Estado estadoCompletada = crearEstadoSiNoExiste("Completada", 'F');

            // ORGANIZACIONES
            Organizacion orgMer = crearOrganizacionSiNoExiste(
                    "Mi Empresa",
                    12345678,
                    'K',
                    "contacto@empresa.cl",
                    "Activo"
            );

            Organizacion orgTech = crearOrganizacionSiNoExiste(
                    "TechCorp Ltda",
                    98765432,
                    '1',
                    "contacto@techcorp.cl",
                    "Activo"
            );

            Organizacion orgInnova = crearOrganizacionSiNoExiste(
                    "Innovatech SpA",
                    11223344,
                    'K',
                    "contacto@innovatech.cl",
                    "Activo"
            );

            Organizacion orgData = crearOrganizacionSiNoExiste(
                    "DataSystems",
                    55667788,
                    '3',
                    "contacto@datasystems.cl",
                    "Activo"
            );

            // DEPARTAMENTOS
            Departamento depGestion = crearDepartamentoSiNoExiste(
                    "Gestión de Proyectos",
                    "Planificación y control de proyectos",
                    orgMer
            );

            crearDepartamentoSiNoExiste("Analista Programador", "Desarrollo y mantención de software", orgMer);
            crearDepartamentoSiNoExiste("Ingeniería en Redes", "Infraestructura y conectividad de redes", orgMer);
            crearDepartamentoSiNoExiste("Ciberseguridad", "Seguridad de la información", orgMer);
            crearDepartamentoSiNoExiste("Administración", "Gestión administrativa y finanzas", orgMer);

            crearDepartamentoSiNoExiste("Desarrollo de Software", "Diseño y desarrollo de aplicaciones", orgTech);
            crearDepartamentoSiNoExiste("Soporte TI", "Soporte técnico a usuarios internos", orgTech);
            crearDepartamentoSiNoExiste("Base de Datos", "Administración y optimización de BD", orgTech);
            crearDepartamentoSiNoExiste("Recursos Humanos", "Gestión de personas y talento", orgTech);

            crearDepartamentoSiNoExiste("Innovación", "Investigación y desarrollo de nuevas ideas", orgInnova);
            crearDepartamentoSiNoExiste("Marketing Digital", "Estrategias de marketing en línea", orgInnova);
            crearDepartamentoSiNoExiste("Operaciones", "Operaciones y logística", orgInnova);
            crearDepartamentoSiNoExiste("Finanzas", "Control financiero y contabilidad", orgInnova);

            crearDepartamentoSiNoExiste("Análisis de Datos", "Procesamiento y análisis de información", orgData);
            crearDepartamentoSiNoExiste("Infraestructura", "Servidores y sistemas de almacenamiento", orgData);

            // KPI
            Kpi kpiTareas = crearKpiSiNoExiste(
                    "Tareas completadas",
                    0,
                    100,
                    "%",
                    LocalDateTime.now()
            );

            // USUARIOS
            Usuario admin = crearUsuarioSiNoExiste(
                    "admin@admin.com",
                    "Administrador",
                    "Sistema",
                    "Principal",
                    "admin123",
                    "999999999",
                    rolAdmin,
                    orgMer,
                    depGestion
            );

            Usuario sebastian = crearUsuarioSiNoExiste(
                    "seba@email.com",
                    "Sebastian",
                    "Mardones",
                    "Araya",
                    "123456",
                    "999999999",
                    rolAdmin,
                    orgMer,
                    depGestion
            );

            // USUARIO NORMAL (para pruebas CP-18)
            Usuario usuarioTest = crearUsuarioSiNoExiste(
                    "usuario@test.cl",
                    "Test",
                    "Usuario",
                    "Normal",
                    "Prueba123",
                    "999999998",
                    rolUsuario,
                    orgMer,
                    depGestion
            );

            // PROCESO BASE
            Proceso onboarding = crearProcesoSiNoExiste(
                    "Onboarding cliente B",
                    "Proceso de incorporación cliente B",
                    LocalDate.of(2026, 4, 1),
                    LocalDate.of(2026, 5, 30),
                    orgMer,
                    kpiTareas,
                    estadoActivo
            );

            // TAREAS BASE
            crearTareaSiNoExiste(
                    "Revisión contrato",
                    "Revisar cláusulas del contrato",
                    1,
                    LocalDate.of(2026, 5, 22),
                    null,
                    LocalDate.of(2026, 4, 1),
                    onboarding,
                    sebastian,
                    estadoInactivo
            );

            crearTareaSiNoExiste(
                    "Configurar accesos",
                    "Crear credenciales del sistema",
                    2,
                    LocalDate.of(2026, 5, 25),
                    null,
                    LocalDate.of(2026, 4, 1),
                    onboarding,
                    sebastian,
                    estadoActivo
            );

            crearTareaSiNoExiste(
                    "Reunión kickoff",
                    "Reunión inicial con cliente",
                    3,
                    LocalDate.of(2026, 5, 10),
                    LocalDateTime.of(2026, 5, 10, 10, 0),
                    LocalDate.of(2026, 4, 1),
                    onboarding,
                    sebastian,
                    estadoCompletada
            );

            System.out.println("DATOS INICIALES CARGADOS CORRECTAMENTE");
        };
    }

    private Rol crearRolSiNoExiste(String nombre, String descripcion) {
        return rolRepository.findAll()
                .stream()
                .filter(r -> r.getNombre().equalsIgnoreCase(nombre))
                .findFirst()
                .orElseGet(() -> {
                    Rol rol = new Rol();
                    rol.setNombre(nombre);
                    rol.setDescripcion(descripcion);
                    rol.setUsuario(null);
                    return rolRepository.save(rol);
                });
    }

    private Estado crearEstadoSiNoExiste(String nombre, Character valor) {
        return estadoRepository.findAll()
                .stream()
                .filter(e -> e.getNombreEstado().equalsIgnoreCase(nombre))
                .findFirst()
                .orElseGet(() -> {
                    Estado estado = new Estado();
                    estado.setNombreEstado(nombre);
                    estado.setValorEstado(valor);
                    return estadoRepository.save(estado);
                });
    }

    private Organizacion crearOrganizacionSiNoExiste(
            String nombre,
            Integer rut,
            Character dv,
            String email,
            String estadoTexto
    ) {
        return organizacionRepository.findAll()
                .stream()
                .filter(o -> o.getNombre().equalsIgnoreCase(nombre))
                .findFirst()
                .orElseGet(() -> {
                    Organizacion org = new Organizacion();
                    org.setNombre(nombre);
                    org.setRut(rut);
                    org.setDv(dv);
                    org.setEmailContacto(email);
                    org.setEstado(estadoTexto);
                    org.setFechaCreacion(LocalDate.now());
                    return organizacionRepository.save(org);
                });
    }

    private Departamento crearDepartamentoSiNoExiste(
            String nombre,
            String descripcion,
            Organizacion organizacion
    ) {
        return departamentoRepository
                .findByOrganizacion_IdOrganizacion(organizacion.getIdOrganizacion())
                .stream()
                .filter(d -> d.getNombre().equalsIgnoreCase(nombre))
                .findFirst()
                .orElseGet(() -> {
                    Departamento dep = new Departamento();
                    dep.setNombre(nombre);
                    dep.setDescripcion(descripcion);
                    dep.setOrganizacion(organizacion);
                    return departamentoRepository.save(dep);
                });
    }

    private Kpi crearKpiSiNoExiste(
            String nombre,
            Integer valorActual,
            Integer valorObjetivo,
            String unidad,
            LocalDateTime calculadoEn
    ) {
        return kpiRepository.findAll()
                .stream()
                .filter(k -> k.getNombreKpi().equalsIgnoreCase(nombre))
                .findFirst()
                .orElseGet(() -> {
                    Kpi kpi = new Kpi();
                    kpi.setNombreKpi(nombre);
                    kpi.setValorActual(valorActual);
                    kpi.setValorObjetivo(valorObjetivo);
                    kpi.setUnidadKpi(unidad);
                    kpi.setCalculadoEn(calculadoEn);
                    return kpiRepository.save(kpi);
                });
    }

    private Usuario crearUsuarioSiNoExiste(
            String email,
            String nombre,
            String apellidoP,
            String apellidoM,
            String password,
            String telefono,
            Rol rol,
            Organizacion organizacion,
            Departamento departamento
    ) {
        return usuarioRepository.findByEmailUsuario(email)
                .orElseGet(() -> {
                    Usuario usuario = new Usuario();
                    usuario.setNombre(nombre);
                    usuario.setApellidoP(apellidoP);
                    usuario.setApellidoM(apellidoM);
                    usuario.setEmailUsuario(email);
                    usuario.setPassword(passwordEncoder.encode(password));
                    usuario.setTelefono(telefono);
                    usuario.setIntentosFallidos(0);
                    usuario.setBloqueado('N');
                    usuario.setUltimoLogin(LocalDateTime.now());
                    usuario.setFechaCreacion(LocalDate.now());
                    usuario.setRol(rol);
                    usuario.setOrganizacion(organizacion);
                    usuario.setDepartamento(departamento);
                    return usuarioRepository.save(usuario);
                });
    }

    private Proceso crearProcesoSiNoExiste(
            String nombre,
            String descripcion,
            LocalDate fechaInicio,
            LocalDate fechaLimite,
            Organizacion organizacion,
            Kpi kpi,
            Estado estado
    ) {
        return procesoRepository.findAll()
                .stream()
                .filter(p -> p.getNombre().equalsIgnoreCase(nombre))
                .findFirst()
                .orElseGet(() -> {
                    Proceso proceso = new Proceso();
                    proceso.setNombre(nombre);
                    proceso.setDescripcionProceso(descripcion);
                    proceso.setFechaInicio(fechaInicio);
                    proceso.setFechaLimite(fechaLimite);
                    proceso.setFechaCreacion(LocalDate.now());
                    proceso.setOrganizacion(organizacion);
                    proceso.setKpi(kpi);
                    proceso.setEstado(estado);
                    return procesoRepository.save(proceso);
                });
    }

    private Tarea crearTareaSiNoExiste(
            String nombre,
            String descripcion,
            Integer orden,
            LocalDate fechaLimite,
            LocalDateTime fechaCompletada,
            LocalDate fechaCreacion,
            Proceso proceso,
            Usuario usuario,
            Estado estado
    ) {
        return tareaRepository.findAll()
                .stream()
                .filter(t -> t.getNombreTarea().equalsIgnoreCase(nombre)
                        && t.getProceso().getIdProceso().equals(proceso.getIdProceso()))
                .findFirst()
                .orElseGet(() -> {
                    Tarea tarea = new Tarea();
                    tarea.setNombreTarea(nombre);
                    tarea.setDescripcionT(descripcion);
                    tarea.setOrdenT(orden);
                    tarea.setFechaLimiteS(fechaLimite);
                    tarea.setFechaCompletada(fechaCompletada);
                    tarea.setFechaCreacionT(fechaCreacion);
                    tarea.setProceso(proceso);
                    tarea.setUsuario(usuario);
                    tarea.setEstado(estado);
                    return tareaRepository.save(tarea);
                });
    }
}