# 📖 Guía de Implementación - Sistema Invernadero

## 🎯 Objetivo

Esta guía proporciona instrucciones paso a paso para completar la implementación del sistema de control de invernadero en Flutter, siguiendo la arquitectura documentada en `ARQUITECTURA.md`.

---

## 📋 Prerrequisitos

### Software Requerido
- ✅ Flutter SDK 3.9.0 o superior
- ✅ Dart SDK 3.9.0 o superior
- ✅ Firebase CLI
- ✅ Editor de código (VS Code / Android Studio / Cursor)

### Cuentas y Servicios
- ✅ Firebase Project configurado
- ✅ Backend REST API (Python/Node.js) para lógica difusa
- ✅ Git para control de versiones

---

## 🚀 Paso 1: Configuración Inicial

### 1.1 Actualizar Dependencias

```bash
# En la raíz del proyecto
flutter pub get
```

Esto instalará las dependencias adicionales:
- `dio` - Cliente HTTP avanzado
- `web_socket_channel` - WebSocket para tiempo real
- `pdf` - Generación de PDFs
- `path_provider` - Rutas de archivos
- `shared_preferences` - Persistencia local
- `uuid` - IDs únicos
- `intl` - Formateo

### 1.2 Verificar Estructura de Carpetas

Asegúrate de que la estructura de carpetas sea:

```
lib/
├── models/
│   ├── sensor_data.dart          ✅ CREADO
│   ├── planta_model.dart         ✅ CREADO
│   ├── dispositivo_control.dart  ✅ CREADO
│   ├── reporte_model.dart        ✅ CREADO
│   ├── user_model.dart           ✅ EXISTE
│   ├── ia_control.dart           ✅ EXISTE
│   └── perfil.dart               ✅ EXISTE
├── services/
│   ├── sensor_service.dart       ✅ CREADO
│   ├── dispositivo_service.dart  ✅ CREADO
│   ├── reporte_service.dart      ✅ CREADO
│   ├── ia_control_service.dart   ✅ EXISTE
│   └── perfilservices.dart       ✅ EXISTE
├── controllers/
│   ├── sensor_controller.dart    ✅ CREADO
│   ├── dispositivo_controller.dart ✅ CREADO
│   ├── dashboard_controller.dart ✅ CREADO
│   ├── auth_controller.dart      ✅ EXISTE
│   ├── ia_control_controller.dart ✅ EXISTE
│   └── perfilcontrollers.dart    ✅ EXISTE
├── ui/
│   ├── widgets/
│   │   ├── sensor_card.dart      ✅ CREADO
│   │   ├── planta_selector.dart  ✅ CREADO
│   │   ├── modo_selector.dart    ✅ CREADO
│   │   ├── ventilador_control.dart ✅ CREADO
│   │   ├── riego_control.dart    ✅ CREADO
│   │   └── luminosidad_control.dart ✅ CREADO
│   └── home/
│       └── home_view.dart        ✅ EXISTE (mejorar)
```

---

## 🔧 Paso 2: Registrar Controladores en main.dart

Modifica `lib/main.dart` para registrar los nuevos controladores:

```dart
// En la sección MultiProvider
MultiProvider(
  providers: [
    // ... Providers existentes
    
    // Agregar controladores nuevos
    ChangeNotifierProvider<SensorController>(
      create: (_) => SensorController(),
    ),
    ChangeNotifierProvider<DispositivoController>(
      create: (_) => DispositivoController(),
    ),
    ChangeNotifierProvider<DashboardController>(
      create: (context) => DashboardController(
        sensorController: context.read<SensorController>(),
        dispositivoController: context.read<DispositivoController>(),
        iaController: context.read<IAControlController>(),
      ),
    ),
  ],
  child: GetMaterialApp(...),
)
```

---

## 🎨 Paso 3: Crear Dashboard Mejorado

### 3.1 Crear Nueva Vista

