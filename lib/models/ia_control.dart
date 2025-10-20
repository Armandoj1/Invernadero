class IAControlModel {
  final String id; // uid del usuario o invernadero
  final String cultivo;
  final String modo; // 'automatico' | 'manual' | 'hibrido'
  final double temperaturaObjetivo;
  final double humedadObjetivo;
  final double co2Objetivo;
  final DateTime ultimaActualizacion;

  IAControlModel({
    required this.id,
    required this.cultivo,
    required this.modo,
    required this.temperaturaObjetivo,
    required this.humedadObjetivo,
    required this.co2Objetivo,
    required this.ultimaActualizacion,
  });

  factory IAControlModel.fromJson(Map<String, dynamic> json) {
    final dynamic fecha = json['ultimaActualizacion'];
    DateTime updatedAt;
    if (fecha is String) {
      updatedAt = DateTime.tryParse(fecha) ?? DateTime.now();
    } else if (fecha is DateTime) {
      updatedAt = fecha;
    } else {
      updatedAt = DateTime.now();
    }

    return IAControlModel(
      id: (json['id'] ?? json['uid'] ?? '') as String,
      cultivo: (json['cultivo'] ?? 'Tomate') as String,
      modo: (json['modo'] ?? 'automatico') as String,
      temperaturaObjetivo: ((json['temperaturaObjetivo'] ?? 24) as num).toDouble(),
      humedadObjetivo: ((json['humedadObjetivo'] ?? 70) as num).toDouble(),
      co2Objetivo: ((json['co2Objetivo'] ?? 500) as num).toDouble(),
      ultimaActualizacion: updatedAt,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uid': id, // escribimos ambos por compatibilidad
      'cultivo': cultivo,
      'modo': modo,
      'temperaturaObjetivo': temperaturaObjetivo,
      'humedadObjetivo': humedadObjetivo,
      'co2Objetivo': co2Objetivo,
      'ultimaActualizacion': ultimaActualizacion.toIso8601String(),
    };
  }

  IAControlModel copyWith({
    String? id,
    String? cultivo,
    String? modo,
    double? temperaturaObjetivo,
    double? humedadObjetivo,
    double? co2Objetivo,
    DateTime? ultimaActualizacion,
  }) {
    return IAControlModel(
      id: id ?? this.id,
      cultivo: cultivo ?? this.cultivo,
      modo: modo ?? this.modo,
      temperaturaObjetivo: temperaturaObjetivo ?? this.temperaturaObjetivo,
      humedadObjetivo: humedadObjetivo ?? this.humedadObjetivo,
      co2Objetivo: co2Objetivo ?? this.co2Objetivo,
      ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
    );
  }
}