class NotificationModel {
  final String id;
  final String userId;
  final String type; // 'alert', 'crop', 'system', 'ai'
  final String title;
  final String message;
  final String? iconType; // 'info', 'warning', 'success', 'error'
  final DateTime timestamp;
  final bool isRead;
  final Map<String, dynamic>? data; // Datos adicionales según el tipo

  NotificationModel({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.message,
    this.iconType,
    required this.timestamp,
    this.isRead = false,
    this.data,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'type': type,
      'title': title,
      'message': message,
      'iconType': iconType,
      'timestamp': timestamp.toIso8601String(),
      'isRead': isRead,
      'data': data,
    };
  }

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] ?? '',
      userId: json['userId'] ?? '',
      type: json['type'] ?? 'system',
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      iconType: json['iconType'],
      timestamp: json['timestamp'] is String
          ? DateTime.parse(json['timestamp'])
          : DateTime.now(),
      isRead: json['isRead'] ?? false,
      data: json['data'] as Map<String, dynamic>?,
    );
  }

  NotificationModel copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? message,
    String? iconType,
    DateTime? timestamp,
    bool? isRead,
    Map<String, dynamic>? data,
  }) {
    return NotificationModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      message: message ?? this.message,
      iconType: iconType ?? this.iconType,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      data: data ?? this.data,
    );
  }
}
