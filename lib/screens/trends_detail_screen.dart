import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:fl_chart/fl_chart.dart';
import '../services/firebase_service.dart';
import '../controllers/auth_controller.dart';

class TrendsDetailScreen extends StatelessWidget {
  const TrendsDetailScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text('Tendencias'),
        backgroundColor: const Color(0xFF2196F3),
        actions: [
          // Notificaciones con conteo dinámico
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: service.getRtdbHistorical(),
            builder: (context, snapshot) {
              int activeCount = 0;
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                Map<String, dynamic>? latest;
                for (final item in snapshot.data!.reversed) {
                  if ((item['planta'] ?? '') == 'Lechuga') { latest = item; break; }
                }
                latest ??= snapshot.data!.last;

                final double temp = ((latest['temperatura'] ?? 0) as num).toDouble();
                final double humAir = ((latest['humedad_aire'] ?? 0) as num).toDouble();
                final double humSoil = ((latest['humedad_suelo'] ?? 0) as num).toDouble();
                if (!(temp >= 15 && temp <= 20)) activeCount++;
                if (!(humAir >= 70 && humAir <= 80)) activeCount++;
                if (!(humSoil >= 60 && humSoil <= 80)) activeCount++;
              }

              return Stack(
                alignment: Alignment.center,
                children: [
                  IconButton(
                    icon: const Icon(Icons.notifications, color: Colors.white),
                    onPressed: () { Navigator.pushNamed(context, '/alerts'); },
                  ),
                  if (activeCount > 0)
                    Positioned(
                      top: 8,
                      right: 8,
                      child: Container(
                        padding: const EdgeInsets.all(4),
                        decoration: const BoxDecoration(
                          color: Colors.red,
                          shape: BoxShape.circle,
                        ),
                        child: Text(
                          '$activeCount',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                ],
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Cerrar sesión',
            onPressed: () async {
              final auth = Get.find<AuthController>();
              await auth.signOut();
              Get.offAllNamed('/login');
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Evolución de sensores (24 horas)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Expanded(
              child: Card(
                elevation: 1,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: StreamBuilder<List<Map<String, dynamic>>>(
                    stream: service.getRtdbHistorical(),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return const Center(child: CircularProgressIndicator());
                      }
                      final data = snapshot.data ?? <Map<String, dynamic>>[];
                      return _buildDetailedChart(data);
                    },
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 16,
              runSpacing: 8,
              children: const [
                _Legend(color: Colors.red, label: 'Temperatura (°C)'),
                _Legend(color: Colors.blue, label: 'Humedad aire (%)'),
                _Legend(color: Colors.green, label: 'Humedad suelo (%)'),
                _Legend(color: Color(0xFF81C784), label: 'Rango óptimo Temp'),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailedChart(List<Map<String, dynamic>> historicalData) {
    final filtered = <Map<String, dynamic>>[];
    // Tomar últimos 24 para mayor detalle
    final raw = historicalData.length > 24
        ? historicalData.sublist(historicalData.length - 24)
        : historicalData;
    for (final entry in raw) {
      if ((entry['planta'] ?? '') == 'Lechuga') filtered.add(entry);
    }

    if (filtered.isEmpty) {
      return const Center(child: Text('Sin datos de Lechuga en el periodo'));
    }

    final temperatureData = <FlSpot>[];
    final humidityData = <FlSpot>[];
    final soilHumidityData = <FlSpot>[];

    for (int i = 0; i < filtered.length; i++) {
      final e = filtered[i];
      temperatureData.add(FlSpot(i.toDouble(), ((e['temperatura'] ?? 0) as num).toDouble()));
      humidityData.add(FlSpot(i.toDouble(), ((e['humedad_aire'] ?? 0) as num).toDouble()));
      soilHumidityData.add(FlSpot(i.toDouble(), ((e['humedad_suelo'] ?? 0) as num).toDouble()));
    }

    const double optimalTempMin = 15.0;
    const double optimalTempMax = 20.0;
    final maxX = (filtered.length - 1).toDouble();

    return LineChart(
      LineChartData(
        gridData: FlGridData(
          show: true,
          horizontalInterval: 10,
          verticalInterval: 3,
          getDrawingHorizontalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
          getDrawingVerticalLine: (value) => FlLine(color: Colors.grey.shade200, strokeWidth: 1),
        ),
        titlesData: FlTitlesData(
          bottomTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 28,
              getTitlesWidget: (value, meta) {
                final idx = value.toInt();
                if (idx >= 0 && idx < filtered.length) {
                  final fecha = filtered[idx]['fecha']?.toString() ?? '';
                  final parts = fecha.split(' ');
                  if (parts.length >= 2) {
                    final horaParts = parts[1].split(':');
                    if (horaParts.length >= 2) {
                      return Text('${horaParts[0]}:${horaParts[1]}', style: const TextStyle(fontSize: 10));
                    }
                  }
                }
                return const Text('');
              },
            ),
          ),
          leftTitles: AxisTitles(
            sideTitles: SideTitles(
              showTitles: true,
              reservedSize: 32,
              getTitlesWidget: (value, meta) => Text(value.toInt().toString(), style: const TextStyle(fontSize: 10)),
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
          // Banda óptima de temperatura (relleno entre dos líneas)
          LineChartBarData(
            spots: [FlSpot(0, optimalTempMin), FlSpot(maxX, optimalTempMin)],
            isCurved: false,
            color: const Color(0xFF81C784),
            barWidth: 1,
            dotData: FlDotData(show: false),
            belowBarData: BarAreaData(
              show: true,
              color: const Color(0xFF81C784).withOpacity(0.15),
              cutOffY: optimalTempMax,
              applyCutOffY: true,
            ),
          ),
          LineChartBarData(
            spots: [FlSpot(0, optimalTempMax), FlSpot(maxX, optimalTempMax)],
            isCurved: false,
            color: const Color(0xFF81C784),
            barWidth: 1,
            dotData: FlDotData(show: false),
          ),
          // Temperatura
          LineChartBarData(
            spots: temperatureData,
            isCurved: true,
            color: Colors.red,
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
          // Humedad aire
          LineChartBarData(
            spots: humidityData,
            isCurved: true,
            color: Colors.blue,
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
          // Humedad suelo
          LineChartBarData(
            spots: soilHumidityData,
            isCurved: true,
            color: Colors.green,
            barWidth: 3,
            dotData: FlDotData(show: false),
          ),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 6),
        Text(label, style: const TextStyle(color: Colors.grey, fontSize: 12)),
      ],
    );
  }
}