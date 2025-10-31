import 'sensor_data.dart';

/// Tipos de plantas disponibles en el sistema
enum TipoPlanta {
  lechuga,
  pimenton,
  tomate;

  String get displayName {
    switch (this) {
      case TipoPlanta.lechuga:
        return 'Lechuga';
      case TipoPlanta.pimenton:
        return 'Pimentón';
      case TipoPlanta.tomate:
        return 'Tomate';
    }
  }
}

/// Rango de temperatura óptima para una planta
class RangoTemperatura {
  final double min;
  final double max;

  RangoTemperatura({required this.min, required this.max});

  bool estaEnRango(double temperatura) {
    return temperatura >= min && temperatura <= max;
  }

  double distanciaDelRango(double temperatura) {
    if (estaEnRango(temperatura)) return 0;
    if (temperatura < min) return min - temperatura;
    return temperatura - max;
  }
}

/// Rango de humedad óptima para una planta
class RangoHumedad {
  final double min;
  final double max;

  RangoHumedad({required this.min, required this.max});

  bool estaEnRango(double humedad) {
    return humedad >= min && humedad <= max;
  }

  double distanciaDelRango(double humedad) {
    if (estaEnRango(humedad)) return 0;
    if (humedad < min) return min - humedad;
    return humedad - max;
  }
}

/// Modelo de datos para una planta con sus parámetros óptimos
class PlantaModel {
  final TipoPlanta tipo;
  final RangoTemperatura temperaturaOptima;
  final RangoHumedad humedadOptima;
  final RangoHumedad humedadSueloOptima;
  final int nivelLuminosidad; // 1-5

  PlantaModel({
    required this.tipo,
    required this.temperaturaOptima,
    required this.humedadOptima,
    required this.humedadSueloOptima,
    required this.nivelLuminosidad,
  });

  String get nombre => tipo.displayName;

  /// Obtener configuración por defecto según el tipo de planta
  static PlantaModel getDefault(TipoPlanta tipo) {
    switch (tipo) {
      case TipoPlanta.lechuga:
        return PlantaModel(
          tipo: TipoPlanta.lechuga,
          temperaturaOptima: RangoTemperatura(min: 15, max: 20),
          humedadOptima: RangoHumedad(min: 60, max: 70),
          humedadSueloOptima: RangoHumedad(min: 75, max: 85),
          nivelLuminosidad: 3, // Moderada
        );
      case TipoPlanta.pimenton:
        return PlantaModel(
          tipo: TipoPlanta.pimenton,
          temperaturaOptima: RangoTemperatura(min: 21, max: 26),
          humedadOptima: RangoHumedad(min: 65, max: 75),
          humedadSueloOptima: RangoHumedad(min: 70, max: 80),
          nivelLuminosidad: 4, // Alta
        );
      case TipoPlanta.tomate:
        return PlantaModel(
          tipo: TipoPlanta.tomate,
          temperaturaOptima: RangoTemperatura(min: 20, max: 24),
          humedadOptima: RangoHumedad(min: 70, max: 80),
          humedadSueloOptima: RangoHumedad(min: 70, max: 80),
          nivelLuminosidad: 5, // Muy Alta
        );
    }
  }

  /// Convertir a JSON para almacenamiento
  Map<String, dynamic> toJson() {
    return {
      'tipo': tipo.name,
      'temperaturaMin': temperaturaOptima.min,
      'temperaturaMax': temperaturaOptima.max,
      'humedadMin': humedadOptima.min,
      'humedadMax': humedadOptima.max,
      'humedadSueloMin': humedadSueloOptima.min,
      'humedadSueloMax': humedadSueloOptima.max,
      'nivelLuminosidad': nivelLuminosidad,
    };
  }

  /// Constructor desde JSON
  factory PlantaModel.fromJson(Map<String, dynamic> json) {
    return PlantaModel(
      tipo: TipoPlanta.values.firstWhere(
        (e) => e.name == json['tipo'],
        orElse: () => TipoPlanta.tomate,
      ),
      temperaturaOptima: RangoTemperatura(
        min: (json['temperaturaMin'] as num).toDouble(),
        max: (json['temperaturaMax'] as num).toDouble(),
      ),
      humedadOptima: RangoHumedad(
        min: (json['humedadMin'] as num).toDouble(),
        max: (json['humedadMax'] as num).toDouble(),
      ),
      humedadSueloOptima: RangoHumedad(
        min: (json['humedadSueloMin'] as num).toDouble(),
        max: (json['humedadSueloMax'] as num).toDouble(),
      ),
      nivelLuminosidad: json['nivelLuminosidad'] as int,
    );
  }

  /// Verificar si los parámetros actuales están óptimos
  Map<String, bool> verificarParametros(SensorData sensor) {
    return {
      'temperatura': temperaturaOptima.estaEnRango(sensor.temperaturaAire),
      'humedadAire': humedadOptima.estaEnRango(sensor.humedadAire),
      'humedadSuelo': humedadSueloOptima.estaEnRango(sensor.humedadSuelo),
      'luminosidad': (sensor.luminosidad / 20).round() >= nivelLuminosidad,
    };
  }

  /// Obtener mensaje descriptivo de parámetros óptimos
  String get descripcionParametros {
    return '''$nombre requiere:
• Temperatura: ${temperaturaOptima.min}-${temperaturaOptima.max}°C
• Humedad aire: ${humedadOptima.min}-${humedadOptima.max}%
• Humedad suelo: ${humedadSueloOptima.min}-${humedadSueloOptima.max}%
• Luminosidad: $nivelLuminosidad/5''';
  }
}

