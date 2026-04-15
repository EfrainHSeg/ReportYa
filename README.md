# ReportYa

Aplicación móvil para la gestión y seguimiento de reportes de campo en operaciones industriales. Permite a los trabajadores registrar incidencias, adjuntar evidencia fotográfica y generar reportes en PDF, con un dashboard de estadísticas en tiempo real.

## Características

- Autenticación con correo/contraseña y Google
- Creación de reportes con título, descripción, área y nivel de riesgo
- Captura y carga de fotos como evidencia
- Generación y compartición de reportes en PDF
- Dashboard con estadísticas por período (7 días, mes, 3 meses, año)
- Historial de reportes con filtros por estado
- Vista de tareas asignadas
- Unidades de trabajo agrupadas por región

## Tecnologías

- **Flutter** / Dart
- **Firebase Auth** — autenticación
- **fl_chart** — gráficos estadísticos
- **pdf / printing** — generación de PDFs

## Arquitectura

El proyecto sigue una arquitectura **feature-based** con separación por capas:

```
lib/
├── core/               # Tema, colores, configuración global
├── features/
│   ├── auth/           # Login, registro, Google Sign-In
│   ├── dashboard/      # Home, estadísticas, perfil
│   ├── reports/        # Crear, listar, previsualizar reportes
│   ├── tasks/          # Tareas asignadas
│   ├── units/          # Unidades de trabajo
│   └── splash/         # Pantalla de carga
└── shared/             # Widgets reutilizables
```

## Instalación

### Prerrequisitos

- Flutter SDK >= 3.0
- Dart >= 3.0
- Android Studio o VS Code

### Pasos

```bash
git clone https://github.com/EfrainHSeg/ReportYa.git
cd ReportYa
flutter pub get
flutter run
```

## Autor

**Efrain H. Segura**
