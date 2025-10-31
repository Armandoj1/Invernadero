import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/planta_model.dart';
import '../controllers/auth_controller.dart';
import '../controllers/sensor_controller.dart';
import '../controllers/dispositivo_controller.dart';
import '../controllers/ia_control_controller.dart';

/// Controlador principal del Dashboard que coordina sensores, dispositivos y IA
class DashboardController extends ChangeNotifier {
  final SensorController _sensorController;
  final DispositivoController _dispositivoController;
  final IAControlController _iaController;

  TipoPlanta _plantaSeleccionada = TipoPlanta.tomate;
  bool _esModoManual = false;

  TipoPlanta get plantaSeleccionada => _plantaSeleccionada;
  PlantaModel get plantaActual => PlantaModel.getDefault(_plantaSeleccionada);
  bool get esModoManual => _esModoManual;
  
  // Delegados a controllers específicos
  bool get isLoading => _sensorController.isLoading || _dispositivoController.isLoading;
  String? get error => _sensorController.error ?? _dispositivoController.error;

  DashboardController({
    required SensorController sensorController,
    required DispositivoController dispositivoController,
    required IAControlController iaController,
  })  : _sensorController = sensorController,
        _dispositivoController = dispositivoController,
        _iaController = iaController {
    _init();
  }

  void _init() {
    // Escuchar cambios en el modo de IA
    _iaController.addListener(_actualizarModoManual);
    _actualizarModoManual();
  }

  void _actualizarModoManual() {
    final modo = _iaController.control?.modo;
    _esModoManual = (modo == 'manual' || modo == 'hibrido');
    notifyListeners();
  }

  /// Cambiar tipo de planta
  Future<void> cambiarPlanta(TipoPlanta tipo) async {
    _plantaSeleccionada = tipo;
    notifyListeners();
  }

  /// Control de ventilador (verifica si está en modo manual)
  Future<bool> controlarVentilador(double velocidad) async {
    if (!_esModoManual) {
      Get.snackbar(
        'Modo Automático',
        'No se puede controlar manualmente en modo automático',
        backgroundColor: Colors.orange.shade100,
      );
      return false;
    }
    
    return await _dispositivoController.setVelocidadVentilador(velocidad);
  }

  /// Control de riego (verifica si está en modo manual)
  Future<bool> controlarRiego(int segundos) async {
    if (!_esModoManual) {
      Get.snackbar(
        'Modo Automático',
        'No se puede controlar manualmente en modo automático',
        backgroundColor: Colors.orange.shade100,
      );
      return false;
    }
    
    return await _dispositivoController.iniciarRiego(segundos);
  }

  /// Control de luminosidad (verifica si está en modo manual)
  Future<bool> controlarLuminosidad(int nivel) async {
    if (!_esModoManual) {
      Get.snackbar(
        'Modo Automático',
        'No se puede controlar manualmente en modo automático',
        backgroundColor: Colors.orange.shade100,
      );
      return false;
    }
    
    return await _dispositivoController.setIntensidadLuminosidad(nivel);
  }

  /// Apagar todos los dispositivos
  Future<bool> apagarTodos() async {
    return await _dispositivoController.apagarTodos();
  }

  /// Obtener datos actuales de sensores
  get currentSensorData => _sensorController.currentData;
  get historialSensorData => _sensorController.historialData;

  /// Delegar carga de datos
  Future<void> load() async {
    await Future.wait([
      _sensorController.load(),
      _dispositivoController.load(),
      _iaController.load(),
    ]);
  }

  /// Delegar streams
  Stream get sensorStream => _sensorController.getSensorStream();
  Stream get dispositivoStream => _dispositivoController.getDispositivosStream();

  /// Verificar si los parámetros actuales están óptimos para la planta seleccionada
  Map<String, bool> verificarParametrosOptimos() {
    final datos = _sensorController.currentData;
    if (datos == null) {
      return {
        'temperatura': false,
        'humedadAire': false,
        'humedadSuelo': false,
        'luminosidad': false,
      };
    }
    
    return plantaActual.verificarParametros(datos);
  }

  /// Obtener mensaje de alerta si hay parámetros fuera de rango
  String? getMensajeAlerta() {
    final verificacion = verificarParametrosOptimos();
    final alertas = <String>[];
    
    if (!verificacion['temperatura']!) {
      alertas.add('Temperatura fuera de rango óptimo');
    }
    if (!verificacion['humedadAire']!) {
      alertas.add('Humedad del aire fuera de rango óptimo');
    }
    if (!verificacion['humedadSuelo']!) {
      alertas.add('Humedad del suelo fuera de rango óptimo');
    }
    if (!verificacion['luminosidad']!) {
      alertas.add('Luminosidad insuficiente');
    }
    
    if (alertas.isEmpty) return null;
    return alertas.join('\n');
  }

  @override
  void dispose() {
    _iaController.removeListener(_actualizarModoManual);
    super.dispose();
  }
}

