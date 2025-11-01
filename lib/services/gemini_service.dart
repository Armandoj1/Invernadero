import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/sensor_data.dart';
import '../models/device_state.dart';

class GeminiService {
  // API Key de Groq
  static const String _apiKey = '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';
  static const String _baseUrl = 'https://api.groq.com/openai/v1';

  final List<Map<String, String>> _chatHistory = [];
  String? _systemContext;

  /// Inicializa el chat con contexto del invernadero
  Future<void> initializeChat({
    SensorData? currentSensors,
    DeviceState? currentDevices,
    String? plantType,
  }) async {
    _chatHistory.clear();
    _systemContext = _buildContextPrompt(
      currentSensors,
      currentDevices,
      plantType,
    );
  }

  /// Construye el prompt de contexto para la IA
  String _buildContextPrompt(
    SensorData? sensors,
    DeviceState? devices,
    String? plantType,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('Eres un asistente experto en agricultura de invernaderos inteligentes. '
        'Tu función es ayudar al usuario a optimizar el cultivo de plantas, '
        'respondiendo preguntas sobre condiciones ambientales, recomendaciones de cultivo, '
        'y control de dispositivos del invernadero.');

    buffer.writeln('\nDatos actuales del invernadero:');

    if (plantType != null) {
      buffer.writeln('- Planta cultivada: $plantType');
    }

    if (sensors != null) {
      buffer.writeln('- Temperatura: ${sensors.temperature.toStringAsFixed(1)}°C');
      buffer.writeln('- Humedad del aire: ${sensors.humidity.toStringAsFixed(1)}%');
      buffer.writeln('- Humedad del suelo: ${sensors.soilMoisture.toStringAsFixed(1)}%');
      buffer.writeln('- Luz: ${sensors.light.toStringAsFixed(0)} lux');
    }

    if (devices != null) {
      buffer.writeln('\nEstado de dispositivos:');
      buffer.writeln('- Bomba de riego: ${devices.pumpActive ? "Encendida" : "Apagada"}');
      buffer.writeln('- Ventilador: ${devices.fanActive ? "Encendido (${devices.fanSpeed}%)" : "Apagado"}');
      buffer.writeln('- Luces: ${devices.lightsActive ? "Encendidas (${devices.lightLevel}%)" : "Apagadas"}');
      buffer.writeln('- Calefactor: ${devices.heaterActive ? "Encendido" : "Apagado"}');
    }

    buffer.writeln('\nRangos óptimos por tipo de planta:');
    buffer.writeln('Lechuga: Temperatura 15-20°C, Humedad aire 70-80%, Humedad suelo 60-80%, Luz 10000-15000 lux');
    buffer.writeln('Tomate: Temperatura 20-25°C, Humedad aire 60-70%, Humedad suelo 65-85%, Luz 15000-20000 lux');
    buffer.writeln('Fresa: Temperatura 18-24°C, Humedad aire 65-75%, Humedad suelo 60-75%, Luz 12000-18000 lux');
    buffer.writeln('Zanahoria: Temperatura 16-21°C, Humedad aire 60-70%, Humedad suelo 55-70%, Luz 8000-12000 lux');

    buffer.writeln('\nResponde en español de forma clara, concisa y práctica.');

    return buffer.toString();
  }