Crear archivo `lib/ui/home/dashboard_completo.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import '../../controllers/dashboard_controller.dart';
import '../../controllers/auth_controller.dart';
import '../../ui/widgets/sensor_card.dart';
import '../../ui/widgets/planta_selector.dart';
import '../../ui/widgets/modo_selector.dart';
import '../../ui/widgets/ventilador_control.dart';
import '../../ui/widgets/riego_control.dart';
import '../../ui/widgets/luminosidad_control.dart';
import 'package:fl_chart/fl_chart.dart';

class DashboardCompletoView extends StatefulWidget {
  const DashboardCompletoView({super.key});

  @override
  State<DashboardCompletoView> createState() => _DashboardCompletoViewState();
}

class _DashboardCompletoViewState extends State<DashboardCompletoView> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<DashboardController>();
      controller.load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text(
          'Invernadero Control',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: const Color(0xFF1565C0),
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.report),
            onPressed: () => Get.toNamed('/reportes'),
            tooltip: 'Reportes',
          ),
          IconButton(
            icon: const Icon(Icons.account_circle),
            onPressed: () => Get.toNamed('/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authController.signOut();
              Get.offAllNamed('/login');
            },
          ),
        ],
      ),
      body: Consumer<DashboardController>(
        builder: (context, controller, _) {
          if (controller.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Selector de modo y planta
                Row(
                  children: const [
                    Expanded(child: ModoSelector()),
                    SizedBox(width: 8),
                    Expanded(child: PlantaSelector()),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Tarjetas de sensores
                const Text(
                  'Sensores en Tiempo Real',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                _buildSensoresGrid(context, controller),
                const SizedBox(height: 24),
                
                // Gráfico de tendencias
                _buildTendenciasChart(context, controller),
                const SizedBox(height: 24),
                
                // Controles manuales (solo si está en modo manual)
                if (controller.esModoManual) ...[
                  const Text(
                    'Control Manual de Dispositivos',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const VentiladorControl(),
                  const SizedBox(height: 16),
                  const RiegoControl(),
                  const SizedBox(height: 16),
                  const LuminosidadControl(),
                ],
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildSensoresGrid(BuildContext context, DashboardController controller) {
    final sensor = controller.currentSensorData;
    
    return Row(
      children: [
        Expanded(
          child: SensorCard(
            titulo: 'Temperatura Aire',
            valor: sensor?.temperaturaAire,
            unidad: '°C',
            icono: Icons.thermostat,
            color: Colors.red,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: SensorCard(
            titulo: 'Humedad Aire',
            valor: sensor?.humedadAire,
            unidad: '%',
            icono: Icons.water_drop,
            color: Colors.blue,
          ),
        ),
      ],
    );
  }

  Widget _buildTendenciasChart(BuildContext context, DashboardController controller) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Tendencia de Sensores (últimas horas)',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 200,
              child: _buildLineChart(controller.historialSensorData),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLineChart(List historial) {
    if (historial.isEmpty) {
      return const Center(child: Text('No hay datos disponibles'));
    }

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: true),
        titlesData: FlTitlesData(show: true),
        borderData: FlBorderData(show: true),
        lineBarsData: [
          LineChartBarData(
            spots: historial.asMap().entries.map((e) {
              return FlSpot(
                e.key.toDouble(),
                (e.value as dynamic).temperaturaAire,
              );
            }).toList(),
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}
```

### 3.2 Agregar Ruta

En `lib/main.dart`, agregar:

```dart
GetPage(
  name: '/dashboard-completo',
  page: () => const DashboardCompletoView(),
),
```

---

## 🔗 Paso 4: Integrar con Backend REST API

### 4.1 Crear Servicio API

Crear `lib/services/api_service.dart`:

```dart
import 'package:dio/dio.dart';
import '../models/sensor_data.dart';
import '../models/dispositivo_control.dart';

class ApiService {
  final Dio _dio;
  static const String baseUrl = 'https://tu-backend.com/api';
  
  ApiService() : _dio = Dio(BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 30),
    receiveTimeout: const Duration(seconds: 30),
    headers: {
      'Content-Type': 'application/json',
    },
  ));

  // Endpoint: GET /sensores/:userId
  Future<SensorData> getSensorData(String userId) async {
    final response = await _dio.get('/sensores/$userId');
    return SensorData.fromJson(response.data);
  }

  // Endpoint: GET /sensores/:userId/historico
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

  // Endpoint: GET /ia/decisión
  Future<DispositivoControl> getDecisionIA(String userId) async {
    final response = await _dio.get('/ia/decision/$userId');
    return DispositivoControl.fromJson(response.data);
  }
}
```

