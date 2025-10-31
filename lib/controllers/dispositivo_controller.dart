import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/dispositivo_control.dart';
import '../services/dispositivo_service.dart';
import '../controllers/auth_controller.dart';

/// Controlador para gestionar control de dispositivos
class DispositivoController extends ChangeNotifier {
  final DispositivoService _dispositivoService = DispositivoService();

  DispositivoControl? _controlActual;
  bool _isLoading = false;
  String? _error;

  DispositivoControl? get controlActual => _controlActual;
  bool get isLoading => _isLoading;
  String? get error => _error;

  // Valores actuales
  double get velocidadVentilador => _controlActual?.velocidadVentilador ?? 0;
  int get duracionRiego => _controlActual?.duracionRiego ?? 0;
  int get intensidadLuminosidad => _controlActual?.intensidadLuminosidad ?? 1;

  /// Cargar estado actual de dispositivos
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
      _controlActual = await _dispositivoService.getEstadoDispositivos(uid);
      // Si no hay datos, crear estado simulado
      if (_controlActual == null) {
        _controlActual = DispositivoControl(
          id: uid,
          velocidadVentilador: 0,
          duracionRiego: 0,
          intensidadLuminosidad: 3,
          ultimaActualizacion: DateTime.now(),
          usuarioId: uid,
        );
      }
    } catch (e) {
      // Si hay error, usar datos simulados
      _controlActual = DispositivoControl(
        id: uid,
        velocidadVentilador: 0,
        duracionRiego: 0,
        intensidadLuminosidad: 3,
        ultimaActualizacion: DateTime.now(),
        usuarioId: uid,
      );
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// Actualizar velocidad del ventilador
  Future<bool> setVelocidadVentilador(double velocidad) async {
    final auth = Get.find<AuthController>();
    final uid = auth.user?.uid;
    
    if (uid == null) return false;

    try {
      // Intentar actualizar en Firestore
      final exitoso = await _dispositivoService.setVelocidadVentilador(uid, velocidad);
      
      // Actualizar localmente de todas formas (modo simulación)
      _controlActual = _controlActual?.copyWith(
        velocidadVentilador: velocidad,
        ultimaActualizacion: DateTime.now(),
      );
      notifyListeners();
      
      return exitoso;
    } catch (e) {
      // Si falla, actualizar localmente de todas formas
      _controlActual = _controlActual?.copyWith(
        velocidadVentilador: velocidad,
        ultimaActualizacion: DateTime.now(),
      );
      notifyListeners();
      return true; // Retornar true para simulación
    }
  }

  /// Iniciar riego con duración específica
  Future<bool> iniciarRiego(int segundos) async {
    final auth = Get.find<AuthController>();
    final uid = auth.user?.uid;
    
    if (uid == null) return false;

    try {
      // Intentar actualizar en Firestore
      final exitoso = await _dispositivoService.setDuracionRiego(uid, segundos);
      
      // Actualizar localmente de todas formas
      _controlActual = _controlActual?.copyWith(
        duracionRiego: segundos,
        ultimaActualizacion: DateTime.now(),
      );
      notifyListeners();
      
      return exitoso;
    } catch (e) {
      // Si falla, actualizar localmente
      _controlActual = _controlActual?.copyWith(
        duracionRiego: segundos,
        ultimaActualizacion: DateTime.now(),
      );
      notifyListeners();
      return true;
    }
  }

  /// Establecer intensidad de luminosidad
  Future<bool> setIntensidadLuminosidad(int nivel) async {
    final auth = Get.find<AuthController>();
    final uid = auth.user?.uid;
    
    if (uid == null) return false;

    try {
      // Intentar actualizar en Firestore
      final exitoso = await _dispositivoService.setIntensidadLuminosidad(uid, nivel);
      
      // Actualizar localmente de todas formas
      _controlActual = _controlActual?.copyWith(
        intensidadLuminosidad: nivel,
        ultimaActualizacion: DateTime.now(),
      );
      notifyListeners();
      
      return exitoso;
    } catch (e) {
      // Si falla, actualizar localmente
      _controlActual = _controlActual?.copyWith(
        intensidadLuminosidad: nivel,
        ultimaActualizacion: DateTime.now(),
      );
      notifyListeners();
      return true;
    }
  }

  /// Apagar todos los dispositivos
  Future<bool> apagarTodos() async {
    final auth = Get.find<AuthController>();
    final uid = auth.user?.uid;
    
    if (uid == null) return false;

    try {
      final exitoso = await _dispositivoService.apagarTodos(uid);
      
      if (exitoso) {
        await load(); // Recargar estado
      }
      
      return exitoso;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  /// Obtener stream de cambios en dispositivos
  Stream<DispositivoControl?> getDispositivosStream() {
    final auth = Get.find<AuthController>();
    final uid = auth.user?.uid;
    
    if (uid == null) {
      return Stream.value(null);
    }

    return _dispositivoService.getDispositivosStream(uid);
  }

  /// Limpiar error
  void limpiarError() {
    _error = null;
    notifyListeners();
  }
}

