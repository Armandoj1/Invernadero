# 🏡 Sistema de Control Inteligente de Invernaderos

![Flutter](https://img.shields.io/badge/Flutter-3.9+-02569B?logo=flutter&logoColor=white)
![Dart](https://img.shields.io/badge/Dart-3.9+-0175C2?logo=dart&logoColor=white)
![Firebase](https://img.shields.io/badge/Firebase-FFCA28?logo=firebase&logoColor=black)
![License](https://img.shields.io/badge/license-MIT-green)

Sistema completo de monitoreo y control de invernaderos con inteligencia artificial, lógica difusa y control manual de dispositivos IoT.

## 📋 Tabla de Contenidos

- [Características](#-características)
- [Requisitos](#-requisitos)
- [Instalación](#-instalación)
- [Uso](#-uso)
- [Arquitectura](#-arquitectura)
- [Documentación](#-documentación)
- [Contribuir](#-contribuir)
- [Licencia](#-licencia)

## ✨ Características

### 🔬 Monitoreo en Tiempo Real
- Temperatura del aire y del suelo
- Humedad del aire y del suelo
- Luminosidad (LDR)
- Gráficas de tendencias históricas

### 🤖 Control Inteligente
- **Modo Automático**: IA/Lógica difusa toma decisiones
- **Modo Manual**: Control directo del usuario
- **Modo Híbrido**: IA con supervisión manual

### 🌱 Soporte Multiplanta
- **Lechuga**: Ambiente fresco, humedad moderada
- **Pimentón**: Ambiente templado, alta luminosidad
- **Tomate**: Ambiente cálido, máxima luminosidad

### 🎛️ Control de Dispositivos
- Ventilador (0-100% velocidad)
- Riego automatizado (duración configurable)
- Iluminación (5 niveles de intensidad)

### 📊 Reportes y Analytics
- Reportes diarios, semanales y mensuales
- Exportación PDF con gráficas
- Historial de datos

### 🔐 Gestión de Usuarios
- Autenticación segura con Firebase
- Perfiles personalizables
- Roles y permisos

## 🚀 Requisitos

- Flutter SDK >=3.9.0
- Dart SDK >=3.9.0
- Firebase Project configurado
- Backend REST API (opcional)

## 📦 Instalación

```bash
# Clonar repositorio
git clone https://github.com/tu-usuario/invernadero.git
cd invernadero

# Instalar dependencias
flutter pub get

# Configurar Firebase
flutterfire configure

# Ejecutar aplicación
flutter run
```

## 🎯 Uso

### Primera Configuración

1. **Registrarse o Iniciar Sesión**
   - Crear cuenta nueva o usar credenciales existentes
   - Completar perfil de usuario

2. **Configurar Invernadero**
   - Seleccionar tipo de planta
   - Elegir modo de operación (Automático/Manual/Híbrido)
   - Configurar parámetros objetivos

3. **Monitorear Dashboard**
   - Visualizar datos en tiempo real
   - Ver gráficas de tendencias
   - Controlar dispositivos (modo manual)

### Control Manual

En modo manual, puedes controlar directamente:
- **Ventilador**: Ajustar velocidad con slider (0-100%)
- **Riego**: Definir duración en segundos (30s, 1min, 2min)
- **Luminosidad**: Seleccionar nivel de intensidad (1-5)

### Generar Reportes

1. Navegar a la sección Reportes
2. Seleccionar período (Día/Semana/Mes)
3. Generar y descargar PDF
4. Visualizar gráficas y estadísticas

## 🏗️ Arquitectura

### Stack Tecnológico

- **Frontend**: Flutter, Dart
- **State Management**: Provider + GetX
- **Backend**: Firebase (Firestore, Auth)
- **Visualización**: FL Chart
- **HTTP Client**: Dio
- **PDF Generation**: PDF Package

### Estructura del Proyecto

```
lib/
├── models/          # Modelos de datos
├── services/        # Servicios y lógica de negocio
├── controllers/     # Controladores de estado
├── ui/              # Interfaces de usuario
│   ├── auth/        # Login/Register
│   ├── home/        # Dashboard principal
│   └── widgets/     # Componentes reutilizables
└── utils/           # Utilidades y helpers
```

### Patrones de Diseño

- **Provider Pattern**: Estado global
- **GetX Pattern**: Routing y controladores
- **Repository Pattern**: Acceso a datos
- **MVC**: Separación de responsabilidades

## 📚 Documentación

### Documentos Principales

- **[ARQUITECTURA.md](./ARQUITECTURA.md)** - Arquitectura técnica completa
- **[GUIA_IMPLEMENTACION.md](./GUIA_IMPLEMENTACION.md)** - Guía paso a paso
- **[RESUMEN_PROYECTO.md](./RESUMEN_PROYECTO.md)** - Resumen ejecutivo

### Recursos Adicionales

- [Flutter Documentation](https://docs.flutter.dev/)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [GetX Documentation](https://pub.dev/packages/get)

## 🧪 Testing

```bash
# Ejecutar tests unitarios
flutter test

# Ejecutar tests de integración
flutter test integration_test/

# Generar coverage report
flutter test --coverage
```

## 📱 Build y Deploy

### Android

```bash
flutter build apk --release
```

### iOS

```bash
flutter build ios --release
```

### Web

```bash
flutter build web --release
```

## 🤝 Contribuir

1. Fork el proyecto
2. Crea tu feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit tus cambios (`git commit -m 'Add some AmazingFeature'`)
4. Push a la branch (`git push origin feature/AmazingFeature`)
5. Abre un Pull Request

## 📄 Licencia

Este proyecto está bajo la Licencia MIT - ver el archivo [LICENSE](LICENSE) para más detalles.

## 👥 Autores

- **Equipo de Desarrollo** - Trabajo inicial y mantenimiento

## 🙏 Agradecimientos

- Flutter Team por el framework excepcional
- Firebase Team por la plataforma backend
- Comunidad open source por las librerías utilizadas

---

**Desarrollado con ❤️ usando Flutter**
