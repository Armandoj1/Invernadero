/// Modelo de datos para control de dispositivos del invernadero
class DispositivoControl {
  final String id;
  final double velocidadVentilador; // 0-100%
  final int duracionRiego; // segundos
  final int intensidadLuminosidad; // 1-5
  final DateTime ultimaActualizacion;
  final String usuarioId;

  DispositivoControl({
    required this.id,
    required this.velocidadVentilador,
    required this.duracionRiego,
    required this.intensidadLuminosidad,
    required this.ultimaActualizacion,
    required this.usuarioId,
  });

  /// Constructor desde JSON (Firestore, API REST, etc.)
  factory DispositivoControl.fromJson(Map<String, dynamic> json) {
    final dynamic timestamp = json['ultimaActualizacion'];
    DateTime fecha;
    
    if (timestamp is String) {
      fecha = DateTime.tryParse(timestamp) ?? DateTime.now();
    } else if (timestamp is DateTime) {
      fecha = timestamp;
    } else {
      fecha = DateTime.now();
    }

    return DispositivoControl(
      id: (json['id'] ?? '') as String,
      velocidadVentilador: ((json['velocidadVentilador'] ?? 0) as num).toDouble().clamp(0, 100),
      duracionRiego: (json['duracionRiego'] ?? 0) as int,
      intensidadLuminosidad: (json['intensidadLuminosidad'] ?? 1).clamp(1, 5) as int,
      ultimaActualizacion: fecha,
      usuarioId: (json['usuarioId'] ?? '') as String,
    );
  }

  /// Convertir a JSON para almacenamiento/enviar al backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'velocidadVentilador': velocidadVentilador,
      'duracionRiego': duracionRiego,
      'intensidadLuminosidad': intensidadLuminosidad,
      'ultimaActualizacion': ultimaActualizacion.toIso8601String(),
      'usuarioId': usuarioId,
    };
  }

  /// Crear copia con valores modificados
  DispositivoControl copyWith({
    String? id,
    double? velocidadVentilador,
    int? duracionRiego,
    int? intensidadLuminosidad,
    DateTime? ultimaActualizacion,
    String? usuarioId,
  }) {
    return DispositivoControl(
      id: id ?? this.id,
      velocidadVentilador: velocidadVentilador ?? this.velocidadVentilador,
      duracionRiego: duracionRiego ?? this.duracionRiego,
      intensidadLuminosidad: intensidadLuminosidad ?? this.intensidadLuminosidad,
      ultimaActualizacion: ultimaActualizacion ?? this.ultimaActualizacion,
      usuarioId: usuarioId ?? this.usuarioId,
    );
  }

  /// Obtener estado descriptivo del ventilador
  String get estadoVentilador {
    if (velocidadVentilador == 0) return 'Apagado';
    if (velocidadVentilador < 30) return 'Bajo';
    if (velocidadVentilador < 60) return 'Medio';
    if (velocidadVentilador < 100) return 'Alto';
    return 'Máximo';
  }

  /// Obtener estado descriptivo de la luminosidad
  String get estadoLuminosidad {
    return 'Nivel $intensidadLuminosidad/5';
  }

  /// Obtener duración de riego en formato legible
  String get duracionRiegoFormateada {
    if (duracionRiego < 60) {
      return '$duracionRiego seg';
    } else if (duracionRiego < 3600) {
      final minutos = (duracionRiego / 60).round();
      return '$minutos min';
    } else {
      final horas = (duracionRiego / 3600).round();
      return '$horas h';
    }
  }

  @override
  String toString() {
    return 'DispositivoControl(ventilador: ${velocidadVentilador.toStringAsFixed(0)}%, riego: $duracionRiegoFormateada, luz: $intensidadLuminosidad/5)';
  }
}
