import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/dispositivo_control.dart';

/// Servicio para controlar dispositivos del invernadero
class DispositivoService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Obtener estado actual de dispositivos
  Future<DispositivoControl?> getEstadoDispositivos(String userId) async {
    try {
      final doc = await _firestore.collection('dispositivos').doc(userId).get();
      
      if (doc.exists && doc.data() != null) {
        return DispositivoControl.fromJson(doc.data()!);
      }
      
      return null;
    } catch (e) {
      print('Error al obtener estado de dispositivos: $e');
      return null;
    }
  }

  /// Actualizar velocidad del ventilador
  Future<bool> setVelocidadVentilador(
    String userId,
    double velocidad,
  ) async {
    try {
      // Validar rango
      final velocidadClamp = velocidad.clamp(0, 100);
      
      await _firestore.collection('dispositivos').doc(userId).set({
        'id': userId,
        'velocidadVentilador': velocidadClamp,
        'usuarioId': userId,
        'ultimaActualizacion': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('Ventilador actualizado: $velocidadClamp%');
      return true;
    } catch (e) {
      print('Error al actualizar ventilador: $e');
      return false;
    }
  }

  /// Iniciar riego con duración específica
  Future<bool> setDuracionRiego(
    String userId,
    int segundos,
  ) async {
    try {
      await _firestore.collection('dispositivos').doc(userId).set({
        'id': userId,
        'duracionRiego': segundos,
        'usuarioId': userId,
        'ultimaActualizacion': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('Riego iniciado: $segundos segundos');
      return true;
    } catch (e) {
      print('Error al iniciar riego: $e');
      return false;
    }
  }

  /// Establecer intensidad de luminosidad (1-5)
  Future<bool> setIntensidadLuminosidad(
    String userId,
    int nivel,
  ) async {
    try {
      // Validar rango
      final nivelClamp = nivel.clamp(1, 5);
      
      await _firestore.collection('dispositivos').doc(userId).set({
        'id': userId,
        'intensidadLuminosidad': nivelClamp,
        'usuarioId': userId,
        'ultimaActualizacion': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      print('Luminosidad actualizada: Nivel $nivelClamp/5');
      return true;
    } catch (e) {
      print('Error al actualizar luminosidad: $e');
      return false;
    }
  }

  /// Actualizar múltiples dispositivos a la vez
  Future<bool> actualizarDispositivos(
    String userId,
    DispositivoControl control,
  ) async {
    try {
      await _firestore.collection('dispositivos').doc(userId).set({
        'id': userId,
        'velocidadVentilador': control.velocidadVentilador,
        'duracionRiego': control.duracionRiego,
        'intensidadLuminosidad': control.intensidadLuminosidad,
        'usuarioId': userId,
        'ultimaActualizacion': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Error al actualizar dispositivos: $e');
      return false;
    }
  }

  /// Stream de cambios en dispositivos (tiempo real)
  Stream<DispositivoControl?> getDispositivosStream(String userId) {
    return _firestore
        .collection('dispositivos')
        .doc(userId)
        .snapshots()
        .map((doc) {
      if (doc.exists && doc.data() != null) {
        return DispositivoControl.fromJson(doc.data()!);
      }
      return null;
    });
  }

  /// Apagar todos los dispositivos
  Future<bool> apagarTodos(String userId) async {
    try {
      await _firestore.collection('dispositivos').doc(userId).set({
        'id': userId,
        'velocidadVentilador': 0,
        'duracionRiego': 0,
        'intensidadLuminosidad': 1,
        'usuarioId': userId,
        'ultimaActualizacion': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));

      return true;
    } catch (e) {
      print('Error al apagar dispositivos: $e');
      return false;
    }
  }
}

