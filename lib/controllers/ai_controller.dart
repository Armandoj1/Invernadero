import 'package:get/get.dart';
import '../models/chat_message.dart';
import '../models/sensor_data.dart';
import '../models/device_state.dart';
import '../services/gemini_service.dart';
import '../services/firebase_service.dart';
import '../services/device_control_service.dart';
import 'auth_controller.dart';

class AIController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final GeminiService _geminiService = GeminiService();
  final DeviceControlService _deviceControlService = DeviceControlService();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<ChatMessage> messages = <ChatMessage>[].obs;
  final RxBool isLoading = false.obs;
  final RxBool isInitialized = false.obs;
  final RxString currentPlantType = 'Lechuga'.obs;

  SensorData? _lastSensorData;
  DeviceState? _lastDeviceState;

  @override
  void onInit() {
    super.onInit();
    _initializeAI();
  }

  Future<void> _initializeAI() async {
    try {
      isLoading.value = true;

      // Obtener el tipo de planta seleccionada
      final userId = _authController.user?.uid;
      if (userId != null) {
        // Escuchar cambios en el tipo de planta
        _firebaseService.getSelectedPlantType(userId).listen((plantType) {
          currentPlantType.value = plantType;
        });

        // Obtener datos actuales de sensores desde RTDB
        _firebaseService.getRtdbHistorical().listen((dataList) {
          if (dataList.isNotEmpty) {
            final lastData = dataList.last;

            _lastSensorData = SensorData(
              temperature: (lastData['temperatura'] ?? 0).toDouble(),
              humidity: (lastData['humedad_aire'] ?? 0).toDouble(),
              soilMoisture: (lastData['humedad_suelo'] ?? 0).toDouble(),
              light: (lastData['luz'] ?? 0).toDouble(),
              timestamp: DateTime.now(),
              userId: userId,
              plantType: lastData['planta'] ?? currentPlantType.value,
            );
          }
        });

        // Obtener estado actual de dispositivos
        _firebaseService.getCurrentDeviceState(userId).listen((deviceState) {
          _lastDeviceState = deviceState;
        });
      }

      // Esperar un momento para que se carguen los datos
      await Future.delayed(const Duration(seconds: 1));

      // Inicializar el chat con contexto
      await _geminiService.initializeChat(
        currentSensors: _lastSensorData,
        currentDevices: _lastDeviceState,
        plantType: currentPlantType.value,
      );

      // Agregar mensaje de bienvenida
      _addMessage(
        'Hola! Soy tu asistente de invernadero inteligente. '
        'Puedo ayudarte con preguntas sobre:\n\n'
        '* Condiciones actuales de tu ${currentPlantType.value}\n'
        '* Recomendaciones de cultivo\n'
        '* Optimización de temperatura, humedad y riego\n'
        '* Solución de problemas\n\n'
        '¿En qué puedo ayudarte?',
        isUser: false,
      );

      isInitialized.value = true;
    } catch (e) {
      // Evitar print en producción, pero útil para debug
      _addMessage(
        'Error al inicializar el asistente. Por favor, verifica la configuración de la API Key.',
        isUser: false,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // Agregar mensaje del usuario
    _addMessage(text, isUser: true);

    isLoading.value = true;

    try {
      final userId = _authController.user?.uid ?? '';

      // Enviar mensaje a la IA
      final response = await _geminiService.sendMessage(text);

      // Procesar comandos de control de dispositivos en la respuesta de la IA
      final deviceCommands = await _deviceControlService.processAICommand(response, userId);

      // Agregar respuesta de la IA + confirmación de comandos ejecutados
      _addMessage(response + deviceCommands, isUser: false);
    } catch (e) {
      _addMessage(
        'Lo siento, ocurrió un error al procesar tu mensaje. Intenta nuevamente.',
        isUser: false,
      );
    } finally {
      isLoading.value = false;
    }
  }

  void _addMessage(String text, {required bool isUser}) {
    final message = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      message: text,
      isUser: isUser,
      timestamp: DateTime.now(),
    );
    messages.add(message);
  }

  void clearChat() {
    messages.clear();
    _initializeAI();
  }

  Future<void> refreshContext() async {
    isLoading.value = true;
    try {
      final userId = _authController.user?.uid;
      if (userId != null) {
        // Obtener el primer valor del stream
        final deviceState = await _firebaseService.getCurrentDeviceState(userId).first;
        _lastDeviceState = deviceState;

        final dataList = await _firebaseService.getRtdbHistorical().first;
        if (dataList.isNotEmpty) {
          final lastData = dataList.last;
          _lastSensorData = SensorData(
            temperature: (lastData['temperatura'] ?? 0).toDouble(),
            humidity: (lastData['humedad_aire'] ?? 0).toDouble(),
            soilMoisture: (lastData['humedad_suelo'] ?? 0).toDouble(),
            light: (lastData['luz'] ?? 0).toDouble(),
            timestamp: DateTime.now(),
            userId: userId,
            plantType: lastData['planta'] ?? currentPlantType.value,
          );
        }
      }

      await _geminiService.updateContext(
        currentSensors: _lastSensorData,
        currentDevices: _lastDeviceState,
        plantType: currentPlantType.value,
      );

      _addMessage(
        'Contexto actualizado con los datos más recientes del invernadero.',
        isUser: false,
      );
    } catch (e) {
      _addMessage(
        'Error al actualizar el contexto. Intenta nuevamente.',
        isUser: false,
      );
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> generateReport() async {
    isLoading.value = true;
    try {
      final userId = _authController.user?.uid;
      if (userId == null) {
        _addMessage(
          'Error: No se pudo identificar al usuario.',
          isUser: false,
        );
        return;
      }

      // Obtener datos históricos
      List<SensorData>? historicalData;
      try {
        historicalData = await _firebaseService.getSensorHistory(userId, limit: 50);
      } catch (e) {
        // Si falla, continuar sin datos históricos
        historicalData = null;
      }

      // Actualizar datos actuales
      final deviceState = await _firebaseService.getCurrentDeviceState(userId).first;
      _lastDeviceState = deviceState;

      final dataList = await _firebaseService.getRtdbHistorical().first;
      if (dataList.isNotEmpty) {
        final lastData = dataList.last;
        _lastSensorData = SensorData(
          temperature: (lastData['temperatura'] ?? 0).toDouble(),
          humidity: (lastData['humedad_aire'] ?? 0).toDouble(),
          soilMoisture: (lastData['humedad_suelo'] ?? 0).toDouble(),
          light: (lastData['luz'] ?? 0).toDouble(),
          timestamp: DateTime.now(),
          userId: userId,
          plantType: lastData['planta'] ?? currentPlantType.value,
        );
      }

      _addMessage(
        'Generando reporte detallado del invernadero...',
        isUser: false,
      );

      // Generar reporte con la IA
      final report = await _geminiService.generateReport(
        currentSensors: _lastSensorData,
        currentDevices: _lastDeviceState,
        plantType: currentPlantType.value,
        historicalData: historicalData,
      );

      _addMessage(report, isUser: false);
    } catch (e) {
      _addMessage(
        'Error al generar el reporte. Intenta nuevamente.',
        isUser: false,
      );
    } finally {
      isLoading.value = false;
    }
  }
}
