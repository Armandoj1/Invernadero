class Crop {
  final String id;
  final String userId;
  final String name;
  final String type; // Tipo de cultivo (lechuga, tomate, etc.)
  final DateTime plantedDate;
  final DateTime? harvestDate;
  final String status; // activo, cosechado, perdido
  final double? optimalTempMin;
  final double? optimalTempMax;
  final double? optimalHumidityMin;
  final double? optimalHumidityMax;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Crop({
    required this.id,
    required this.userId,
    required this.name,
    required this.type,
    required this.plantedDate,
    this.harvestDate,
    required this.status,
    this.optimalTempMin,
    this.optimalTempMax,
    this.optimalHumidityMin,
    this.optimalHumidityMax,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Crop.initial({
    required String userId,
    required String name,
    required String type,
    required DateTime plantedDate,
  }) {
    final now = DateTime.now();
    return Crop(
      id: now.millisecondsSinceEpoch.toString(),
      userId: userId,
      name: name,
      type: type,
      plantedDate: plantedDate,
      status: 'activo',
      createdAt: now,
      updatedAt: now,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'name': name,
      'type': type,
      'plantedDate': plantedDate.toIso8601String(),
      'harvestDate': harvestDate?.toIso8601String(),
      'status': status,
      'optimalTempMin': optimalTempMin,
      'optimalTempMax': optimalTempMax,
      'optimalHumidityMin': optimalHumidityMin,
      'optimalHumidityMax': optimalHumidityMax,
      'notes': notes,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  factory Crop.fromJson(Map<String, dynamic> json) {
    return Crop(
      id: json['id'],
      userId: json['userId'],
      name: json['name'],
      type: json['type'],
      plantedDate: DateTime.parse(json['plantedDate']),
      harvestDate: json['harvestDate'] != null ? DateTime.parse(json['harvestDate']) : null,
      status: json['status'],
      optimalTempMin: json['optimalTempMin']?.toDouble(),
      optimalTempMax: json['optimalTempMax']?.toDouble(),
      optimalHumidityMin: json['optimalHumidityMin']?.toDouble(),
      optimalHumidityMax: json['optimalHumidityMax']?.toDouble(),
      notes: json['notes'],
      createdAt: DateTime.parse(json['createdAt']),
      updatedAt: DateTime.parse(json['updatedAt']),
    );
  }

  Crop copyWith({
    String? id,
    String? userId,
    String? name,
    String? type,
    DateTime? plantedDate,
    DateTime? harvestDate,
    String? status,
    double? optimalTempMin,
    double? optimalTempMax,
    double? optimalHumidityMin,
    double? optimalHumidityMax,
    String? notes,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Crop(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      type: type ?? this.type,
      plantedDate: plantedDate ?? this.plantedDate,
      harvestDate: harvestDate ?? this.harvestDate,
      status: status ?? this.status,
      optimalTempMin: optimalTempMin ?? this.optimalTempMin,
      optimalTempMax: optimalTempMax ?? this.optimalTempMax,
      optimalHumidityMin: optimalHumidityMin ?? this.optimalHumidityMin,
      optimalHumidityMax: optimalHumidityMax ?? this.optimalHumidityMax,
      notes: notes ?? this.notes,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  int get daysPlanted {
    final now = DateTime.now();
    return now.difference(plantedDate).inDays;
  }

  String get statusLabel {
    switch (status) {
      case 'activo':
        return 'Activo';
      case 'cosechado':
        return 'Cosechado';
      case 'perdido':
        return 'Perdido';
      default:
        return status;
    }
  }
}
