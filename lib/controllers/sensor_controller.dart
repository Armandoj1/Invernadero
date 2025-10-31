import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/sensor_data.dart';
import '../services/sensor_service.dart';
import '../controllers/auth_controller.dart';

/// Controlador para gestionar datos de sensores
class SensorController extends ChangeNotifier {
  final SensorService _sensorService = SensorService();

  SensorData? _currentData;
  List<SensorData> _historialData = [];
  bool _isLoading = false;
  String? _error;

  SensorData? get currentData => _currentData;
  List<SensorData> get historialData => _historialData;
  bool get isLoading => _isLoading;
  String? get error => _error;

  /// Cargar datos actuales de sensores
  Future<void> load() async {
    final auth = Get.find<AuthController>();
    final uid = auth.user?.uid;
    
    if (uid == null) {
      _error = 'Usuario no autenticado';
      notifyListeners();
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Intentar cargar desde Firestore
      _historialData = await _sensorService.getUltimosDatos(uid, 50);
      
      // Si no hay datos, usar simulados
      if (_historialData.isEmpty) {
        _currentData = await _sensorService.getDatosSimulados();
        // Generar historial simulado
        final ahora = DateTime.now();
        _historialData = List.generate(50, (index) {
          return SensorData(
            id: 'sim-${ahora.millisecondsSinceEpoch + index}',
            temperaturaAire: 20 + (index % 10) + (ahora.hour < 12 ? 0 : 4),
            temperaturaSuelo: 18 + (index % 8) + (ahora.hour < 12 ? 0 : 3),
            humedadAire: 60 + (index % 20),
            humedadSuelo: 70 + (index % 15),
            luminosidad: (ahora.hour < 12 ? 60 : 80) + (index % 20),
            timestamp: ahora.subtract(Duration(minutes: 50 - index)),
          );
        });
        _error = '📡 Modo demostración: Mostrando datos simulados';
      } else {
        _currentData = _historialData.last;
      }
    } catch (e) {
      // Si hay error, usar datos simulados
      _currentData = await _sensorService.getDatosSimulados();
      _error = '📡 Modo demostración: Mostrando datos simulados';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Obtener stream de datos en tiempo real
  Stream<SensorData?> getSensorStream() {
    final auth = Get.find<AuthController>();
    final uid = auth.user?.uid;
    
    if (uid == null) {
      return Stream.value(null);
    }

    return _sensorService.getSensorDataStream(uid);
  }

  /// Suscribirse a datos en tiempo real
  void iniciarMonitoreo() {
    final auth = Get.find<AuthController>();
    final uid = auth.user?.uid;
    
    if (uid == null) return;

    _sensorService.getSensorDataStream(uid).listen((data) {
      if (data != null) {
        _currentData = data;
        
        // Agregar a historial (mantener máximo 100)
        _historialData.add(data);
        if (_historialData.length > 100) {
          _historialData.removeAt(0);
        }
        
        notifyListeners();
      }
    }, onError: (error) {
      _error = error.toString();
      notifyListeners();
    });
  }

  /// Actualizar datos manualmente (para testing/simulación)
  Future<void> actualizarDatosManual() async {
    final auth = Get.find<AuthController>();
    final uid = auth.user?.uid;
    
    if (uid == null) return;

    try {
      final simulados = await _sensorService.getDatosSimulados();
      await _sensorService.guardarLectura(uid, simulados);
      
      _currentData = simulados;
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  /// Obtener histórico para un rango de fechas
  Future<List<SensorData>> obtenerHistorico(
    DateTime inicio,
    DateTime fin,
  ) async {
    final auth = Get.find<AuthController>();
    final uid = auth.user?.uid;
    
    if (uid == null) return [];

    try {
      final datos = await _sensorService.getHistorico(uid, inicio, fin);
      return datos;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return [];
    }
  }

  /// Limpiar error
  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}