### 4.2 Actualizar Servicios Existentes

Modificar `sensor_service.dart` y `dispositivo_service.dart` para usar `ApiService` en lugar de solo Firestore:

```dart
// En sensor_service.dart
class SensorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ApiService _apiService = ApiService();

  // Usar API REST cuando esté disponible, sino Firestore
  Stream<SensorData?> getSensorDataStream(String userId) {
    return _firestore
        .collection('sensores')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return SensorData.fromJson(doc.data()!);
      }
      return null;
    });
  }
  
  // ...
}
```

---

## 📊 Paso 5: Implementar Reportes PDF

### 5.1 Instalar Dependencia

Ya agregado en `pubspec.yaml`:
```yaml
pdf: ^3.10.0
```

### 5.2 Crear Generador de PDF

Crear `lib/utils/pdf_generator.dart`:

```dart
import 'dart:typed_data';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import '../models/reporte_model.dart';
import '../models/planta_model.dart';
import 'intl.dart' as intl;

class PDFGenerator {
  static Future<Uint8List> generarReportePDF(
    ReporteModel reporte,
    PlantaModel planta,
  ) async {
    final pdf = pw.Document();

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(40),
        build: (context) => [
          // Encabezado
          pw.Header(
            level: 0,
            child: pw.Text(
              'Reporte de Invernadero',
              style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold),
            ),
          ),
          pw.SizedBox(height: 20),
          
          // Información general
          pw.Text(
            reporte.titulo,
            style: pw.TextStyle(fontSize: 16, fontWeight: pw.FontWeight.bold),
          ),
          pw.SizedBox(height: 10),
          pw.Text('Planta: ${planta.nombre}'),
          pw.Text('Período: ${intl.DateFormat('dd/MM/yyyy').format(reporte.fechaInicio)} - ${intl.DateFormat('dd/MM/yyyy').format(reporte.fechaFin)}'),
          pw.Text('Total lecturas: ${reporte.estadisticas.totalLecturas}'),
          pw.Divider(),
          
          // Estadísticas principales
          pw.Header(level: 1, child: pw.Text('Estadísticas Principales')),
          _buildEstadisticasTable(reporte),
          pw.SizedBox(height: 20),
          
          // Gráfica de tendencias (simplificada)
          pw.Header(level: 1, child: pw.Text('Tendencias de Temperatura')),
          _buildTemperaturaChart(reporte),
        ],
      ),
    );

    return pdf.save();
  }

  static pw.Widget _buildEstadisticasTable(ReporteModel reporte) {
    final stats = reporte.estadisticas;
    
    return pw.Table(
      border: pw.TableBorder.all(),
      children: [
        pw.TableRow(
          children: [
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Métrica', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Promedio', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Mínimo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.all(8),
              child: pw.Text('Máximo', style: pw.TextStyle(fontWeight: pw.FontWeight.bold)),
            ),
          ],
        ),
        _buildTableRow('Temp. Aire', '${stats.tempAirePromedio.toStringAsFixed(1)}°C', '${stats.tempAireMinima.toStringAsFixed(1)}°C', '${stats.tempAireMaxima.toStringAsFixed(1)}°C'),
        _buildTableRow('Temp. Suelo', '${stats.tempSueloPromedio.toStringAsFixed(1)}°C', '${stats.tempSueloMinima.toStringAsFixed(1)}°C', '${stats.tempSueloMaxima.toStringAsFixed(1)}°C'),
        _buildTableRow('Humedad Aire', '${stats.humedadAirePromedio.toStringAsFixed(1)}%', '-', '-'),
        _buildTableRow('Humedad Suelo', '${stats.humedadSueloPromedio.toStringAsFixed(1)}%', '-', '-'),
      ],
    );
  }

  static pw.TableRow _buildTableRow(String label, String promedio, String minimo, String maximo) {
    return pw.TableRow(
      children: [
        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(label)),
        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(promedio)),
        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(minimo)),
        pw.Padding(padding: const pw.EdgeInsets.all(8), child: pw.Text(maximo)),
      ],
    );
  }

  static pw.Widget _buildTemperaturaChart(ReporteModel reporte) {
    // Chart simplificado con barras
    return pw.Container(
      height: 200,
      child: pw.CustomPaint(
        painter: _SimpleBarChart(reporte.datos),
      ),
    );
  }
}

// Pintor simple para gráficas (implementar según necesidad)
class _SimpleBarChart extends pw.CustomPainter {
  final List datos;
  
  _SimpleBarChart(this.datos);
  
  @override
  void paint(pw.Canvas canvas, pw.Size size) {
    // Implementar dibujo de gráfica
  }
  
  @override
  bool shouldRepaint(_SimpleBarChart oldDelegate) => false;
}
```

