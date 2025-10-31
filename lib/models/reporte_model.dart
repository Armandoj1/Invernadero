import 'sensor_data.dart';

/// Períodos disponibles para generar reportes
enum PeriodoReporte {
  dia,
  semana,
  mes;

  String get displayName {
    switch (this) {
      case PeriodoReporte.dia:
        return 'Día';
      case PeriodoReporte.semana:
        return 'Semana';
      case PeriodoReporte.mes:
        return 'Mes';
    }
  }

  DateTime get fechaInicio {
    final ahora = DateTime.now();
    switch (this) {
      case PeriodoReporte.dia:
        return ahora.subtract(const Duration(days: 1));
      case PeriodoReporte.semana:
        return ahora.subtract(const Duration(days: 7));
      case PeriodoReporte.mes:
        return ahora.subtract(const Duration(days: 30));
    }
  }
}

/// Estadísticas calculadas para un reporte
class Estadisticas {
  final double tempAirePromedio;
  final double tempAireMaxima;
  final double tempAireMinima;
  final double tempSueloPromedio;
  final double tempSueloMaxima;
  final double tempSueloMinima;
  final double humedadAirePromedio;
  final double humedadSueloPromedio;
  final double luminosidadPromedio;
  final int eventosRiego;
  final double horasLuz;
  final int totalLecturas;

  Estadisticas({
    required this.tempAirePromedio,
    required this.tempAireMaxima,
    required this.tempAireMinima,
    required this.tempSueloPromedio,
    required this.tempSueloMaxima,
    required this.tempSueloMinima,
    required this.humedadAirePromedio,
    required this.humedadSueloPromedio,
    required this.luminosidadPromedio,
    required this.eventosRiego,
    required this.horasLuz,
    required this.totalLecturas,
  });

  /// Calcular estadísticas desde una lista de datos de sensores
  factory Estadisticas.fromSensorData(List<SensorData> datos) {
    if (datos.isEmpty) {
      return Estadisticas(
        tempAirePromedio: 0,
        tempAireMaxima: 0,
        tempAireMinima: 0,
        tempSueloPromedio: 0,
        tempSueloMaxima: 0,
        tempSueloMinima: 0,
        humedadAirePromedio: 0,
        humedadSueloPromedio: 0,
        luminosidadPromedio: 0,
        eventosRiego: 0,
        horasLuz: 0,
        totalLecturas: 0,
      );
    }

    // Temperatura aire
    final tempsAire = datos.map((d) => d.temperaturaAire).toList();
    final tempsSuelo = datos.map((d) => d.temperaturaSuelo).toList();
    
    // Humedad
    final humsAire = datos.map((d) => d.humedadAire).toList();
    final humsSuelo = datos.map((d) => d.humedadSuelo).toList();
    
    // Luminosidad
    final lums = datos.map((d) => d.luminosidad).toList();

    return Estadisticas(
      tempAirePromedio: _promedio(tempsAire),
      tempAireMaxima: tempsAire.reduce((a, b) => a > b ? a : b),
      tempAireMinima: tempsAire.reduce((a, b) => a < b ? a : b),
      tempSueloPromedio: _promedio(tempsSuelo),
      tempSueloMaxima: tempsSuelo.reduce((a, b) => a > b ? a : b),
      tempSueloMinima: tempsSuelo.reduce((a, b) => a < b ? a : b),
      humedadAirePromedio: _promedio(humsAire),
      humedadSueloPromedio: _promedio(humsSuelo),
      luminosidadPromedio: _promedio(lums),
      eventosRiego: 0, // TODO: calcular desde datos de riego
      horasLuz: (lums.where((l) => l > 50).length * 3 / 60), // Asumiendo lecturas cada 3 min
      totalLecturas: datos.length,
    );
  }

  static double _promedio(List<double> valores) {
    if (valores.isEmpty) return 0;
    return valores.reduce((a, b) => a + b) / valores.length;
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'tempAirePromedio': tempAirePromedio,
      'tempAireMaxima': tempAireMaxima,
      'tempAireMinima': tempAireMinima,
      'tempSueloPromedio': tempSueloPromedio,
      'tempSueloMaxima': tempSueloMaxima,
      'tempSueloMinima': tempSueloMinima,
      'humedadAirePromedio': humedadAirePromedio,
      'humedadSueloPromedio': humedadSueloPromedio,
      'luminosidadPromedio': luminosidadPromedio,
      'eventosRiego': eventosRiego,
      'horasLuz': horasLuz,
      'totalLecturas': totalLecturas,
    };
  }
}

/// Modelo de datos para reportes generados
class ReporteModel {
  final String id;
  final PeriodoReporte periodo;
  final DateTime fechaInicio;
  final DateTime fechaFin;
  final List<SensorData> datos;
  final Estadisticas estadisticas;

  ReporteModel({
    required this.id,
    required this.periodo,
    required this.fechaInicio,
    required this.fechaFin,
    required this.datos,
    required this.estadisticas,
  });

  /// Constructor desde JSON
  factory ReporteModel.fromJson(Map<String, dynamic> json) {
    final inicio = DateTime.tryParse(json['fechaInicio'] ?? '') ?? DateTime.now();
    final fin = DateTime.tryParse(json['fechaFin'] ?? '') ?? DateTime.now();
    
    return ReporteModel(
      id: json['id'] ?? '',
      periodo: PeriodoReporte.values.firstWhere(
        (e) => e.name == json['periodo'],
        orElse: () => PeriodoReporte.dia,
      ),
      fechaInicio: inicio,
      fechaFin: fin,
      datos: (json['datos'] as List?)
              ?.map((d) => SensorData.fromJson(d))
              .toList() ??
          [],
      estadisticas: Estadisticas.fromSensorData(
        (json['datos'] as List?)
                ?.map((d) => SensorData.fromJson(d))
                .toList() ??
            [],
      ),
    );
  }

  /// Convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'periodo': periodo.name,
      'fechaInicio': fechaInicio.toIso8601String(),
      'fechaFin': fechaFin.toIso8601String(),
      'datos': datos.map((d) => d.toJson()).toList(),
      'estadisticas': estadisticas.toJson(),
    };
  }

  /// Obtener título descriptivo del reporte
  String get titulo {
    return 'Reporte ${periodo.displayName} - ${fechaInicio.day}/${fechaInicio.month}/${fechaInicio.year}';
  }

  /// Obtener resumen de estadísticas principales
  String get resumen {
    return '''Promedio temperatura aire: ${estadisticas.tempAirePromedio.toStringAsFixed(1)}°C
Promedio humedad aire: ${estadisticas.humedadAirePromedio.toStringAsFixed(1)}%
Total lecturas: ${estadisticas.totalLecturas}''';
  }

  @override
  String toString() {
    return 'ReporteModel($titulo, lecturas: ${estadisticas.totalLecturas})';
  }
}
