import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/reporte_model.dart';
import '../models/sensor_data.dart';
import 'sensor_service.dart';

/// Servicio para generar reportes del invernadero
class ReporteService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final SensorService _sensorService = SensorService();

  /// Generar reporte para un período específico
  Future<ReporteModel?> generarReporte(
    String userId,
    PeriodoReporte periodo,
  ) async {
    try {
      final fechaInicio = periodo.fechaInicio;
      final fechaFin = DateTime.now();
      
      // Obtener datos del período
      final datos = await _sensorService.getHistorico(userId, fechaInicio, fechaFin);
      
      // Calcular estadísticas
      final estadisticas = Estadisticas.fromSensorData(datos);
      
      // Crear reporte
      final reporte = ReporteModel(
        id: _generarId(),
        periodo: periodo,
        fechaInicio: fechaInicio,
        fechaFin: fechaFin,
        datos: datos,
        estadisticas: estadisticas,
      );
      
      // Guardar reporte en Firestore
      await _guardarReporte(userId, reporte);
      
      return reporte;
    } catch (e) {
      print('Error al generar reporte: $e');
      return null;
    }
  }

  /// Obtener todos los reportes de un usuario
  Future<List<ReporteModel>> getReportesUsuario(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('reportes')
          .doc(userId)
          .collection('mis_reportes')
          .orderBy('fechaFin', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => ReporteModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      print('Error al obtener reportes: $e');
      return [];
    }
  }

  /// Obtener un reporte específico por ID
  Future<ReporteModel?> getReportePorId(
    String userId,
    String reporteId,
  ) async {
    try {
      final doc = await _firestore
          .collection('reportes')
          .doc(userId)
          .collection('mis_reportes')
          .doc(reporteId)
          .get();

      if (doc.exists && doc.data() != null) {
        return ReporteModel.fromJson(doc.data()!);
      }
      
      return null;
    } catch (e) {
      print('Error al obtener reporte: $e');
      return null;
    }
  }

  /// Generar reporte diario
  Future<ReporteModel?> generarReporteDiario(String userId) async {
    return await generarReporte(userId, PeriodoReporte.dia);
  }

  /// Generar reporte semanal
  Future<ReporteModel?> generarReporteSemanal(String userId) async {
    return await generarReporte(userId, PeriodoReporte.semana);
  }

  /// Generar reporte mensual
  Future<ReporteModel?> generarReporteMensual(String userId) async {
    return await generarReporte(userId, PeriodoReporte.mes);
  }

  /// Guardar reporte en Firestore
  Future<bool> _guardarReporte(String userId, ReporteModel reporte) async {
    try {
      await _firestore
          .collection('reportes')
          .doc(userId)
          .collection('mis_reportes')
          .doc(reporte.id)
          .set(reporte.toJson());
      
      return true;
    } catch (e) {
      print('Error al guardar reporte: $e');
      return false;
    }
  }

  /// Eliminar un reporte
  Future<bool> eliminarReporte(String userId, String reporteId) async {
    try {
      await _firestore
          .collection('reportes')
          .doc(userId)
          .collection('mis_reportes')
          .doc(reporteId)
          .delete();
      
      return true;
    } catch (e) {
      print('Error al eliminar reporte: $e');
      return false;
    }
  }

  /// Generar ID único para reporte
  String _generarId() {
    return DateTime.now().millisecondsSinceEpoch.toString();
  }

  /// Obtener resumen rápido de estadísticas sin generar reporte completo
  Future<Map<String, dynamic>?> getResumenRapido(
    String userId,
    PeriodoReporte periodo,
  ) async {
    try {
      final fechaInicio = periodo.fechaInicio;
      final fechaFin = DateTime.now();
      
      final datos = await _sensorService.getHistorico(userId, fechaInicio, fechaFin);
      final estadisticas = Estadisticas.fromSensorData(datos);
      
      return {
        'periodo': periodo.displayName,
        'totalLecturas': estadisticas.totalLecturas,
        'tempPromedio': estadisticas.tempAirePromedio,
        'humedadPromedio': estadisticas.humedadAirePromedio,
        'fechaInicio': fechaInicio.toIso8601String(),
        'fechaFin': fechaFin.toIso8601String(),
      };
    } catch (e) {
      print('Error al obtener resumen: $e');
      return null;
    }
  }
}