  /// Envía un mensaje al chat y obtiene la respuesta
  Future<String> sendMessage(String message) async {
    try {
      // Construir array de mensajes para Groq
      final messages = <Map<String, String>>[];

      // Agregar contexto del sistema
      if (_systemContext != null) {
        messages.add({
          'role': 'system',
          'content': _systemContext!,
        });
      }

      // Agregar historial previo
      for (final msg in _chatHistory) {
        messages.add({
          'role': msg['role'] == 'Usuario' ? 'user' : 'assistant',
          'content': msg['message']!,
        });
      }

      // Agregar mensaje actual del usuario
      messages.add({
        'role': 'user',
        'content': message,
      });

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': messages,
          'temperature': 0.7,
          'max_tokens': 500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choices = data['choices'] as List;

        if (choices.isNotEmpty) {
          final aiResponse = (choices[0]['message']['content'] as String).trim();

          // Guardar en el historial
          _chatHistory.add({
            'role': 'Usuario',
            'message': message,
          });
          _chatHistory.add({
            'role': 'Asistente',
            'message': aiResponse,
          });

          return aiResponse;
        }
        return 'No se pudo generar una respuesta.';
      } else {
        return 'Error: No se pudo obtener respuesta (${response.statusCode})';
      }
    } catch (e) {
      return 'Error al comunicarse con la IA: $e';
    }
  }

  /// Actualiza el contexto del chat con nuevos datos de sensores
  Future<void> updateContext({
    SensorData? currentSensors,
    DeviceState? currentDevices,
    String? plantType,
  }) async {
    _systemContext = _buildContextPrompt(
      currentSensors,
      currentDevices,
      plantType,
    );
  }

  /// Genera un reporte detallado del estado del invernadero
  Future<String> generateReport({
    required SensorData? currentSensors,
    required DeviceState? currentDevices,
    required String plantType,
    List<SensorData>? historicalData,
  }) async {
    try {
      final reportPrompt = _buildReportPrompt(
        currentSensors,
        currentDevices,
        plantType,
        historicalData,
      );

      final response = await http.post(
        Uri.parse('$_baseUrl/chat/completions'),
        headers: {
          'Authorization': 'Bearer $_apiKey',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'model': 'llama-3.3-70b-versatile',
          'messages': [
            {
              'role': 'user',
              'content': reportPrompt,
            }
          ],
          'temperature': 0.7,
          'max_tokens': 1500,
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final choices = data['choices'] as List;
        if (choices.isNotEmpty) {
          return (choices[0]['message']['content'] as String).trim();
        }
        return 'No se pudo generar el reporte.';
      } else {
        return 'Error al generar reporte (${response.statusCode})';
      }
    } catch (e) {
      return 'Error al generar el reporte: $e';
    }
  }

  /// Construye el prompt para generar un reporte
  String _buildReportPrompt(
    SensorData? sensors,
    DeviceState? devices,
    String plantType,
    List<SensorData>? historicalData,
  ) {
    final buffer = StringBuffer();

    buffer.writeln('Genera un reporte técnico detallado del invernadero inteligente.');
    buffer.writeln('El reporte debe incluir:');
    buffer.writeln('1. Resumen ejecutivo del estado actual');
    buffer.writeln('2. Análisis de condiciones ambientales');
    buffer.writeln('3. Comparación con parámetros óptimos');
    buffer.writeln('4. Tendencias (si hay datos históricos)');
    buffer.writeln('5. Recomendaciones de acción');
    buffer.writeln('6. Predicciones y alertas');
    buffer.writeln('\n--- DATOS DEL INVERNADERO ---');
    buffer.writeln('\nPlanta cultivada: $plantType');

    if (sensors != null) {
      buffer.writeln('\nCondiciones Actuales:');
      buffer.writeln('- Temperatura: ${sensors.temperature.toStringAsFixed(1)}°C');
      buffer.writeln('- Humedad del aire: ${sensors.humidity.toStringAsFixed(1)}%');
      buffer.writeln('- Humedad del suelo: ${sensors.soilMoisture.toStringAsFixed(1)}%');
      buffer.writeln('- Luz: ${sensors.light.toStringAsFixed(0)} lux');
    }

    if (devices != null) {
      buffer.writeln('\nEstado de Dispositivos:');
      buffer.writeln('- Bomba de riego: ${devices.pumpActive ? "Activa" : "Inactiva"}');
      buffer.writeln('- Ventilador: ${devices.fanActive ? "Activo (${devices.fanSpeed}%)" : "Inactivo"}');
      buffer.writeln('- Luces: ${devices.lightsActive ? "Encendidas (${devices.lightLevel}%)" : "Apagadas"}');
      buffer.writeln('- Calefactor: ${devices.heaterActive ? "Activo" : "Inactivo"}');
    }

    // Parámetros óptimos
    buffer.writeln('\nParámetros Óptimos para $plantType:');
    switch (plantType.toLowerCase()) {
      case 'lechuga':
        buffer.writeln('- Temperatura: 15-20°C, Humedad aire: 70-80%, Humedad suelo: 60-80%, Luz: 10000-15000 lux');
        break;
      case 'tomate':
        buffer.writeln('- Temperatura: 20-25°C, Humedad aire: 60-70%, Humedad suelo: 65-85%, Luz: 15000-20000 lux');
        break;
      case 'fresa':
        buffer.writeln('- Temperatura: 18-24°C, Humedad aire: 65-75%, Humedad suelo: 60-75%, Luz: 12000-18000 lux');
        break;
      case 'zanahoria':
        buffer.writeln('- Temperatura: 16-21°C, Humedad aire: 60-70%, Humedad suelo: 55-70%, Luz: 8000-12000 lux');
        break;
    }

    if (historicalData != null && historicalData.isNotEmpty) {
      buffer.writeln('\nDatos Históricos Disponibles: ${historicalData.length} lecturas recientes');

      double avgTemp = historicalData.map((e) => e.temperature).reduce((a, b) => a + b) / historicalData.length;
      double avgHum = historicalData.map((e) => e.humidity).reduce((a, b) => a + b) / historicalData.length;
      double avgSoil = historicalData.map((e) => e.soilMoisture).reduce((a, b) => a + b) / historicalData.length;

      buffer.writeln('- Temperatura promedio: ${avgTemp.toStringAsFixed(1)}°C');
      buffer.writeln('- Humedad aire promedio: ${avgHum.toStringAsFixed(1)}%');
      buffer.writeln('- Humedad suelo promedio: ${avgSoil.toStringAsFixed(1)}%');
    }

    buffer.writeln('\n--- FIN DE DATOS ---');
    buffer.writeln('\nGenera ahora un reporte profesional y accionable en español con formato claro.');

    return buffer.toString();
  }
}
