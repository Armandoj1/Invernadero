# 🏗️ Arquitectura del Sistema Invernadero - Flutter

## 📋 Índice
1. [Resumen Ejecutivo](#resumen-ejecutivo)
2. [Estado Actual del Proyecto](#estado-actual)
3. [Funcionalidades Requeridas](#funcionalidades-requeridas)
4. [Arquitectura Propuesta](#arquitectura-propuesta)
5. [Modelos de Datos](#modelos-de-datos)
6. [Servicios y Controladores](#servicios-y-controladores)
7. [Vistas y Componentes UI](#vistas-y-componentes-ui)
8. [Comunicación con Backend](#comunicación-con-backend)
9. [Plan de Implementación](#plan-de-implementación)
10. [Mejoras Propuestas](#mejoras-propuestas)

---

## 🎯 Resumen Ejecutivo

### Descripción
Sistema de control inteligente para invernaderos que monitorea y regula parámetros ambientales (temperatura, humedad, luminosidad) mediante sensores IoT, con dos modos de operación: **Automático con IA/Lógica Difusa** y **Manual con control directo del usuario**.

### Objetivos
- Control en tiempo real de temperatura del aire, temperatura del suelo, humedad y luminosidad
- Operación automática mediante IA/Lógica difusa
- Control manual de dispositivos (ventilador, bomba de agua, luz)
- Selección del tipo de planta con parámetros optimizados
- Generación de reportes PDF con gráficas
- Gestión de usuarios con roles

---

## 📊 Estado Actual del Proyecto

### ✅ Funcionalidades Implementadas
1. **Autenticación y Gestión de Usuarios**
   - Login/Register con Firebase Auth
   - Perfiles de usuario con Firestore
   - Cambio de contraseña
   - Roles básicos

2. **Dashboard Principal**
   - Visualización de temperatura en tiempo real (simulada)
   - Gráfico de tendencias de temperatura (24h)
   - Control de IA con 3 modos (Automático, Manual, Híbrido)
   - Tarjetas informativas

3. **Control de IA**
   - Sistema de modo Automático, Manual e Híbrido
   - Parámetros configurable (temperatura, humedad, CO₂)
   - Integración con Firestore

4. **Base de Arquitectura**
   - Estructura de carpetas organizada
   - GetX para routing y controladores
   - Provider para estado global
   - Firebase integrado

### ⚠️ Funcionalidades Faltantes
1. ❌ **Sensores en Tiempo Real**
   - Temperatura del suelo
   - Humedad del suelo
   - Humedad del aire
   - Luminosidad (LDR)
   - Integración real con sensores IoT

2. ❌ **Control Manual de Dispositivos**
   - Control de ventilador (velocidad)
   - Control de bomba de agua (duración riego)
   - Control de luminosidad (5 niveles)

3. ❌ **Tipos de Plantas**
   - Lechuga (parámetros específicos)
   - Pimentón (parámetros específicos)
   - Tomate (parámetros específicos)

4. ❌ **Reportes PDF**
   - Generación de reportes diarios, semanales y mensuales
   - Gráficas de variaciones
   - Exportación y visualización

5. ❌ **Backend REST API**
   - Endpoints para sensores
   - Endpoints para control de dispositivos
   - Integración con lógica difusa

---

## 🎯 Funcionalidades Requeridas

### 1. Dashboard Principal
```
┌─────────────────────────────────────────────────┐
│  🔷 Modo: Automático/Manual                    │
│  🌱 Tipo de Planta: [Lechuga|Pimentón|Tomate]  │
└─────────────────────────────────────────────────┘

┌─────────────────┬─────────────────┬─────────────────┐
│ 🌡️ Temp. Aire  │ 💧 Humedad Aire │ 🌡️ Temp. Suelo │
│   24.5°C        │     65%         │    22.0°C      │
└─────────────────┴─────────────────┴─────────────────┘

┌─────────────────────────────────────────────────┐
│  📊 Gráfico de Tendencias (24h)                 │
│  [Temperatura, Humedad, Luminosidad]            │
└─────────────────────────────────────────────────┘

┌─────────────────┬─────────────────┬─────────────────┐
│  🌀 Ventilar    │  💧 Regar       │  💡 Luminosidad │
│  [Slider 0-100%]│  [Input minutos]│  [1-5 niveles]  │
└─────────────────┴─────────────────┴─────────────────┘
```

### 2. Modo Automático (IA/Lógica Difusa)
- El backend evalúa sensores y toma decisiones autónomas
- Frontend recibe comandos y los visualiza
- No intervención manual necesaria

### 3. Modo Manual
- Usuario controla directamente:
  - **Ventilador**: Velocidad 0-100%
  - **Riego**: Duración en segundos/minutos
  - **Luminosidad**: Niveles 1-5

### 4. Tipos de Plantas y Parámetros Óptimos

#### Lechuga
```yaml
Temperatura: 15-20°C
Humedad: 60-70%
Humedad Suelo: 75-85%
Luminosidad: Moderada (3/5)
```

#### Pimentón
```yaml
Temperatura: 21-26°C
Humedad: 65-75%
Humedad Suelo: 70-80%
Luminosidad: Alta (4-5/5)
```

#### Tomate
```yaml
Temperatura: 20-24°C
Humedad: 70-80%
Humedad Suelo: 70-80%
Luminosidad: Muy Alta (5/5)
```

---

## 🏗️ Arquitectura Propuesta

### Estructura de Carpetas
```
lib/
├── main.dart
├── firebase_options.dart
│
├── 📁 models/
│   ├── sensor_data.dart          ⭐ NUEVO
│   ├── planta_model.dart          ⭐ NUEVO
│   ├── dispositivo_control.dart   ⭐ NUEVO
│   ├── reporte_model.dart         ⭐ NUEVO
│   ├── user_model.dart           ✅ EXISTE
│   ├── ia_control.dart           ✅ EXISTE
│   └── perfil.dart               ✅ EXISTE
│
├── 📁 services/
│   ├── sensor_service.dart       ⭐ NUEVO
│   ├── dispositivo_service.dart  ⭐ NUEVO
│   ├── reporte_service.dart      ⭐ NUEVO
│   ├── ia_control_service.dart   ✅ EXISTE
│   └── perfilservices.dart       ✅ EXISTE
│
├── 📁 controllers/
│   ├── sensor_controller.dart    ⭐ NUEVO
│   ├── dispositivo_controller.dart ⭐ NUEVO
│   ├── dashboard_controller.dart ⭐ NUEVO
│   ├── reporte_controller.dart   ⭐ NUEVO
│   ├── auth_controller.dart      ✅ EXISTE
│   ├── ia_control_controller.dart ✅ EXISTE
│   └── perfilcontrollers.dart    ✅ EXISTE
│
├── 📁 ui/
│   ├── app.dart                  ✅ EXISTE
│   │
│   ├── 📁 auth/
│   │   ├── login_view.dart       ✅ EXISTE
│   │   └── register_view.dart    ✅ EXISTE
│   │
│   ├── 📁 home/
│   │   ├── dashboard_view.dart   ⭐ RENOMBRAR/MEJORAR
│   │   ├── home_view.dart        ✅ EXISTE
│   │   ├── ia_control.dart       ✅ EXISTE
│   │   ├── perfil.dart           ✅ EXISTE
│   │   └── editPerfil.dart       ✅ EXISTE
│   │
│   ├── 📁 sensores/
│   │   ├── sensor_card.dart      ⭐ NUEVO
│   │   └── sensor_chart.dart     ⭐ NUEVO
│   │
│   ├── 📁 control/
│   │   ├── ventilador_control.dart ⭐ NUEVO
│   │   ├── riego_control.dart    ⭐ NUEVO
│   │   └── luminosidad_control.dart ⭐ NUEVO
│   │
│   ├── 📁 reportes/
│   │   ├── reportes_view.dart    ⭐ NUEVO
│   │   └── reporte_item.dart     ⭐ NUEVO
│   │
│   └── 📁 widgets/
│       ├── planta_selector.dart  ⭐ NUEVO
│       ├── modo_selector.dart    ⭐ NUEVO
│       └── info_card.dart        ⭐ NUEVO
│
└── 📁 utils/
    ├── constants.dart            ⭐ NUEVO
    ├── helpers.dart              ⭐ NUEVO
    └── pdf_generator.dart        ⭐ NUEVO
```

---

## 📦 Modelos de Datos

### 1. SensorData ⭐ NUEVO
```dart
class SensorData {
  final String id;
  final double temperaturaAire;
  final double temperaturaSuelo;
  final double humedadAire;
  final double humedadSuelo;
  final double luminosidad; // 0-100%
  final DateTime timestamp;
  
  SensorData({
    required this.id,
    required this.temperaturaAire,
    required this.temperaturaSuelo,
    required this.humedadAire,
    required this.humedadSuelo,
    required this.luminosidad,
    required this.timestamp,
  });
  
  factory SensorData.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  SensorData copyWith({...});
}
```

### 2. PlantaModel ⭐ NUEVO
```dart
enum TipoPlanta { lechuga, pimenton, tomate }

class PlantaModel {
  final TipoPlanta tipo;
  final RangoTemperatura temperaturaOptima;
  final RangoHumedad humedadOptima;
  final RangoHumedad humedadSueloOptima;
  final int nivelLuminosidad; // 1-5
  
  PlantaModel({
    required this.tipo,
    required this.temperaturaOptima,
    required this.humedadOptima,
    required this.humedadSueloOptima,
    required this.nivelLuminosidad,
  });
  
  String get nombre => _tipoToString(tipo);
  static PlantaModel getDefault(TipoPlanta tipo);
}

class RangoTemperatura {
  final double min;
  final double max;
  RangoTemperatura({required this.min, required this.max});
}

class RangoHumedad {
  final double min;
  final double max;
  RangoHumedad({required this.min, required this.max});
}
```

### 3. DispositivoControl ⭐ NUEVO
```dart
class DispositivoControl {
  final String id;
  final double velocidadVentilador; // 0-100%
  final int duracionRiego; // segundos
  final int intensidadLuminosidad; // 1-5
  final DateTime ultimaActualizacion;
  final String usuarioId;
  
  DispositivoControl({
    required this.id,
    required this.velocidadVentilador,
    required this.duracionRiego,
    required this.intensidadLuminosidad,
    required this.ultimaActualizacion,
    required this.usuarioId,
  });
  
  factory DispositivoControl.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
  DispositivoControl copyWith({...});
}
```

### 4. ReporteModel ⭐ NUEVO
```dart
enum PeriodoReporte { dia, semana, mes }

class ReporteModel {
  final String id;
  final PeriodoReporte periodo;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final List<SensorData> datos;
  final Estadisticas estadisticas;
  
  ReporteModel({
    required this.id,
    required this.periodo,
    required this.fechaInicio,
    required this.fechaFin,
    required this.datos,
    required this.estadisticas,
  });
  
  factory ReporteModel.fromJson(Map<String, dynamic> json);
  Map<String, dynamic> toJson();
}

class Estadisticas {
  final double tempAirePromedio;
  final double tempAireMaxima;
  final double tempAireMinima;
  final double humedadPromedio;
  final int eventosRiego;
  final double horasLuz;
  // ... más estadísticas
}
```

---

## 🔧 Servicios y Controladores

### 1. SensorService ⭐ NUEVO
```dart
class SensorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Stream de datos en tiempo real
  Stream<SensorData> getSensorDataStream(String userId) {
    return _firestore
      .collection('sensores')
      .doc(userId)
      .snapshots()
      .map((doc) => SensorData.fromJson(doc.data()!));
  }
  
  // Obtener histórico
  Future<List<SensorData>> getHistorico(
    String userId,
    DateTime inicio,
    DateTime fin,
  ) async {
    // Implementación con consulta Firestore
  }
}
```

### 2. DispositivoService ⭐ NUEVO
```dart
class DispositivoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Actualizar velocidad ventilador
  Future<bool> setVelocidadVentilador(
    String userId,
    double velocidad,
  ) async {
    try {
      await _firestore.collection('dispositivos').doc(userId).update({
        'velocidadVentilador': velocidad,
        'ultimaActualizacion': FieldValue.serverTimestamp(),
      });
      return true;
    } catch (e) {
      print('Error: $e');
      return false;
    }
  }
  
  // Actualizar riego
  Future<bool> setDuracionRiego(
    String userId,
    int segundos,
  ) async { /* ... */ }
  
  // Actualizar luminosidad
  Future<bool> setIntensidadLuminosidad(
    String userId,
    int nivel,
  ) async { /* ... */ }
}
```

### 3. DashboardController ⭐ NUEVO
```dart
class DashboardController extends ChangeNotifier {
  final SensorService _sensorService;
  final DispositivoService _dispositivoService;
  final IAControlController _iaController;
  
  SensorData? _currentData;
  bool _isLoading = false;
  
  SensorData? get currentData => _currentData;
  bool get isLoading => _isLoading;
  
  StreamSubscription? _sensorSubscription;
  
  DashboardController({
    required SensorService sensorService,
    required DispositivoService dispositivoService,
    required IAControlController iaController,
  }) : _sensorService = sensorService,
       _dispositivoService = dispositivoService,
       _iaController = iaController {
    _init();
  }
  
  void _init() {
    // Suscribirse a datos en tiempo real
    _sensorSubscription = _sensorService
      .getSensorDataStream(Get.find<AuthController>().user!.uid)
      .listen((data) {
        _currentData = data;
        notifyListeners();
      });
  }
  
  Future<void> controlarVentilador(double velocidad) async {
    if (_iaController.control?.modo == 'automatico') return;
    await _dispositivoService.setVelocidadVentilador(
      Get.find<AuthController>().user!.uid,
      velocidad,
    );
  }
  
  // Métodos similares para riego y luminosidad
  
  @override
  void dispose() {
    _sensorSubscription?.cancel();
    super.dispose();
  }
}
```

### 4. ReporteService ⭐ NUEVO
```dart
class ReporteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  Future<ReporteModel> generarReporte(
    String userId,
    PeriodoReporte periodo,
  ) async {
    DateTime inicio, fin;
    switch (periodo) {
      case PeriodoReporte.dia:
        inicio = DateTime.now().subtract(Duration(days: 1));
        fin = DateTime.now();
        break;
      case PeriodoReporte.semana:
        inicio = DateTime.now().subtract(Duration(days: 7));
        fin = DateTime.now();
        break;
      case PeriodoReporte.mes:
        inicio = DateTime.now().subtract(Duration(days: 30));
        fin = DateTime.now();
        break;
    }
    
    // Obtener datos del período
    final datos = await _getHistorico(userId, inicio, fin);
    
    // Calcular estadísticas
    final estadisticas = _calcularEstadisticas(datos);
    
    // Crear reporte
    return ReporteModel(
      id: Uuid().v4(),
      periodo: periodo,
      fechaInicio: inicio,
      fechaFin: fin,
      datos: datos,
      estadisticas: estadisticas,
    );
  }
  
  Future<Uint8List> generarPDF(ReporteModel reporte) async {
    // Implementación con package:pdf
    // Usar pdf_generator.dart
  }
}
```

---

## 🎨 Vistas y Componentes UI

### 1. Dashboard Mejorado (renombrar home_view.dart)
```dart
class DashboardView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Invernadero Control'),
        actions: [
          IconButton(icon: Icon(Icons.report), onPressed: () => ...),
          IconButton(icon: Icon(Icons.settings), onPressed: () => ...),
        ],
      ),
      body: Consumer<DashboardController>(
        builder: (context, controller, _) {
          return Column(
            children: [
              // Selector de modo y planta
              Padding(
                padding: EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(child: ModoSelector()),
                    SizedBox(width: 16),
                    Expanded(child: PlantaSelector()),
                  ],
                ),
              ),
              
              // Tarjetas de sensores
              Expanded(
                child: Row(
                  children: [
                    Expanded(child: SensorCard(
                      titulo: 'Temperatura Aire',
                      valor: controller.currentData?.temperaturaAire,
                      unidad: '°C',
                      icono: Icons.thermostat,
                    )),
                    Expanded(child: SensorCard(...)),
                    Expanded(child: SensorCard(...)),
                  ],
                ),
              ),
              
              // Gráfico de tendencias
              Expanded(
                child: SensorChart(data: controller.historialData),
              ),
              
              // Controles manuales
              if (controller.esModoManual)
                Expanded(
                  child: Column(
                    children: [
                      VentiladorControl(),
                      RiegoControl(),
                      LuminosidadControl(),
                    ],
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}
```

### 2. Widgets Reutilizables

#### SensorCard ⭐ NUEVO
```dart
class SensorCard extends StatelessWidget {
  final String titulo;
  final double? valor;
  final String unidad;
  final IconData icono;
  final Color? color;
  
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Icon(icono, size: 32, color: color),
            SizedBox(height: 8),
            Text(titulo),
            SizedBox(height: 8),
            Text(
              valor != null ? '${valor!.toStringAsFixed(1)} $unidad' : '--',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
```

#### PlantaSelector ⭐ NUEVO
```dart
class PlantaSelector extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardController>(
      builder: (context, controller, _) {
        return DropdownButtonFormField<TipoPlanta>(
          value: controller.plantaActual,
          decoration: InputDecoration(
            labelText: 'Tipo de Planta',
            prefixIcon: Icon(Icons.eco),
            border: OutlineInputBorder(),
          ),
          items: TipoPlanta.values.map((tipo) {
            return DropdownMenuItem(
              value: tipo,
              child: Text(PlantaModel.getDefault(tipo).nombre),
            );
          }).toList(),
          onChanged: (tipo) {
            if (tipo != null) {
              controller.cambiarPlanta(tipo);
            }
          },
        );
      },
    );
  }
}
```

#### VentiladorControl ⭐ NUEVO
```dart
class VentiladorControl extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardController>(
      builder: (context, controller, _) {
        return Card(
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              children: [
                Row(
                  children: [
                    Icon(Icons.air, size: 32),
                    SizedBox(width: 16),
                    Text('Control de Ventilador'),
                  ],
                ),
                SizedBox(height: 16),
                Slider(
                  value: controller.velocidadVentilador,
                  min: 0,
                  max: 100,
                  divisions: 10,
                  label: '${controller.velocidadVentilador.toStringAsFixed(0)}%',
                  onChanged: (value) {
                    controller.controlarVentilador(value);
                  },
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
```

#### RiegoControl ⭐ NUEVO
```dart
class RiegoControl extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Row(children: [
            Icon(Icons.water_drop),
            Text('Control de Riego'),
          ]),
          Row(
            children: [
              Expanded(
                child: TextField(
                  decoration: InputDecoration(
                    labelText: 'Duración (seg)',
                    border: OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                ),
              ),
              ElevatedButton(
                onPressed: () { /* Iniciar riego */ },
                child: Text('Regar'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
```

#### LuminosidadControl ⭐ NUEVO
```dart
class LuminosidadControl extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          Row(children: [
            Icon(Icons.lightbulb),
            Text('Intensidad Lumínica'),
          ]),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(5, (index) {
              final nivel = index + 1;
              return GestureDetector(
                onTap: () { /* Cambiar nivel */ },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: nivel <= /* nivel actual */ ? Colors.yellow : Colors.grey,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(Icons.lightbulb_outline),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}
```

---

## 🔗 Comunicación con Backend

### Opción 1: Firebase Real-time Database (Actual)
**Ventajas:**
- Tiempo real nativo
- Sincronización automática
- Escalamiento sencillo
- Gratis hasta cierto límite

**Desventajas:**
- Consultas complejas limitadas
- Menos flexible que REST

### Opción 2: REST API + WebSocket (Recomendado)
**Ventajas:**
- Control total
- Compatible con lógica difusa en Python/Node.js
- WebSocket para tiempo real
- Más flexible

**Desventajas:**
- Requiere servidor backend
- Más configuración

### Implementación REST con Dio

```dart
// lib/services/api_service.dart ⭐ NUEVO
import 'package:dio/dio.dart';

class ApiService {
  final Dio _dio;
  static const String baseUrl = 'https://tu-backend.com/api';
  
  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: Duration(seconds: 30),
    receiveTimeout: Duration(seconds: 30),
  ));
  
  // Endpoint: GET /sensores
  Future<SensorData> getSensorData(String userId) async {
    final response = await _dio.get('/sensores/$userId');
    return SensorData.fromJson(response.data);
  }
  
  // Endpoint: GET /sensores/historico
  Future<List<SensorData>> getHistorico(
    String userId,
    DateTime inicio,
    DateTime fin,
  ) async {
    final response = await _dio.get('/sensores/$userId/historico', queryParameters: {
      'inicio': inicio.toIso8601String(),
      'fin': fin.toIso8601String(),
    });
    return (response.data as List).map((json) => SensorData.fromJson(json)).toList();
  }
  
  // Endpoint: POST /dispositivos/ventilador
  Future<void> setVentilador(String userId, double velocidad) async {
    await _dio.post('/dispositivos/ventilador', data: {
      'userId': userId,
      'velocidad': velocidad,
    });
  }
  
  // Endpoint: POST /dispositivos/riego
  Future<void> iniciarRiego(String userId, int segundos) async {
    await _dio.post('/dispositivos/riego', data: {
      'userId': userId,
      'duracion': segundos,
    });
  }
  
  // Endpoint: POST /dispositivos/luminosidad
  Future<void> setLuminosidad(String userId, int nivel) async {
    await _dio.post('/dispositivos/luminosidad', data: {
      'userId': userId,
      'nivel': nivel,
    });
  }
}
```

### WebSocket para Tiempo Real

```dart
// lib/services/websocket_service.dart ⭐ NUEVO
import 'package:web_socket_channel/web_socket_channel.dart';

class WebSocketService {
  WebSocketChannel? _channel;
  Stream<SensorData>? _sensorStream;
  
  void connect(String userId) {
    final uri = Uri.parse('wss://tu-backend.com/ws/sensores/$userId');
    _channel = WebSocketChannel.connect(uri);
    
    _sensorStream = _channel!.stream.map((data) {
      final json = jsonDecode(data);
      return SensorData.fromJson(json);
    });
  }
  
  Stream<SensorData> get sensorStream => _sensorStream!;
  
  void disconnect() {
    _channel?.sink.close();
  }
}
```

---

## 📅 Plan de Implementación

### Fase 1: Modelos y Servicios (2-3 días)
- [x] Crear modelo `SensorData`
- [ ] Crear modelo `PlantaModel`
- [ ] Crear modelo `DispositivoControl`
- [ ] Crear modelo `ReporteModel`
- [ ] Crear `SensorService`
- [ ] Crear `DispositivoService`
- [ ] Crear `ReporteService`

### Fase 2: Controladores (2 días)
- [ ] Crear `SensorController`
- [ ] Crear `DashboardController`
- [ ] Crear `DispositivoController`
- [ ] Crear `ReporteController`
- [ ] Integrar con controladores existentes

### Fase 3: UI - Dashboard Mejorado (3-4 días)
- [ ] Renombrar/mejorar `home_view.dart` → `dashboard_view.dart`
- [ ] Crear `SensorCard` widget
- [ ] Crear `PlantaSelector` widget
- [ ] Crear `ModoSelector` widget
- [ ] Implementar controles manuales
- [ ] Mejorar gráficos con múltiples series

### Fase 4: UI - Controles Manuales (2 días)
- [ ] Crear `VentiladorControl`
- [ ] Crear `RiegoControl`
- [ ] Crear `LuminosidadControl`
- [ ] Integrar con Dashboard

### Fase 5: Reportes PDF (3-4 días)
- [ ] Agregar dependencia `pdf`, `pdf_chart` a `pubspec.yaml`
- [ ] Crear `PDFGenerator` util
- [ ] Crear `ReportesView`
- [ ] Implementar generación de reportes
- [ ] Implementar visualización/descarga

### Fase 6: Integración Backend (3-5 días)
- [ ] Agregar `dio` a `pubspec.yaml`
- [ ] Crear `ApiService`
- [ ] Implementar `WebSocketService` (opcional)
- [ ] Actualizar servicios para usar API REST
- [ ] Testing de integración

### Fase 7: Testing y Optimización (2-3 días)
- [ ] Testing unitario
- [ ] Testing de integración
- [ ] Optimización de rendimiento
- [ ] Corrección de bugs

**Total estimado: 15-23 días laborables**

---

## 🚀 Mejoras Propuestas

### 1. Arquitectura
- ✅ **Separación de responsabilidades**: Modelos, Servicios, Controladores, Vistas
- ✅ **Estado global**: Provider para datos compartidos, GetX para routing
- ✅ **Inyección de dependencias**: Pasar servicios a controladores via constructor

### 2. Performance
- **Streams eficientes**: Usar `StreamBuilder` solo donde necesario
- **Caché local**: Implementar `shared_preferences` o `hive` para datos persistentes
- **Lazy loading**: Cargar reportes solo cuando se soliciten

### 3. UX/UI
- **Feedback visual**: Indicadores de carga, mensajes de éxito/error
- **Animaciones**: Transiciones suaves entre estados
- **Responsive**: Adaptar layout para tablets y pantallas grandes
- **Temas**: Modo oscuro/claro

### 4. Seguridad
- **Validación**: Validar inputs del usuario
- **Autenticación**: JWT tokens con refresh
- **Permisos**: Roles (admin vs usuario)

### 5. Monitoreo
- **Logging**: Logs estructurados
- **Analytics**: Firebase Analytics
- **Crashlytics**: Firebase Crashlytics

### 6. Escalabilidad
- **Paginate**: Paginación en históricos largos
- **Offline-first**: Soporte offline con sincronización
- **Múltiples invernaderos**: Permitir gestionar varios invernaderos por usuario

---

## 📦 Dependencias Adicionales Necesarias

```yaml
dependencies:
  # Ya presentes
  flutter: sdk
  provider: ^6.1.0
  http: ^1.2.0
  firebase_core: ^3.6.0
  cloud_firestore: ^5.4.4
  firebase_auth: ^5.3.1
  get: ^4.6.6
  fl_chart: ^0.68.0
  
  # Agregar para funcionalidades faltantes
  dio: ^5.4.0              # ⭐ HTTP client avanzado
  web_socket_channel: ^2.4.0 # ⭐ WebSocket para tiempo real
  pdf: ^3.10.0             # ⭐ Generación PDF
  pdf_chart: ^0.1.0        # ⭐ Gráficas en PDF
  file_picker: ^6.0.0      # ⭐ Selección de archivos
  path_provider: ^2.1.0    # ⭐ Rutas de sistema de archivos
  shared_preferences: ^2.2.0 # ⭐ Persistencia local
  uuid: ^4.2.0             # ⭐ Generación de IDs únicos
  intl: ^0.18.0            # ⭐ Formateo de fechas/números
  syncfusion_flutter_charts: ^24.1.0 # ⭐ Gráficas avanzadas (alternativa)
```

---

## 🎓 Consideraciones Técnicas

### Lógica Difusa (Backend)
El frontend **NO** implementa la lógica difusa, solo:
1. Envía datos de sensores al backend
2. Recibe decisiones del backend (comandos de dispositivos)
3. Visualiza las decisiones en tiempo real
4. Permite override manual si el modo es Manual

### Flujo de Datos

#### Modo Automático:
```
Sensores IoT → Backend (Lógica Difusa) → Decisiones → Frontend (Visualización)
```

#### Modo Manual:
```
Usuario → Frontend → Backend → Dispositivos IoT → Sensores → Frontend
```

### Gestión de Estado
1. **Provider**: Para datos compartidos (sensores, config)
2. **GetX Controllers**: Para lógica y routing
3. **Local State**: Para componentes aislados

---

## 📝 Checklist de Implementación

### Mínimo Viable (MVP)
- [x] Login/Register
- [x] Dashboard básico
- [x] Control IA (3 modos)
- [ ] Sensores en tiempo real
- [ ] Control manual de dispositivos
- [ ] Selector de plantas
- [ ] Reportes básicos

### Funcionalidad Completa
- [ ] Reportes PDF avanzados
- [ ] Gráficas interactivas
- [ ] Notificaciones push
- [ ] Historial detallado
- [ ] Exportación de datos
- [ ] Múltiples invernaderos
- [ ] Roles y permisos

---

## 🔗 Referencias

- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [GetX Documentation](https://pub.dev/packages/get)
- [Firebase for Flutter](https://firebase.flutter.dev/)
- [FL Chart](https://pub.dev/packages/fl_chart)
- [Dio HTTP Client](https://pub.dev/packages/dio)

---

**Autor:** Sistema de Documentación Auto-generado  
**Fecha:** 2024  
**Versión:** 1.0.0
