class DeviceState {
  final bool pumpActive;
  final bool fanActive;
  final bool lightsActive;
  final bool heaterActive;
  final int fanSpeed; // 0-100
  final int irrigationDurationSec; // duración de riego en segundos
  final int lightLevel; // 0-100
  final DateTime timestamp;
  final String userId;

  DeviceState({
    required this.pumpActive,
    required this.fanActive,
    required this.lightsActive,
    required this.heaterActive,
    required this.fanSpeed,
    required this.irrigationDurationSec,
    required this.lightLevel,
    required this.timestamp,
    required this.userId,
    });

  factory DeviceState.initial(String userId) {
    return DeviceState(
      pumpActive: false,
      fanActive: false,
      lightsActive: false,
      heaterActive: false,
      fanSpeed: 0,
      irrigationDurationSec: 0,
      lightLevel: 0,
      timestamp: DateTime.now(),
      userId: userId,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'pumpActive': pumpActive,
      'fanActive': fanActive,
      'lightsActive': lightsActive,
      'heaterActive': heaterActive,
      'fanSpeed': fanSpeed,
      'irrigationDurationSec': irrigationDurationSec,
      'lightLevel': lightLevel,
      'timestamp': timestamp.toIso8601String(),
      'userId': userId,
    };
  }

  factory DeviceState.fromJson(Map<String, dynamic> json) {
    return DeviceState(
      pumpActive: json['pumpActive'] ?? false,
      fanActive: json['fanActive'] ?? false,
      lightsActive: json['lightsActive'] ?? false,
      heaterActive: json['heaterActive'] ?? false,
      fanSpeed: json['fanSpeed'] ?? 0,
      irrigationDurationSec: json['irrigationDurationSec'] ?? 0,
      lightLevel: json['lightLevel'] ?? 0,
      timestamp: DateTime.parse(json['timestamp']),
      userId: json['userId'],
    );
  }

  DeviceState copyWith({
    bool? pumpActive,
    bool? fanActive,
    bool? lightsActive,
    bool? heaterActive,
    int? fanSpeed,
    int? irrigationDurationSec,
    int? lightLevel,
    DateTime? timestamp,
    String? userId,
  }) {
    return DeviceState(
      pumpActive: pumpActive ?? this.pumpActive,
      fanActive: fanActive ?? this.fanActive,
      lightsActive: lightsActive ?? this.lightsActive,
      heaterActive: heaterActive ?? this.heaterActive,
      fanSpeed: fanSpeed ?? this.fanSpeed,
      irrigationDurationSec: irrigationDurationSec ?? this.irrigationDurationSec,
      lightLevel: lightLevel ?? this.lightLevel,
      timestamp: timestamp ?? this.timestamp,
      userId: userId ?? this.userId,
    );
  }
}