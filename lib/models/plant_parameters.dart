class PlantParameters {
  final String plantType;
  final double minTemperature;
  final double maxTemperature;
  final double minHumidity;
  final double maxHumidity;
  final double minSoilMoisture;
  final double maxSoilMoisture;
  final double minLight;
  final double maxLight;

  PlantParameters({
    required this.plantType,
    required this.minTemperature,
    required this.maxTemperature,
    required this.minHumidity,
    required this.maxHumidity,
    required this.minSoilMoisture,
    required this.maxSoilMoisture,
    required this.minLight,
    required this.maxLight,
  });

  static PlantParameters getParameters(String plantType) {
    switch (plantType.toLowerCase()) {
      case 'lechuga':
        return PlantParameters(
          plantType: 'Lechuga',
          minTemperature: 15,
          maxTemperature: 20,
          minHumidity: 70,
          maxHumidity: 80,
          minSoilMoisture: 60,
          maxSoilMoisture: 80,
          minLight: 10000,
          maxLight: 15000,
        );
      case 'tomate':
        return PlantParameters(
          plantType: 'Tomate',
          minTemperature: 20,
          maxTemperature: 25,
          minHumidity: 60,
          maxHumidity: 70,
          minSoilMoisture: 65,
          maxSoilMoisture: 85,
          minLight: 15000,
          maxLight: 20000,
        );
      case 'fresa':
        return PlantParameters(
          plantType: 'Fresa',
          minTemperature: 18,
          maxTemperature: 24,
          minHumidity: 65,
          maxHumidity: 75,
          minSoilMoisture: 60,
          maxSoilMoisture: 75,
          minLight: 12000,
          maxLight: 18000,
        );
      case 'zanahoria':
        return PlantParameters(
          plantType: 'Zanahoria',
          minTemperature: 16,
          maxTemperature: 21,
          minHumidity: 60,
          maxHumidity: 70,
          minSoilMoisture: 55,
          maxSoilMoisture: 70,
          minLight: 8000,
          maxLight: 12000,
        );
      default:
        // Valores por defecto para Lechuga
        return PlantParameters(
          plantType: plantType,
          minTemperature: 15,
          maxTemperature: 20,
          minHumidity: 70,
          maxHumidity: 80,
          minSoilMoisture: 60,
          maxSoilMoisture: 80,
          minLight: 10000,
          maxLight: 15000,
        );
    }
  }

  bool isTemperatureInRange(double value) {
    return value >= minTemperature && value <= maxTemperature;
  }

  bool isHumidityInRange(double value) {
    return value >= minHumidity && value <= maxHumidity;
  }

  bool isSoilMoistureInRange(double value) {
    return value >= minSoilMoisture && value <= maxSoilMoisture;
  }

  bool isLightInRange(double value) {
    return value >= minLight && value <= maxLight;
  }

  String getTemperatureStatus(double value) {
    if (value < minTemperature) return 'low';
    if (value > maxTemperature) return 'high';
    return 'normal';
  }

  String getHumidityStatus(double value) {
    if (value < minHumidity) return 'low';
    if (value > maxHumidity) return 'high';
    return 'normal';
  }

  String getSoilMoistureStatus(double value) {
    if (value < minSoilMoisture) return 'low';
    if (value > maxSoilMoisture) return 'high';
    return 'normal';
  }

  String getLightStatus(double value) {
    if (value < minLight) return 'low';
    if (value > maxLight) return 'high';
    return 'normal';
  }
}
