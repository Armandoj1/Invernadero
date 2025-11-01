// screens/dashboard_screen.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/firebase_service.dart';
import 'package:fl_chart/fl_chart.dart';
import '../controllers/auth_controller.dart';

class DashboardScreen extends StatelessWidget {
  final String userId;
  const DashboardScreen({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final firebaseService = FirebaseService();

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: Row(
          children: [
            const Text(
              'AgriSensePro',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: 8),
            StreamBuilder<String>(
              stream: FirebaseService().getSelectedPlantType(userId),
              builder: (context, snapshot) {
                final plant = snapshot.data ?? 'Lechuga';
                return Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.white24,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    plant,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.white,
                    ),
                  ),
                );
              },
            ),
          ],
        ),
        backgroundColor: const Color(0xFF2196F3),
        actions: [
          // Notificaciones con conteo dinámico de alertas activas
          StreamBuilder<List<Map<String, dynamic>>>(
            stream: firebaseService.getRtdbHistorical(),
            builder: (context, snapshot) {
              int activeCount = 0;
              if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                // Encontrar la última lectura para Lechuga
                Map<String, dynamic>? latest;
                for (final item in snapshot.data!.reversed) {
                  if ((item['planta'] ?? '') == 'Lechuga') { latest = item; break; }
                }
                latest ??= snapshot.data!.last;

                // Evaluar alertas activas sobre la última lectura
                final double temp = ((latest['temperatura'] ?? 0) as num).toDouble();
                final double humAir = ((latest['humedad_aire'] ?? 0) as num).toDouble();
                final double humSoil = ((latest['humedad_suelo'] ?? 0) as num).toDouble();

                // Temperatura (Lechuga)
                if (!(temp >= 15 && temp <= 20)) { activeCount++; }
                // Humedad aire 70–80%
                if (!(humAir >= 70 && humAir <= 80)) { activeCount++; }
                // Humedad suelo 60–80%
                if (!(humSoil >= 60 && humSoil <= 80)) { activeCount++; }
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

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Sensor Cards Grid (responsive)
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.8,
                  children: [
                    _sensorCard(
                      title: 'Temperatura',
                      value: '${temp.toStringAsFixed(1)}°C',
                      icon: Icons.thermostat_outlined,
                      color: Colors.blue,
                    ),
                    _sensorCard(
                      title: 'Humedad aire',
                      value: '${humAir.toStringAsFixed(0)}%',
                      icon: Icons.water_drop_outlined,
                      color: Colors.blue,
                    ),
                    _sensorCard(
                      title: 'Humedad suelo',
                      value: '${humSoil.toStringAsFixed(0)}%',
                      icon: Icons.grass,
                      color: Colors.green,
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                
                // System Card Simplified
                _systemCardSimplified(context),
                const SizedBox(height: 16),
                
                // Trends Chart
                _trendsCard(context, entries),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 0,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.sensors),
            label: 'Sensores',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.auto_awesome),
            label: 'Control IA',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.notifications),
            label: 'Alertas',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.eco),
            label: 'Cultivos',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bar_chart),
            label: 'Reportes',
          ),
        ],
        onTap: (index) {
          if (index == 1) {
            Navigator.pushReplacementNamed(context, '/sensors');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/alerts');
          } else if (index == 4) {
            Navigator.pushReplacementNamed(context, '/cultivos');
          }
        },
      ),
    );
  }

  Widget _sensorCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
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
          Text(
            title,
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              Icon(icon, color: color),
            ],
          ),
        ],
      ),
    );
  }

  Widget _recommendationCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2196F3),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
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
              Icon(Icons.star, color: Colors.white),
              SizedBox(width: 8),
              Text(
                'Recomendación IA',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Condiciones óptimas mantenidas. El sistema está funcionando eficientemente. Continuar con el programa actual.',
            style: TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Aplicar Automáticamente'),
          ),
        ],
      ),
    );
  }

  Widget _systemStatusCard() {
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
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statusItem(
                icon: Icons.auto_awesome,
                label: 'Control IA',
                status: 'Activo',
                color: Colors.green,
              ),
              _statusItem(
                icon: Icons.sensors,
                label: 'Sensores',
                status: '8/8',
                color: Colors.blue,
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statusItem(
                icon: Icons.water,
                label: 'Riego Auto',
                status: 'Programado',
                color: Colors.orange,
              ),
              _statusItem(
                icon: Icons.thermostat,
                label: 'Clima',
                status: 'Óptimo',
                color: Colors.purple,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _statusItem({
    required IconData icon,
    required String label,
    required String status,
    required Color color,
  }) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: color, size: 16),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          status,
          style: TextStyle(
            color: color,
            fontWeight: FontWeight.w500,
            fontSize: 14,
          ),
        ),
      ],
    );
  }

  // Card simplificado para el sistema según requerimiento
  Widget _systemCardSimplified(BuildContext context) {
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
            'Sistema',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _statusItem(
                icon: Icons.psychology_alt,
                label: 'Control IA',
                status: 'Inactivo',
                color: Colors.grey,
              ),
              _statusItem(
                icon: Icons.sensors,
                label: 'Sensores',
                status: '3/3',
                color: Colors.blue,
              ),
              _statusItem(
                icon: Icons.water,
                label: 'Riego',
                status: 'Manual',
                color: Colors.orange,
              ),
            ],
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () {
                Navigator.pushReplacementNamed(context, '/sensors');
              },
              icon: const Icon(Icons.tune, color: Colors.blue),
              label: const Text(
                'Abrir control manual',
                style: TextStyle(color: Colors.blue),
              ),
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.blue),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
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
                child: const Text(
                  'Ver Más',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
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