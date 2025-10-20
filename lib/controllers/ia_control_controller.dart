import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:invernadero/controllers/auth_controller.dart';
import 'package:invernadero/models/ia_control.dart';
import 'package:invernadero/services/ia_control_service.dart';

class IAControlController extends ChangeNotifier {
  final IAControlService _service;

  IAControlModel? _control;
  bool _isLoading = false;
  String? _error;

  IAControlModel? get control => _control;
  bool get isLoading => _isLoading;
  String? get error => _error;

  IAControlController({required IAControlService service}) : _service = service;

  Future<void> load() async {
    final auth = Get.find<AuthController>();
    final uid = auth.user?.uid;
    if (uid == null) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final loaded = await _service.getControl(uid);
      if (loaded != null) {
        _control = loaded;
      } else {
        final rec = _recommendedForCultivo('Tomate');
        _control = IAControlModel(
          id: uid,
          cultivo: 'Tomate',
          modo: 'automatico',
          temperaturaObjetivo: rec[0],
          humedadObjetivo: rec[1],
          co2Objetivo: rec[2],
          ultimaActualizacion: DateTime.now(),
        );
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void setModo(String modo) {
    if (_control == null) return;
    final rec = _recommendedForCultivo(_control!.cultivo);
    final autoValues = IAControlModel(
      id: _control!.id,
      cultivo: _control!.cultivo,
      modo: modo,
      temperaturaObjetivo: rec[0],
      humedadObjetivo: rec[1],
      co2Objetivo: rec[2],
      ultimaActualizacion: DateTime.now(),
    );

    switch (modo) {
      case 'automatico':
        _control = autoValues;
        break;
      case 'manual':
        _control = _control!.copyWith(modo: modo, ultimaActualizacion: DateTime.now());
        break;
      case 'hibrido':
        // En híbrido: temperatura y CO2 fijos recomendados; humedad ajustable
        _control = _control!.copyWith(
          modo: modo,
          temperaturaObjetivo: rec[0],
          co2Objetivo: rec[2],
          ultimaActualizacion: DateTime.now(),
        );
        break;
    }
    notifyListeners();
  }

  void updateTemperatura(double v) {
    if (_control == null) return;
    if (_control!.modo == 'automatico') return; // bloqueado
    if (_control!.modo == 'hibrido') return; // bloqueado en híbrido
    _control = _control!.copyWith(temperaturaObjetivo: v, ultimaActualizacion: DateTime.now());
    notifyListeners();
  }

  void updateHumedad(double v) {
    if (_control == null) return;
    if (_control!.modo == 'automatico') return; // bloqueado
    // híbrido permite humedad
    _control = _control!.copyWith(humedadObjetivo: v, ultimaActualizacion: DateTime.now());
    notifyListeners();
  }

  void updateCo2(double v) {
    if (_control == null) return;
    if (_control!.modo == 'automatico') return; // bloqueado
    if (_control!.modo == 'hibrido') return; // bloqueado en híbrido
    _control = _control!.copyWith(co2Objetivo: v, ultimaActualizacion: DateTime.now());
    notifyListeners();
  }

  Future<bool> save() async {
    final auth = Get.find<AuthController>();
    final uid = auth.user?.uid;
    if (_control == null || uid == null) return false;
    try {
      final ok = await _service.saveControl(uid, _control!);
      if (!ok) _error = 'No se pudo guardar configuración';
      return ok;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      notifyListeners();
    }
  }

  List<double> _recommendedForCultivo(String cultivo) {
    switch (cultivo.toLowerCase()) {
      case 'tomate':
        return [24.0, 70.0, 500.0];
      default:
        return [24.0, 70.0, 500.0];
    }
  }
}