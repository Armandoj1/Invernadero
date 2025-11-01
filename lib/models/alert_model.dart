class AlertModel {
  final String id;
  final String userId;
  final String plantType;
  final String alertType; // 'temperature', 'humidity', 'soilMoisture', 'light'
  final String severity; // 'low', 'medium', 'high', 'critical'
  final String title;
  final String message;
  final double currentValue;
  final double minThreshold;
  final double maxThreshold;
  final DateTime timestamp;
  final bool isRead;
  final bool isAutomatic; // true si fue generada automáticamente

  AlertModel({
    required this.id,
    required this.userId,
    required this.plantType,
    required this.alertType,
    required this.severity,
    required this.title,
    required this.message,
    required this.currentValue,
    required this.minThreshold,
    required this.maxThreshold,
    required this.timestamp,
    this.isRead = false,
    this.isAutomatic = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'plantType': plantType,
      'alertType': alertType,
      'severity': severity,
      'title': title,
      'message': message,
      'currentValue': currentValue,
      'minThreshold': minThreshold,
      'maxThreshold': maxThreshold,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'isAutomatic': isAutomatic,
    };
  }

  factory AlertModel.fromJson(Map<String, dynamic> json) {
    return AlertModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      plantType: json['plantType'] ?? '',
      alertType: json['alertType'] ?? '',
      severity: json['severity'] ?? 'medium',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      currentValue: (json['currentValue'] ?? 0).toDouble(),
      minThreshold: (json['minThreshold'] ?? 0).toDouble(),
      maxThreshold: (json['maxThreshold'] ?? 0).toDouble(),
      timestamp: DateTime.parse(json['timestamp']),
      isRead: json['isRead'] ?? false,
      isAutomatic: json['isAutomatic'] ?? true,
    );
  }

  AlertModel copyWith({
    String? id,
    String? userId,
    String? plantType,
    String? alertType,
    String? severity,
    String? title,
    String? message,
    double? currentValue,
    double? minThreshold,
    double? maxThreshold,
    DateTime? timestamp,
    bool? isRead,
    bool? isAutomatic,
  }) {
    return AlertModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      plantType: plantType ?? this.plantType,
      alertType: alertType ?? this.alertType,
      severity: severity ?? this.severity,
      title: title ?? this.title,
      message: message ?? this.message,
      currentValue: currentValue ?? this.currentValue,
      minThreshold: minThreshold ?? this.minThreshold,
      maxThreshold: maxThreshold ?? this.maxThreshold,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      isAutomatic: isAutomatic ?? this.isAutomatic,
    );
  }
}
