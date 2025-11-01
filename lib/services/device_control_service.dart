import '../services/firebase_service.dart';
import '../models/device_state.dart';

/// Servicio para controlar dispositivos del invernadero mediante comandos de IA
class DeviceControlService {
  final FirebaseService _firebaseService = FirebaseService();

  /// Analiza un mensaje de la IA y ejecuta comandos de control de dispositivos
  Future<String> processAICommand(String aiMessage, String userId) async {
    final lowerMessage = aiMessage.toLowerCase();
    final commands = <String>[];

    try {
      // Obtener estado actual
      final currentState = await _firebaseService.getCurrentDeviceState(userId).first;
      DeviceState newState = currentState ?? DeviceState.initial(userId);

      // Detectar comandos de ventilador
      if (lowerMessage.contains('encender') && lowerMessage.contains('ventilador')) {
        newState = newState.copyWith(fanActive: true, timestamp: DateTime.now());
        commands.add('✅ Ventilador encendido');
      } else if (lowerMessage.contains('apagar') && lowerMessage.contains('ventilador')) {
        newState = newState.copyWith(fanActive: false, timestamp: DateTime.now());
        commands.add('✅ Ventilador apagado');
      }

      // Detectar comandos de bomba de riego
      if (lowerMessage.contains('encender') && (lowerMessage.contains('bomba') || lowerMessage.contains('riego'))) {
        newState = newState.copyWith(pumpActive: true, timestamp: DateTime.now());
        commands.add('✅ Bomba de riego activada');
      } else if (lowerMessage.contains('apagar') && (lowerMessage.contains('bomba') || lowerMessage.contains('riego'))) {
        newState = newState.copyWith(pumpActive: false, timestamp: DateTime.now());
        commands.add('✅ Bomba de riego desactivada');
      }

      // Detectar comandos de luces
      if (lowerMessage.contains('encender') && (lowerMessage.contains('luz') || lowerMessage.contains('luces'))) {
        newState = newState.copyWith(lightsActive: true, timestamp: DateTime.now());
        commands.add('✅ Luces encendidas');
      } else if (lowerMessage.contains('apagar') && (lowerMessage.contains('luz') || lowerMessage.contains('luces'))) {
        newState = newState.copyWith(lightsActive: false, timestamp: DateTime.now());
        commands.add('✅ Luces apagadas');
      }

      // Detectar comandos de calefactor
      if (lowerMessage.contains('encender') && (lowerMessage.contains('calefactor') || lowerMessage.contains('calefacción'))) {
        newState = newState.copyWith(heaterActive: true, timestamp: DateTime.now());
        commands.add('✅ Calefactor encendido');
      } else if (lowerMessage.contains('apagar') && (lowerMessage.contains('calefactor') || lowerMessage.contains('calefacción'))) {
        newState = newState.copyWith(heaterActive: false, timestamp: DateTime.now());
        commands.add('✅ Calefactor apagado');
      }

      // Detectar comandos de velocidad del ventilador
      final fanSpeedMatch = RegExp(r'ventilador.*?(\d+)\s*%').firstMatch(lowerMessage);
      if (fanSpeedMatch != null) {
        final speed = int.parse(fanSpeedMatch.group(1)!);
        newState = newState.copyWith(fanSpeed: speed.clamp(0, 100), fanActive: true, timestamp: DateTime.now());
        commands.add('✅ Velocidad del ventilador ajustada a $speed%');
      }

      // Detectar comandos de intensidad de luces
      final lightLevelMatch = RegExp(r'luz.*?(\d+)\s*%').firstMatch(lowerMessage);
      if (lightLevelMatch != null) {
        final level = int.parse(lightLevelMatch.group(1)!);
        newState = newState.copyWith(lightLevel: level.clamp(0, 100), lightsActive: true, timestamp: DateTime.now());
        commands.add('✅ Intensidad de luces ajustada a $level%');
      }

      // Guardar el nuevo estado si hubo comandos
      if (commands.isNotEmpty) {
        await _firebaseService.saveDeviceState(newState);
      }

      return commands.isEmpty ? '' : '\n\n${commands.join('\n')}';
    } catch (e) {
      return '\n\n⚠️ Error al ejecutar comando: $e';
    }
  }

  /// Verifica si un mensaje del usuario contiene una solicitud de control
  bool hasControlRequest(String userMessage) {
    final lower = userMessage.toLowerCase();

    // Palabras clave de control
    final controlKeywords = [
      'enciende', 'encender', 'activa', 'activar', 'prende', 'prender',
      'apaga', 'apagar', 'desactiva', 'desactivar',
      'ajusta', 'ajustar', 'configura', 'configurar',
      'sube', 'subir', 'baja', 'bajar',
    ];

    // Dispositivos
    final deviceKeywords = [
      'ventilador', 'bomba', 'riego', 'luz', 'luces',
      'calefactor', 'calefacción',
    ];

    final hasControlWord = controlKeywords.any((word) => lower.contains(word));
    final hasDeviceWord = deviceKeywords.any((word) => lower.contains(word));

    return hasControlWord && hasDeviceWord;
  }
}
