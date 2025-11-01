class SensorData {
  final double temperature;
  final double humidity;
  final double soilMoisture;
  final double light;
  final DateTime timestamp;
  final String userId;
  final String plantType;

  SensorData({
    required this.temperature,
    required this.humidity,
    required this.soilMoisture,
    required this.light,
    required this.timestamp,
    required this.userId,
    required this.plantType,
  });

  factory SensorData.fromJson(Map<String, dynamic> json) {
    return SensorData(
      temperature: (json['temperature'] ?? json['temperatura'] ?? 0).toDouble(),
      humidity: (json['humidity'] ?? json['humedad'] ?? json['humedad_aire'] ?? json['humedad_ambiental'] ?? 0).toDouble(),
      soilMoisture: (json['soilMoisture'] ?? json['humedad_suelo'] ?? 0).toDouble(),
      light: (json['light'] ?? json['luz'] ?? 0).toDouble(),
      timestamp: DateTime.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now(),
      userId: json['userId']?.toString() ?? 'unknown',
      plantType: json['plantType']?.toString() ?? 'Lechuga',
    );
  }

  // Mapea datos provenientes del RTDB con claves en español
  factory SensorData.fromRealtimeJson(Map<dynamic, dynamic> json, {required String userId, required String plantType}) {
    double _toDouble(dynamic v) {
      if (v == null) return 0.0;
      if (v is num) return v.toDouble();
      return double.tryParse(v.toString()) ?? 0.0;
    }

    return SensorData(
      temperature: _toDouble(json['temperatura']),
      humidity: _toDouble(json['humedad_aire'] ?? json['humedad_ambiental']),
      soilMoisture: _toDouble(json['humedad_suelo']),
      light: _toDouble(json['luz']),
      timestamp: DateTime.fromMillisecondsSinceEpoch(int.tryParse(json['timestamp']?.toString() ?? '') ?? DateTime.now().millisecondsSinceEpoch),
      userId: userId,
      plantType: plantType,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature': temperature,
      'humidity': humidity,
      'soilMoisture': soilMoisture,
      'light': light,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
      'plantType': plantType,
    };
  }
}