// services/firebase_service.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import '../models/sensor_data.dart';
import '../models/device_state.dart';

class FirebaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Colecciones
  final String _sensorDataCollection = 'sensor_data';
  final String _deviceStateCollection = 'device_states';
  final String _userSettingsCollection = 'user_settings';
  
  Future<void> saveManualScanSpanish({
    required String userId,
    required String plantName,
    required double temperatura,
    required double humedadAmbiental,
    required double humedadSuelo,
    required double porcentajeTemperatura,
    required double porcentajeHumedad,
    required double porcentajeHumedadSuelo,
    required DateTime fechaHora,
  }) async {
    final String collectionName = _collectionForPlant(plantName);
    await _firestore.collection(collectionName).add({
      'usuario_id': userId,
      'planta': plantName,
      'temperatura': temperatura,
      'humedad_ambiental': humedadAmbiental,
      'humedad_suelo': humedadSuelo,
      'porcentaje_temperatura': porcentajeTemperatura,
      'porcentaje_humedad': porcentajeHumedad,
      'porcentaje_humedad_suelo': porcentajeHumedadSuelo,
      'fecha_hora': fechaHora,
    });
  }

  String _collectionForPlant(String plantName) {
    final normalized = plantName.trim().toLowerCase().replaceAll('á', 'a').replaceAll('é', 'e').replaceAll('í', 'i').replaceAll('ó', 'o').replaceAll('ú', 'u');
    return 'sensor_datos_${normalized}';
  }
  
  // Guardar datos de sensores en Firestore
  Future<void> saveSensorData(SensorData data) async {
    try {
      await _firestore.collection(_sensorDataCollection).add(data.toJson());
    } catch (e) {
      print('Error al guardar datos de sensores: $e');
    }
  }
  
  // Obtener los últimos datos de sensores para un usuario
  Stream<SensorData?> getLatestSensorData(String userId) {
    // Evitar índice compuesto: ordenar por timestamp y filtrar por userId en código
    return _firestore
        .collection(_sensorDataCollection)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
          for (final doc in snapshot.docs) {
            final data = SensorData.fromJson(doc.data());
            if (data.userId == userId) {
              return data;
            }
          }
          return null;
        });
  }

  // Obtener datos de sensores en tiempo real
  Stream<SensorData> getRealtimeSensors({required String userId, required String plantType}) {
    // Datos simulados para pruebas
    return Stream.periodic(const Duration(seconds: 3), (count) {
      return SensorData(
        temperature: 23.5 + (count % 5),
        humidity: 60.0 + (count % 15),
        soilMoisture: 70.0 + (count % 10),
        light: 15000 + (count * 100),
        timestamp: DateTime.now(),
        userId: userId,
        plantType: plantType,
      );
    });
  }

  // Leer historial desde Firebase Realtime Database en la ruta 'historico'
  // Devuelve una lista ordenada por la clave push (que es cronológica)
  Stream<List<Map<String, dynamic>>> getRtdbHistorical() {
    final db = FirebaseDatabase.instanceFor(
      app: Firebase.app(),
      databaseURL: 'https://invernadero-61290-default-rtdb.firebaseio.com',
    );

    final ref = db.ref('historico');
    return ref.onValue.map((event) {
      final value = event.snapshot.value;
      if (value == null) return <Map<String, dynamic>>[];
      final map = Map<dynamic, dynamic>.from(value as Map);
      final items = map.entries.map((e) {
        final data = Map<String, dynamic>.from(e.value as Map);
        data['id'] = e.key;
        return data;
      }).toList();
      // Ordenar por id (push keys están ordenadas por tiempo)
      items.sort((a, b) => (a['id'] as String).compareTo(b['id'] as String));
      return items;
    });
  }
  
  // Obtener datos históricos simulados
  Stream<List<Map<String, dynamic>>> getHistoricalData() {
    // Datos simulados basados en el ejemplo proporcionado
    final List<Map<String, dynamic>> mockData = [
      {
        'id': '-OcwuwpjEokWX_BP4Nd2',
        'fecha': '31 08:01:00 PM',
        'humedad_aire': 60.6,
        'humedad_suelo': 68.8,
        'planta': 'Lechuga',
        'temperatura': 24.6,
      },
      {
        'id': '-OcwvBM5wD7V_pOvwJ56',
        'fecha': '31 08:05:00 PM',
        'humedad_aire': 78.3,
        'humedad_suelo': 71.0,
        'planta': 'Tomate',
        'temperatura': 34.5,
      },
      {
        'id': '-OcwvCM5wD7V_pOvwJ57',
        'fecha': '31 08:10:00 PM',
        'humedad_aire': 65.2,
        'humedad_suelo': 70.5,
        'planta': 'Tomate',
        'temperatura': 28.3,
      },
      {
        'id': '-OcwvDM5wD7V_pOvwJ58',
        'fecha': '31 08:15:00 PM',
        'humedad_aire': 62.8,
        'humedad_suelo': 69.7,
        'planta': 'Tomate',
        'temperatura': 25.1,
      },
      {
        'id': '-OcwvEM5wD7V_pOvwJ59',
        'fecha': '31 08:20:00 PM',
        'humedad_aire': 70.4,
        'humedad_suelo': 72.3,
        'planta': 'Tomate',
        'temperatura': 29.8,
      },
    ];
    
    return Stream.value(mockData);
  }
  
  // Obtener historial de datos de sensores para un usuario
  Stream<List<SensorData>> getSensorDataHistory(String userId, {int limit = 100}) {
    return _firestore
        .collection(_sensorDataCollection)
        .orderBy('timestamp', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) {
          final items = snapshot.docs
              .map((doc) => SensorData.fromJson(doc.data()))
              .where((d) => d.userId == userId)
              .toList();
          return items;
        });
  }
  
  // Método para obtener historial de sensores (versión Future)
  Future<List<SensorData>> getSensorHistory(String userId, {int limit = 100}) async {
    try {
      final query = _firestore
          .collection(_sensorDataCollection)
          .orderBy('timestamp', descending: true)
          .limit(limit);
      
      final snapshot = await query.get();
      
      final results = snapshot.docs
          .map((doc) => SensorData.fromJson(doc.data() as Map<String, dynamic>))
          .where((d) => d.userId == userId)
          .toList();

      if (results.isEmpty) {
        // Si no hay datos, generar algunos datos de ejemplo para pruebas
        List<SensorData> dummyData = [];
        final now = DateTime.now();
        
        for (int i = 0; i < 10; i++) {
          final timestamp = now.subtract(Duration(minutes: i * 10));
          dummyData.add(SensorData(
            temperature: 22.0 + (i % 5),
            humidity: 60.0 + (i % 10),
            soilMoisture: 70.0 - (i % 15),
            light: 700.0 + (i * 10),
            timestamp: timestamp,
            userId: userId,
            plantType: 'lettuce', // Planta por defecto
          ));
        }
        
        // Guardar los datos de ejemplo en Firestore
        for (var data in dummyData) {
          await saveSensorData(data);
        }
        
        return dummyData;
      }
      
      return results;
    } catch (e) {
      print('Error al obtener historial de sensores: $e');
      return [];
    }
  }
  
  // Guardar estado de dispositivos
  Future<void> saveDeviceState(DeviceState state) async {
    try {
      await _firestore.collection(_deviceStateCollection).add(state.toJson());
      
      // También actualizar el estado actual del usuario
      await _firestore
          .collection(_userSettingsCollection)
          .doc(state.userId)
          .set({'currentDeviceState': state.toJson()}, SetOptions(merge: true));
    } catch (e) {
      print('Error al guardar estado de dispositivos: $e');
    }
  }
  
  // Obtener el estado actual de los dispositivos para un usuario
  Stream<DeviceState?> getCurrentDeviceState(String userId) {
    return _firestore
        .collection(_userSettingsCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data()?['currentDeviceState'] != null) {
            return DeviceState.fromJson(snapshot.data()!['currentDeviceState']);
          }
          return DeviceState.initial(userId);
        });
  }
  
  // Guardar tipo de planta seleccionada por el usuario
  Future<void> savePlantType(String userId, String plantType) async {
    try {
      await _firestore
          .collection(_userSettingsCollection)
          .doc(userId)
          .set({'selectedPlant': plantType}, SetOptions(merge: true));
    } catch (e) {
      print('Error al guardar tipo de planta: $e');
    }
  }
  
  // Obtener tipo de planta seleccionada por el usuario
  Stream<String> getSelectedPlantType(String userId) {
    return _firestore
        .collection(_userSettingsCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data()?['selectedPlant'] != null) {
            return snapshot.data()!['selectedPlant'] as String;
          }
          return 'Lechuga'; // Valor por defecto
        });
  }
  
  // Guardar modo de control (automático o manual)
  Future<void> saveControlMode(String userId, String mode) async {
    try {
      await _firestore
          .collection(_userSettingsCollection)
          .doc(userId)
          .set({'controlMode': mode}, SetOptions(merge: true));
    } catch (e) {
      print('Error al guardar modo de control: $e');
    }
  }
  
  // Obtener modo de control actual
  Stream<String> getControlMode(String userId) {
    return _firestore
        .collection(_userSettingsCollection)
        .doc(userId)
        .snapshots()
        .map((snapshot) {
          if (snapshot.exists && snapshot.data()?['controlMode'] != null) {
            return snapshot.data()!['controlMode'] as String;
          }
          return 'automatic'; // Valor por defecto
        });
  }
}