### 5.3 Crear Vista de Reportes

Crear `lib/ui/home/reportes_view.dart`:

```dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../controllers/reporte_controller.dart';

class ReportesView extends StatelessWidget {
  const ReportesView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Reportes'),
        backgroundColor: const Color(0xFF1565C0),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildBotonReporte('Diario', PeriodoReporte.dia),
          _buildBotonReporte('Semanal', PeriodoReporte.semana),
          _buildBotonReporte('Mensual', PeriodoReporte.mes),
        ],
      ),
    );
  }

  Widget _buildBotonReporte(String titulo, PeriodoReporte periodo) {
    return Card(
      child: ListTile(
        title: Text('Reporte $titulo'),
        subtitle: Text('Generar reporte de ${titulo.toLowerCase()}'),
        trailing: const Icon(Icons.picture_as_pdf),
        onTap: () async {
          // Generar reporte
          final controller = Get.find<ReporteController>();
          final reporte = await controller.generarReporte(periodo);
          
          if (reporte != null) {
            // Mostrar éxito
            Get.snackbar('Éxito', 'Reporte generado');
            
            // Opcional: compartir o guardar PDF
          }
        },
      ),
    );
  }
}
```

---

## 🧪 Paso 6: Testing

### 6.1 Testing Manual

1. Ejecutar app: `flutter run`
2. Probar login/register
3. Navegar al dashboard
4. Cambiar modo (Auto/Manual/Híbrido)
5. Seleccionar planta
6. Controlar dispositivos en modo manual
7. Generar reportes

### 6.2 Testing de Integración

```bash
# En terminal separado, ejecutar backend de prueba
python backend/simulador_sensores.py
```

### 6.3 Flutter Test

```bash
# Ejecutar tests unitarios
flutter test

# Ejecutar tests de integración
flutter test integration_test/
```

---

## 🚨 Troubleshooting

### Problema: Firebase no conecta
**Solución:**
```bash
firebase login
flutterfire configure
```

### Problema: Error de dependencias
**Solución:**
```bash
flutter clean
flutter pub get
```

### Problema: Linter errors
**Solución:**
```bash
flutter analyze
dart fix --apply
```

---

## 📦 Deployment

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

---

## 📚 Recursos Adicionales

- [ARQUITECTURA.md](./ARQUITECTURA.md) - Documentación completa de arquitectura
- [Flutter Documentation](https://docs.flutter.dev/)
- [Provider Package](https://pub.dev/packages/provider)
- [GetX Documentation](https://pub.dev/packages/get)

---

## ✅ Checklist de Implementación

- [x] Análisis de arquitectura
- [x] Modelos de datos creados
- [x] Servicios implementados
- [x] Controladores creados
- [x] Widgets reutilizables
- [ ] Dashboard mejorado integrado
- [ ] Reportes PDF funcionando
- [ ] Backend REST conectado
- [ ] Testing completo
- [ ] Deployment

---

**Autor:** Sistema de Documentación  
**Versión:** 1.0.0  
**Última actualización:** 2024
