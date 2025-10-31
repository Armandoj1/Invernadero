/// Modelo de datos para información de sensores del invernadero
class SensorData {
  final String id;
  final double temperaturaAire; // °C
  final double temperaturaSuelo; // °C
  final double humedadAire; // %
  final double humedadSuelo; // %
  final double luminosidad; // 0-100%
  final DateTime timestamp;

  SensorData({
    required this.id,
    required this.temperaturaAire,
    required this.temperaturaSuelo,
    required this.humedadAire,
    required this.humedadSuelo,
    required this.luminosidad,
    required this.timestamp,
  });

  /// Constructor desde JSON (Firestore, API REST, etc.)
  factory SensorData.fromJson(Map<String, dynamic> json) {
    final dynamic timestamp = json['timestamp'];
    DateTime fecha;
    
    if (timestamp is String) {
      fecha = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else if (timestamp is DateTime) {
      fecha = timestamp;
    } else {
      fecha = DateTime.now();
    }

    return SensorData(
      id: (json['id'] ?? '') as String,
      temperaturaAire: ((json['temperaturaAire'] ?? 0) as num).toDouble(),
      temperaturaSuelo: ((json['temperaturaSuelo'] ?? 0) as num).toDouble(),
      humedadAire: ((json['humedadAire'] ?? 0) as num).toDouble(),
      humedadSuelo: ((json['humedadSuelo'] ?? 0) as num).toDouble(),
      luminosidad: ((json['luminosidad'] ?? 0) as num).toDouble(),
      timestamp: fecha,
    );
  }

  /// Convertir a JSON para almacenamiento/enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'temperaturaAire': temperaturaAire,
      'temperaturaSuelo': temperaturaSuelo,
      'humedadAire': humedadAire,
      'humedadSuelo': humedadSuelo,
      'luminosidad': luminosidad,
      'timestamp': timestamp.toIso8601String(),
    };
  }

  /// Crear copia con valores modificados
  SensorData copyWith({
    String? id,
    double? temperaturaAire,
    double? temperaturaSuelo,
    double? humedadAire,
    double? humedadSuelo,
    double? luminosidad,
    DateTime? timestamp,
  }) {
    return SensorData(
      id: id ?? this.id,
      temperaturaAire: temperaturaAire ?? this.temperaturaAire,
      temperaturaSuelo: temperaturaSuelo ?? this.temperaturaSuelo,
      humedadAire: humedadAire ?? this.humedadAire,
      humedadSuelo: humedadSuelo ?? this.humedadSuelo,
      luminosidad: luminosidad ?? this.luminosidad,
      timestamp: timestamp ?? this.timestamp,
    );
  }

  @override
  String toString() {
    return 'SensorData(id: $id, tempAire: $temperaturaAire°C, humedadAire: $humedadAire%, timestamp: $timestamp)';
  }
}
