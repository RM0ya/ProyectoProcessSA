<<<<<<< HEAD
# MERPROYECTO - Backend Spring Boot

## Requisitos
- Java 21
- Maven 3.8+
- MySQL 8+
- IntelliJ IDEA

## Configuración

### 1. Base de datos
Ejecuta el script SQL en MySQL:
```sql
-- Crea la DB y todas las tablas según el script MERPROYECTO.sql
```

### 2. application.properties
Edita `src/main/resources/application.properties`:
```properties
spring.datasource.url=jdbc:mysql://localhost:3306/MERPROYECTO?...
spring.datasource.username=root
spring.datasource.password=TU_PASSWORD
```

### 3. Abrir en IntelliJ
- File → Open → selecciona la carpeta `merproyecto`
- IntelliJ detecta automáticamente el `pom.xml`
- Espera que Maven descargue dependencias
- Ejecuta `MerproyectoApplication.java`

## Endpoints disponibles

| Entidad        | Base URL                 |
|----------------|--------------------------|
| Estado         | /api/estados             |
| Organización   | /api/organizacions       |
| Rol            | /api/rols                |
| KPI            | /api/kpis                |
| Usuario        | /api/usuarios            |
| Sesión         | /api/sesions             |
| Log Actividad  | /api/logs                |
| Notificación   | /api/notificaciones      |
| Reporte        | /api/reportes            |
| Proceso        | /api/procesos            |
| Tarea          | /api/tareas              |

## Operaciones por entidad
- `GET    /api/{entidad}`         → Listar todos
- `GET    /api/{entidad}/{id}`    → Obtener por ID
- `POST   /api/{entidad}`        → Crear
- `PUT    /api/{entidad}/{id}`   → Actualizar
- `DELETE /api/{entidad}/{id}`   → Eliminar

### Endpoints especiales - Tarea (clave compuesta)
- `GET /api/tareas/{idTarea}/{idProceso}`
- `GET /api/tareas/proceso/{idProceso}`
- `GET /api/tareas/usuario/{idUsuario}`
- `DELETE /api/tareas/{idTarea}/{idProceso}`

## Estructura del proyecto
```
merproyecto/
├── pom.xml
└── src/main/java/com/merproyecto/
    ├── MerproyectoApplication.java
    ├── model/          ← Entidades JPA (12 clases)
    ├── repository/     ← JpaRepository (12 interfaces)
    ├── service/        ← Interfaces de servicio
    │   └── impl/      ← Implementaciones
    ├── controller/     ← REST Controllers
    └── config/         ← CORS + GlobalExceptionHandler
```
=======
# Proyecto Process SA

Sistema de gestión de procesos y tareas empresariales.

## Tecnologías
- Backend: Spring Boot (microservicios)
- Frontend: Flutter
- Base de datos: MySQL (RDS)
- Infraestructura: AWS (EC2, S3)

##  Aplicación Flutter
Este proyecto contiene la app móvil desarrollada en Flutter para interactuar con el sistema.

### Cómo ejecutar
```bash
flutter pub get
flutter run
>>>>>>> 591e53136e856f8783e581a09881dd102313bfa1
