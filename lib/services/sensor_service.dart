import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sensor_data.dart';

/// Servicio para manejar datos de sensores del invernadero
class SensorService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtener stream de datos de sensores en tiempo real
  Stream<SensorData?> getSensorDataStream(String userId) {
    return _firestore
        .collection('sensores')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return SensorData.fromJson(doc.data()!);
      }
      return null;
    });
  }

  /// Obtener los últimos N datos de sensores
  Future<List<SensorData>> getUltimosDatos(
    String userId,
    int limite,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('sensores')
          .doc(userId)
          .collection('historial')
          .orderBy('timestamp', descending: true)
          .limit(limite)
          .get();

      return querySnapshot.docs
          .map((doc) => SensorData.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error al obtener últimos datos: $e');
      return [];
    }
  }

  /// Obtener histórico de sensores en un rango de fechas
  Future<List<SensorData>> getHistorico(
    String userId,
    DateTime inicio,
    DateTime fin,
  ) async {
    try {
      final querySnapshot = await _firestore
          .collection('sensores')
          .doc(userId)
          .collection('historial')
          .where('timestamp', isGreaterThan: inicio.toIso8601String())
          .where('timestamp', isLessThan: fin.toIso8601String())
          .orderBy('timestamp', descending: false)
          .get();

      return querySnapshot.docs
          .map((doc) => SensorData.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error al obtener histórico: $e');
      return [];
    }
  }

  /// Guardar lectura de sensor (útil para simulación/testing)
  Future<bool> guardarLectura(String userId, SensorData sensorData) async {
    try {
      await _firestore
          .collection('sensores')
          .doc(userId)
          .set(sensorData.toJson(), SetOptions(merge: true));

      // También guardar en historial
      await _firestore
          .collection('sensores')
          .doc(userId)
          .collection('historial')
          .add(sensorData.toJson());

      return true;
    } catch (e) {
      print('Error al guardar lectura: $e');
      return false;
    }
  }

  /// Obtener datos de simulación para desarrollo/testing
  Future<SensorData> getDatosSimulados() async {
    // Simular datos realistas
    final ahora = DateTime.now();
    
    // Simular variaciones naturales (ejemplo: ciclo diario)
    final hora = ahora.hour;
    final factorHora = (hora < 12) ? hora / 12 : (24 - hora) / 12;
    
    return SensorData(
      id: 'simulado',
      temperaturaAire: 18 + (factorHora * 8) + (ahora.minute % 3),
      temperaturaSuelo: 18 + (factorHora * 6) + (ahora.minute % 2),
      humedadAire: 60 + (factorHora * 15) + (ahora.minute % 5),
      humedadSuelo: 70 + (factorHora * 10) + (ahora.minute % 3),
      luminosidad: (factorHora * 80) + (ahora.minute % 20),
      timestamp: ahora,
    );
  }
}

