import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/alert_model.dart';
import '../models/plant_parameters.dart';
import 'firebase_service.dart';
import 'dart:async';

class AlertService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseService _firebaseService = FirebaseService();
  final String _alertsCollection = 'alerts';

  // Mapa para evitar duplicar alertas en poco tiempo
  final Map<String, DateTime> _lastAlertTime = {};
  final Duration _alertCooldown = const Duration(minutes: 30); // 30 min entre alertas del mismo tipo

  /// Iniciar monitoreo automático de sensores para un usuario
  StreamSubscription<List<Map<String, dynamic>>>? startMonitoring(String userId, String plantType) {
    return _firebaseService.getRtdbHistorical().listen((dataList) {
      if (dataList.isNotEmpty) {
        final latestData = dataList.last;
        _checkAndCreateAlerts(userId, plantType, latestData);
      }
    });
  }

  /// Verificar datos y crear alertas si es necesario
  Future<void> _checkAndCreateAlerts(
    String userId,
    String plantType,
    Map<String, dynamic> sensorData,
  ) async {
    final parameters = PlantParameters.getParameters(plantType);

    final temperature = (sensorData['temperatura'] ?? 0).toDouble();
    final humidity = (sensorData['humedad_aire'] ?? 0).toDouble();
    final soilMoisture = (sensorData['humedad_suelo'] ?? 0).toDouble();
    final light = (sensorData['luz'] ?? 0).toDouble();

    // Verificar temperatura
    if (!parameters.isTemperatureInRange(temperature)) {
      await _createAlertIfNeeded(
        userId: userId,
        plantType: plantType,
        alertType: 'temperature',
        currentValue: temperature,
        minThreshold: parameters.minTemperature,
        maxThreshold: parameters.maxTemperature,
      );
    }

    // Verificar humedad del aire
    if (!parameters.isHumidityInRange(humidity)) {
      await _createAlertIfNeeded(
        userId: userId,
        plantType: plantType,
        alertType: 'humidity',
        currentValue: humidity,
        minThreshold: parameters.minHumidity,
        maxThreshold: parameters.maxHumidity,
      );
    }

    // Verificar humedad del suelo
    if (!parameters.isSoilMoistureInRange(soilMoisture)) {
      await _createAlertIfNeeded(
        userId: userId,
        plantType: plantType,
        alertType: 'soilMoisture',
        currentValue: soilMoisture,
        minThreshold: parameters.minSoilMoisture,
        maxThreshold: parameters.maxSoilMoisture,
      );
    }

    // Verificar luz
    if (!parameters.isLightInRange(light)) {
      await _createAlertIfNeeded(
        userId: userId,
        plantType: plantType,
        alertType: 'light',
        currentValue: light,
        minThreshold: parameters.minLight,
        maxThreshold: parameters.maxLight,
      );
    }
  }

  /// Crear alerta si no existe una reciente del mismo tipo
  Future<void> _createAlertIfNeeded({
    required String userId,
    required String plantType,
    required String alertType,
    required double currentValue,
    required double minThreshold,
    required double maxThreshold,
  }) async {
    final alertKey = '$userId-$alertType';
    final now = DateTime.now();

    // Verificar si ya existe una alerta reciente del mismo tipo
    if (_lastAlertTime.containsKey(alertKey)) {
      final lastAlert = _lastAlertTime[alertKey]!;
      if (now.difference(lastAlert) < _alertCooldown) {
        return; // No crear alerta duplicada
      }
    }

    // Determinar severidad y mensaje
    final alertInfo = _getAlertInfo(alertType, currentValue, minThreshold, maxThreshold);

    // Crear la alerta
    final alert = AlertModel(
      id: now.millisecondsSinceEpoch.toString(),
      userId: userId,
      plantType: plantType,
      alertType: alertType,
      severity: alertInfo['severity'] ?? 'medium',
      title: alertInfo['title'] ?? 'Alerta de Sensor',
      message: alertInfo['message'] ?? 'Se detectó una anomalía en los sensores.',
      currentValue: currentValue,
      minThreshold: minThreshold,
      maxThreshold: maxThreshold,
      timestamp: now,
      isRead: false,
      isAutomatic: true,
    );

    // Guardar en Firebase
    await saveAlert(alert);

    // Actualizar tiempo de última alerta
    _lastAlertTime[alertKey] = now;
  }

  /// Obtener información de la alerta según el tipo y valor
  Map<String, String> _getAlertInfo(
    String alertType,
    double currentValue,
    double minThreshold,
    double maxThreshold,
  ) {
    String severity = 'medium';
    String title = 'Alerta';
    String message = 'Alerta de sensor';

    final isLow = currentValue < minThreshold;
    final deviation = isLow
        ? ((minThreshold - currentValue) / minThreshold * 100).abs()
        : ((currentValue - maxThreshold) / maxThreshold * 100).abs();

    // Determinar severidad según la desviación
    if (deviation > 30) {
      severity = 'critical';
    } else if (deviation > 20) {
      severity = 'high';
    } else if (deviation > 10) {
      severity = 'medium';
    } else {
      severity = 'low';
    }

    switch (alertType) {
      case 'temperature':
        title = isLow ? 'Temperatura Baja' : 'Temperatura Alta';
        message = 'La temperatura está en ${currentValue.toStringAsFixed(1)}°C. '
            'El rango óptimo es ${minThreshold.toStringAsFixed(0)}-${maxThreshold.toStringAsFixed(0)}°C. '
            '${isLow ? "Considera activar el calefactor." : "Considera activar el ventilador o abrir ventilación."}';
        break;

      case 'humidity':
        title = isLow ? 'Humedad del Aire Baja' : 'Humedad del Aire Alta';
        message = 'La humedad del aire está en ${currentValue.toStringAsFixed(1)}%. '
            'El rango óptimo es ${minThreshold.toStringAsFixed(0)}-${maxThreshold.toStringAsFixed(0)}%. '
            '${isLow ? "Considera usar humidificadores." : "Mejora la ventilación para reducir humedad."}';
        break;

      case 'soilMoisture':
        title = isLow ? 'Humedad del Suelo Baja' : 'Humedad del Suelo Alta';
        message = 'La humedad del suelo está en ${currentValue.toStringAsFixed(1)}%. '
            'El rango óptimo es ${minThreshold.toStringAsFixed(0)}-${maxThreshold.toStringAsFixed(0)}%. '
            '${isLow ? "Activa el sistema de riego." : "Reduce el riego para evitar encharcamiento."}';
        break;

      case 'light':
        title = isLow ? 'Iluminación Insuficiente' : 'Iluminación Excesiva';
        message = 'La luz está en ${currentValue.toStringAsFixed(0)} lux. '
            'El rango óptimo es ${minThreshold.toStringAsFixed(0)}-${maxThreshold.toStringAsFixed(0)} lux. '
            '${isLow ? "Enciende las luces de cultivo." : "Reduce la intensidad de las luces o usa sombra."}';
        break;

      default:
        title = 'Alerta de Sensor';
        message = 'Valor actual: ${currentValue.toStringAsFixed(1)}';
        severity = 'medium';
    }

    return {
      'severity': severity,
      'title': title,
      'message': message,
    };
  }

  /// Guardar alerta en Firebase
  Future<void> saveAlert(AlertModel alert) async {
    try {
      await _firestore.collection(_alertsCollection).doc(alert.id).set(alert.toJson());
    } catch (e) {
      // Error al guardar alerta
    }
  }

  /// Obtener alertas de un usuario
  Stream<List<AlertModel>> getAlerts(String userId) {
    return _firestore
        .collection(_alertsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AlertModel.fromJson(data);
      }).toList();
    });
  }

  /// Obtener solo alertas no leídas
  Stream<List<AlertModel>> getUnreadAlerts(String userId) {
    return _firestore
        .collection(_alertsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return AlertModel.fromJson(data);
      }).toList();
    });
  }

  /// Marcar alerta como leída
  Future<void> markAsRead(String alertId) async {
    try {
      await _firestore.collection(_alertsCollection).doc(alertId).update({
        'isRead': true,
      });
    } catch (e) {
      // Error al actualizar alerta
    }
  }

  /// Marcar todas las alertas como leídas
  Future<void> markAllAsRead(String userId) async {
    try {
      final alerts = await _firestore
          .collection(_alertsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in alerts.docs) {
        await doc.reference.update({'isRead': true});
      }
    } catch (e) {
      // Error al actualizar alertas
    }
  }

  /// Eliminar alerta
  Future<void> deleteAlert(String alertId) async {
    try {
      await _firestore.collection(_alertsCollection).doc(alertId).delete();
    } catch (e) {
      // Error al eliminar alerta
    }
  }

  /// Eliminar todas las alertas de un usuario
  Future<void> deleteAllAlerts(String userId) async {
    try {
      final alerts = await _firestore
          .collection(_alertsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in alerts.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      // Error al eliminar alertas
    }
  }
}
