import 'package:get/get.dart';
import '../services/alert_service.dart';
import 'auth_controller.dart';
import 'dart:async';

class AlertController extends GetxController {
  final AlertService _alertService = AlertService();
  final AuthController _authController = Get.find<AuthController>();

  StreamSubscription? _monitoringSubscription;
  final RxInt unreadCount = 0.obs;
  final RxString currentPlantType = 'Lechuga'.obs;

  @override
  void onInit() {
    super.onInit();
    _startMonitoring();
    _updateUnreadCount();
  }

  @override
  void onClose() {
    _monitoringSubscription?.cancel();
    super.onClose();
  }

  /// Iniciar monitoreo automático de sensores
  void _startMonitoring() {
    final userId = _authController.user?.uid;
    if (userId != null) {
      // Iniciar el monitoreo de sensores para generar alertas automáticas
      _monitoringSubscription = _alertService.startMonitoring(
        userId,
        currentPlantType.value,
      );
    }
  }

  /// Actualizar contador de alertas no leídas
  void _updateUnreadCount() {
    final userId = _authController.user?.uid;
    if (userId != null) {
      _alertService.getUnreadAlerts(userId).listen((alerts) {
        unreadCount.value = alerts.length;
      });
    }
  }

  /// Cambiar tipo de planta monitoreada
  void changePlantType(String plantType) {
    currentPlantType.value = plantType;
    _restartMonitoring();
  }

  /// Reiniciar el monitoreo con el nuevo tipo de planta
  void _restartMonitoring() {
    _monitoringSubscription?.cancel();
    _startMonitoring();
  }

  /// Marcar todas las alertas como leídas
  Future<void> markAllAsRead() async {
    final userId = _authController.user?.uid;
    if (userId != null) {
      await _alertService.markAllAsRead(userId);
    }
  }

  /// Eliminar todas las alertas
  Future<void> deleteAllAlerts() async {
    final userId = _authController.user?.uid;
    if (userId != null) {
      await _alertService.deleteAllAlerts(userId);
    }
  }
}
