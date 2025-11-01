// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/auth_controller.dart';
import 'notifications_screen.dart';

class DashboardScreen extends StatelessWidget {
  final String userId;
  const DashboardScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BCD4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            Scaffold.of(context).openDrawer();
          },
        ),
        title: StreamBuilder<String>(
          stream: FirebaseService().getSelectedPlantType(userId),
          builder: (context, snapshot) {
            final plant = snapshot.data ?? 'Lechuga';
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'AgriSense Pro',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
                Text(
                  '$plant - Sector A1',
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.white70,
                  ),
                ),
              ],
            );
          },
        ),
        actions: [
          // Notificaciones con conteo dinámico de notificaciones no leídas
          StreamBuilder<int>(
            stream: NotificationService().getUnreadCount(userId),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;

              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_outlined, color: Colors.white),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Get.to(() => const NotificationsScreen());
                },
              );
            },
          ),
          // Botón de cerrar sesión
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              try {
                // Usar AuthController vía GetX
                final auth = Get.find<AuthController>();
                await auth.signOut();
                Get.offAllNamed('/login');
              } catch (_) {
                // Si GetX no está disponible por alguna razón, no romper la UI
                Navigator.pushNamedAndRemoveUntil(context, '/login', (route) => false);
              }
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: StreamBuilder(
        stream: firebaseService.getRtdbHistorical(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = snapshot.data as List<Map<String, dynamic>>? ?? <Map<String, dynamic>>[];
          if (entries.isEmpty) {
            return const Center(child: Text('Esperando datos de sensores...'));
          }

          // Buscar última lectura de Lechuga
          Map<String, dynamic>? latest;
          for (final item in entries.reversed) {
            if ((item['planta'] ?? '') == 'Lechuga') { latest = item; break; }
          }
          latest ??= entries.last;
          final double temp = ((latest['temperatura'] ?? 0) as num).toDouble();
          final double humAir = ((latest['humedad_aire'] ?? 0) as num).toDouble();
          final double humSoil = ((latest['humedad_suelo'] ?? 0) as num).toDouble();

          // Evaluar alertas activas sobre la última lectura
          int activeAlertCount = 0;
          // Temperatura (Lechuga: 15-20°C óptimo)
          if (!(temp >= 15 && temp <= 20)) { activeAlertCount++; }
          // Humedad aire 70–80%
          if (!(humAir >= 70 && humAir <= 80)) { activeAlertCount++; }
          // Humedad suelo 60–80%
          if (!(humSoil >= 60 && humSoil <= 80)) { activeAlertCount++; }

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sensor Cards Grid (2x2 grid) - mejoradas
                Row(
                  children: [
                    Expanded(
                      child: _modernSensorCard(
                        title: 'Temperatura',
                        value: '${temp.toStringAsFixed(1)}°C',
                        icon: Icons.thermostat,
                        gradient: const LinearGradient(
                          colors: [Color(0xFFFF6B6B), Color(0xFFFF8E53)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _modernSensorCard(
                        title: 'Humedad Aire',
                        value: '${humAir.toStringAsFixed(0)}%',
                        icon: Icons.air,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF5E72E4), Color(0xFF825EE4)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _modernSensorCard(
                        title: 'Humedad Suelo',
                        value: '${humSoil.toStringAsFixed(0)}%',
                        icon: Icons.water_drop,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF4FC3F7), Color(0xFF29B6F6)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _modernSensorCard(
                        title: 'Estado IA',
                        value: 'Óptimo',
                        icon: Icons.psychology,
                        gradient: const LinearGradient(
                          colors: [Color(0xFF2DCE89), Color(0xFF11998E)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // AI Recommendation Card with gradient
                _aiRecommendationCard(),
                const SizedBox(height: 12),

                // System Card Simplified
                _systemCardSimplified(context, activeAlertCount),
                const SizedBox(height: 12),

                // Trends Chart
                _trendsCard(context, entries),
                const SizedBox(height: 12),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _modernSensorCard({
    required String title,
    required String value,
    required IconData icon,
    required Gradient gradient,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, color: Colors.white, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _aiRecommendationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Color(0xFF00BCD4), Color(0xFF2196F3)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF00BCD4).withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: const [
              Icon(Icons.lightbulb_outline, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Recomendación IA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          const Text(
            'Las condiciones actuales son óptimas para el crecimiento de tu cultivo. Todos los parámetros están dentro del rango ideal.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 13,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // Card simplificado para el sistema según requerimiento
  Widget _systemCardSimplified(BuildContext context, int activeAlertCount) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Estado Actual del Sistema',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _modernStatusBadge(
                  label: 'Control IA',
                  status: 'Activo',
                  color: const Color(0xFF2DCE89),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _modernStatusBadge(
                  label: 'Alertas',
                  status: activeAlertCount > 0 ? '$activeAlertCount Activas' : 'Normal',
                  color: activeAlertCount > 0 ? const Color(0xFFFB6340) : const Color(0xFF2DCE89),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: _modernStatusBadge(
                  label: 'Riego Auto',
                  status: 'Programado',
                  color: const Color(0xFF8965E0),
                ),
              ),
              const SizedBox(width: 6),
              Expanded(
                child: _modernStatusBadge(
                  label: 'Sensores',
                  status: '3/3',
                  color: const Color(0xFF5E72E4),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _modernStatusBadge({
    required String label,
    required String status,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 6),
          Flexible(
            child: Text(
              '$label: ',
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey.shade700,
                fontWeight: FontWeight.w500,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            status,
            style: TextStyle(
              fontSize: 11,
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _trendsCard(BuildContext context, dynamic data) {
    final firebaseService = FirebaseService();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Tendencias (24h)',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pushNamed(context, '/trends');
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Ver Más',
                  style: TextStyle(
                    color: Color(0xFF00BCD4),
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: firebaseService.getRtdbHistorical(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (!snapshot.hasData || snapshot.data!.isEmpty) {
                return SizedBox(
                  height: 200,
                  child: _buildChart(),
                );
              }

              return SizedBox(
                height: 220,
                child: _buildChartFromFirebase(snapshot.data!),
              );
            },
          ),
          const SizedBox(height: 8),
          Wrap(
            alignment: WrapAlignment.center,
            spacing: 16,
            runSpacing: 4,
            children: [
              _chartLegend(Colors.red, 'Temperatura (°C)'),
              _chartLegend(Colors.blue, 'Humedad aire (%)'),
              _chartLegend(Colors.green, 'Humedad suelo (%)'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _chartLegend(Color color, String label) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(
          label,
          style: const TextStyle(color: Colors.grey, fontSize: 11),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildChartFromFirebase(List<Map<String, dynamic>> historicalData) {
    // Preparar datos filtrando solo "Lechuga" y limitar a 12 últimos
    final temperatureData = <FlSpot>[];
    final humidityData = <FlSpot>[];
    final soilHumidityData = <FlSpot>[];

    final raw = historicalData.length > 12
        ? historicalData.sublist(historicalData.length - 12)
        : historicalData;

    final filtered = <Map<String, dynamic>>[];
    for (final entry in raw) {
      if ((entry['planta'] ?? '') == 'Lechuga') {
        filtered.add(entry);
      }
    }

    // Si no hay datos, mostrar un placeholder amigable sin romper el gráfico
    if (filtered.isEmpty) {
      return Container(
        height: 180,
        alignment: Alignment.center,
        child: const Text(
          'Sin datos de Lechuga en el periodo',
          style: TextStyle(color: Colors.grey),
        ),
      );
    }

    for (int i = 0; i < filtered.length; i++) {
      final entry = filtered[i];
      final temp = (entry['temperatura'] as num?)?.toDouble() ?? 0.0;
      final humidity = (entry['humedad_aire'] as num?)?.toDouble() ?? 0.0;
      final soilHumidity = (entry['humedad_suelo'] as num?)?.toDouble() ?? 0.0;

      // El eje X usa el índice del elemento filtrado
      final x = i.toDouble();
      temperatureData.add(FlSpot(x, temp));
      humidityData.add(FlSpot(x, humidity));
      soilHumidityData.add(FlSpot(x, soilHumidity));
    }

    // Rango óptimo de Lechuga según especificación
    const double optimalTempMin = 15.0;
    const double optimalTempMax = 20.0;

    final maxX = (filtered.length - 1).toDouble();

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < filtered.length) {
                  final fecha = filtered[idx]['fecha']?.toString() ?? '';
                  final parts = fecha.split(' ');
                  if (parts.length >= 2) {
                    final horaParts = parts[1].split(':');
                    if (horaParts.length >= 2) {
                      return Text(
                        '${horaParts[0]}:${horaParts[1]}',
                        style: const TextStyle(fontSize: 8),
                      );
                    }
                  }
                }
                return const Text('');
              },
              reservedSize: 22,
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              getTitlesWidget: (value, meta) {
                return Text(
                  value.toInt().toString(),
                  style: const TextStyle(fontSize: 8),
                );
              },
              reservedSize: 22,
            ),
          ),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: maxX,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          // Zona óptima de temperatura
          LineChartBarData(
            spots: [
              FlSpot(0, optimalTempMin),
              FlSpot(maxX, optimalTempMin),
            ],
            isCurved: false,
            color: Colors.green.withOpacity(0.3),
            barWidth: 1,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: Colors.green.withOpacity(0.1),
              cutOffY: optimalTempMax,
              applyCutOffY: true,
            ),
          ),
          LineChartBarData(
            spots: [
              FlSpot(0, optimalTempMax),
              FlSpot(maxX, optimalTempMax),
            ],
            isCurved: false,
            color: Colors.green.withOpacity(0.3),
            barWidth: 1,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
          ),
          // Datos de temperatura
          LineChartBarData(
            spots: temperatureData,
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(
              show: true,
              getDotPainter: (spot, percent, barData, index) {
                final isOptimal = spot.y >= optimalTempMin && spot.y <= optimalTempMax;
                return FlDotCirclePainter(
                  radius: 4,
                  color: isOptimal ? Colors.green : Colors.red,
                  strokeWidth: 1,
                  strokeColor: Colors.white,
                );
              },
            ),
            belowBarData: BarAreaData(show: false),
          ),
          // Datos de humedad
          LineChartBarData(
            spots: humidityData,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
          // Datos de humedad de suelo
          LineChartBarData(
            spots: soilHumidityData,
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    // Simulated data for the chart
    final temperatureData = [
      FlSpot(0, 25),
      FlSpot(1, 26),
      FlSpot(2, 27),
      FlSpot(3, 25),
      FlSpot(4, 26),
      FlSpot(5, 28),
      FlSpot(6, 27),
      FlSpot(7, 25),
      FlSpot(8, 26),
      FlSpot(9, 27),
      FlSpot(10, 26),
      FlSpot(11, 25),
    ];

    final humidityData = [
      FlSpot(0, 70),
      FlSpot(1, 75),
      FlSpot(2, 80),
      FlSpot(3, 75),
      FlSpot(4, 70),
      FlSpot(5, 75),
      FlSpot(6, 80),
      FlSpot(7, 75),
      FlSpot(8, 70),
      FlSpot(9, 75),
      FlSpot(10, 80),
      FlSpot(11, 75),
    ];

    return LineChart(
      LineChartData(
        gridData: FlGridData(show: false),
        titlesData: FlTitlesData(show: false),
        borderData: FlBorderData(show: false),
        minX: 0,
        maxX: 11,
        minY: 0,
        maxY: 100,
        lineBarsData: [
          LineChartBarData(
            spots: temperatureData,
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
          LineChartBarData(
            spots: humidityData,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(show: false),
          ),
        ],
      ),
    );
  }
}
