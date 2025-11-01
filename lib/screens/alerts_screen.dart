import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/firebase_service.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final FirebaseService _firebaseService = FirebaseService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BCD4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'AgriSense Pro',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              'Alertas',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Alertas en Tiempo Real'),
                  content: const Text(
                    'Las alertas se calculan automáticamente basándose en los datos actuales de los sensores. '
                    'Se muestran cuando las condiciones están fuera del rango óptimo para el tipo de cultivo.',
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Entendido'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Información',
          ),
        ],
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firebaseService.getRtdbHistorical(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final entries = snapshot.data ?? [];
          if (entries.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay datos de sensores',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            );
          }

          // Obtener última lectura de Lechuga
          Map<String, dynamic>? latest;
          for (final item in entries.reversed) {
            if ((item['planta'] ?? '') == 'Lechuga') {
              latest = item;
              break;
            }
          }
          latest ??= entries.last;

          final double temp = ((latest['temperatura'] ?? 0) as num).toDouble();
          final double humAir = ((latest['humedad_aire'] ?? 0) as num).toDouble();
          final double humSoil = ((latest['humedad_suelo'] ?? 0) as num).toDouble();
          final String fecha = (latest['fecha'] ?? '') as String;

          // Calcular alertas basadas en rangos óptimos para Lechuga
          final List<Map<String, dynamic>> activeAlerts = [];

          // Temperatura (15-20°C óptimo)
          if (!(temp >= 15 && temp <= 20)) {
            String severity = 'medium';
            String title = '';
            String message = '';

            if (temp < 7) {
              severity = 'critical';
              title = 'Temperatura Crítica Baja';
              message = 'La temperatura está en ${temp.toStringAsFixed(1)}°C. Está muy por debajo del rango óptimo (15-20°C). Riesgo de congelación de las plantas.';
            } else if (temp < 15) {
              severity = temp < 10 ? 'high' : 'medium';
              title = 'Temperatura Baja';
              message = 'La temperatura está en ${temp.toStringAsFixed(1)}°C. El rango óptimo es 15-20°C. Considera activar el calefactor.';
            } else if (temp > 27) {
              severity = 'critical';
              title = 'Temperatura Crítica Alta';
              message = 'La temperatura está en ${temp.toStringAsFixed(1)}°C. Está muy por encima del rango óptimo (15-20°C). Riesgo de estrés térmico severo.';
            } else {
              severity = temp > 24 ? 'high' : 'medium';
              title = 'Temperatura Alta';
              message = 'La temperatura está en ${temp.toStringAsFixed(1)}°C. El rango óptimo es 15-20°C. Considera activar el ventilador o abrir ventilación.';
            }

            activeAlerts.add({
              'title': title,
              'message': message,
              'severity': severity,
              'plantType': 'Lechuga',
              'timestamp': fecha,
            });
          }

          // Humedad aire (70-80% óptimo)
          if (!(humAir >= 70 && humAir <= 80)) {
            String severity = 'medium';
            String title = '';
            String message = '';

            if (humAir < 70) {
              severity = humAir < 50 ? 'high' : 'medium';
              title = 'Humedad del Aire Baja';
              message = 'La humedad del aire está en ${humAir.toStringAsFixed(1)}%. El rango óptimo es 70-80%. Considera usar humidificadores.';
            } else {
              severity = humAir > 90 ? 'high' : 'medium';
              title = 'Humedad del Aire Alta';
              message = 'La humedad del aire está en ${humAir.toStringAsFixed(1)}%. El rango óptimo es 70-80%. Mejora la ventilación para reducir humedad.';
            }

            activeAlerts.add({
              'title': title,
              'message': message,
              'severity': severity,
              'plantType': 'Lechuga',
              'timestamp': fecha,
            });
          }

          // Humedad suelo (60-80% óptimo)
          if (!(humSoil >= 60 && humSoil <= 80)) {
            String severity = 'medium';
            String title = '';
            String message = '';

            if (humSoil < 60) {
              severity = humSoil < 40 ? 'high' : 'medium';
              title = 'Humedad del Suelo Baja';
              message = 'La humedad del suelo está en ${humSoil.toStringAsFixed(1)}%. El rango óptimo es 60-80%. Activa el sistema de riego.';
            } else {
              severity = humSoil > 90 ? 'high' : 'medium';
              title = 'Humedad del Suelo Alta';
              message = 'La humedad del suelo está en ${humSoil.toStringAsFixed(1)}%. El rango óptimo es 60-80%. Reduce el riego para evitar encharcamiento.';
            }

            activeAlerts.add({
              'title': title,
              'message': message,
              'severity': severity,
              'plantType': 'Lechuga',
              'timestamp': fecha,
            });
          }

          if (activeAlerts.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.check_circle_outline,
                    size: 80,
                    color: Colors.grey.shade400,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No hay alertas',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey.shade600,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Todas las condiciones están óptimas',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _sectionTitle('Alertas Activas', activeAlerts.length),
              const SizedBox(height: 8),
              ...activeAlerts.map((alert) => _buildAlertCardFromData(alert)),
            ],
          );
        },
      ),
    );
  }

  Widget _sectionTitle(String title, int count) {
    return Row(
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: const Color(0xFF2196F3),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            count.toString(),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAlertCardFromData(Map<String, dynamic> alert) {
    final severityConfig = _getSeverityConfig(alert['severity']);

    return Card(
      elevation: 2,
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: severityConfig['color'],
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: severityConfig['color'].withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    severityConfig['icon'],
                    color: severityConfig['color'],
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              alert['title'],
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                          ),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF2196F3),
                              shape: BoxShape.circle,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text(
                        severityConfig['label'],
                        style: TextStyle(
                          fontSize: 12,
                          color: severityConfig['color'],
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              alert['message'],
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black87,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(Icons.eco, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  alert['plantType'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                const Spacer(),
                Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                const SizedBox(width: 4),
                Text(
                  alert['timestamp'],
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Map<String, dynamic> _getSeverityConfig(String severity) {
    switch (severity) {
      case 'critical':
        return {
          'color': Colors.red,
          'icon': Icons.error,
          'label': 'CRÍTICO',
        };
      case 'high':
        return {
          'color': Colors.orange,
          'icon': Icons.warning,
          'label': 'ALTO',
        };
      case 'medium':
        return {
          'color': Colors.amber,
          'icon': Icons.info,
          'label': 'MEDIO',
        };
      case 'low':
        return {
          'color': Colors.blue,
          'icon': Icons.notifications,
          'label': 'BAJO',
        };
      default:
        return {
          'color': Colors.grey,
          'icon': Icons.notifications,
          'label': 'INFO',
        };
    }
  }
}
