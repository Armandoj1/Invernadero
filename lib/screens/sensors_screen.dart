import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/firebase_service.dart';
import '../models/sensor_data.dart';
import '../models/device_state.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SensorsScreen extends StatefulWidget {
  const SensorsScreen({Key? key}) : super(key: key);

  @override
  State<SensorsScreen> createState() => _SensorsScreenState();
}

class _SensorsScreenState extends State<SensorsScreen> {
  final FirebaseService firebaseService = FirebaseService();
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';
  int _fanSpeed = 0;
  int _irrigationDurationSec = 0;
  int _lightLevel = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.home,
                color: Colors.white,
                size: 20,
              ),
            ),
            const SizedBox(width: 8),
            const Text(
              'AgriSense Pro',
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications, color: Colors.black),
            onPressed: () {},
          ),
        ],
      ),
      body: StreamBuilder<String>(
        stream: firebaseService.getSelectedPlantType(userId),
        builder: (context, plantSnapshot) {
          final selectedPlant = plantSnapshot.data ?? 'Lechuga';
          return StreamBuilder<List<Map<String, dynamic>>>(
            stream: firebaseService.getRtdbHistorical(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final entries = snapshot.data ?? <Map<String, dynamic>>[];
              if (entries.isEmpty) {
                return const Center(child: Text('Sin lecturas en RTDB aún.'));
              }

              // Buscar la última lectura para la planta seleccionada
              Map<String, dynamic>? latestForPlant;
              for (final item in entries.reversed) {
                if ((item['planta'] ?? '') == selectedPlant) {
                  latestForPlant = item;
                  break;
                }
              }
              final latest = latestForPlant ?? entries.last;

              final num tempNum = (latest['temperatura'] ?? 0) as num;
              final num humAirNum = (latest['humedad_aire'] ?? 0) as num;
              final num humSoilNum = (latest['humedad_suelo'] ?? 0) as num;
              final double temperatura = tempNum.toDouble();
              final double humedadAire = humAirNum.toDouble();
              final double humedadSuelo = humSoilNum.toDouble();
              final String fecha = (latest['fecha'] ?? '') as String;

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Sección de modo de control IA/Manual y controles manuales
                    StreamBuilder<String>(
                      stream: firebaseService.getControlMode(userId),
                      builder: (context, modeSnapshot) {
                        final mode = modeSnapshot.data ?? 'automatic';
                        final isManual = mode == 'manual';
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Card(
                              elevation: 2,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                              child: Padding(
                                padding: const EdgeInsets.all(16),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text(
                                      'Modo de Control',
                                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 12),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => firebaseService.saveControlMode(userId, 'automatic'),
                                            icon: const Icon(Icons.auto_awesome),
                                            label: const Text('Automático con IA'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: mode == 'automatic' ? Colors.blue : Colors.grey[200],
                                              foregroundColor: mode == 'automatic' ? Colors.white : Colors.black87,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: ElevatedButton.icon(
                                            onPressed: () => firebaseService.saveControlMode(userId, 'manual'),
                                            icon: const Icon(Icons.handyman),
                                            label: const Text('Manual'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: mode == 'manual' ? Colors.blue : Colors.grey[200],
                                              foregroundColor: mode == 'manual' ? Colors.white : Colors.black87,
                                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            if (isManual) ...[
                              const SizedBox(height: 12),
                              _manualControlsCard(),
                            ],
                          ],
                        );
                      },
                    ),
                    const SizedBox(height: 16),
                    // Temperatura
                    _buildSensorDetailCard(
                      icon: Icons.thermostat,
                      iconColor: Colors.red,
                      title: 'Temperatura',
                      sensorId: 'Sensor ID: TEMP-001',
                      value: '${temperatura.toStringAsFixed(1)}°C',
                      valueColor: Colors.red,
                      status: 'Normal',
                      minValue: '18°C',
                      optimalValue: 'Óptimo: 22-26°C',
                      maxValue: '32°C',
                      lastReading: 'Última lectura: $fecha',
                      precision: 'Precisión: 99.8%',
                    ),

                    const SizedBox(height: 16),

                    // Humedad aire
                    _buildSensorDetailCard(
                      icon: Icons.water_drop,
                      iconColor: Colors.blue,
                      title: 'Humedad aire',
                      sensorId: 'Sensor ID: HUM-001',
                      value: '${humedadAire.toStringAsFixed(0)}%',
                      valueColor: Colors.blue,
                      status: 'Normal',
                      minValue: '40%',
                      optimalValue: 'Óptimo: 60-80%',
                      maxValue: '95%',
                      lastReading: 'Última lectura: $fecha',
                      precision: 'Precisión: 99.5%',
                    ),

                    const SizedBox(height: 16),

                    // Humedad suelo
                    _buildSensorDetailCard(
                      icon: Icons.grass,
                      iconColor: Colors.green,
                      title: 'Humedad suelo',
                      sensorId: 'Sensor ID: SOIL-001',
                      value: '${humedadSuelo.toStringAsFixed(0)}%',
                      valueColor: Colors.green,
                      status: 'Normal',
                      minValue: '30%',
                      optimalValue: 'Óptimo: 60-80%',
                      maxValue: '95%',
                      lastReading: 'Última lectura: $fecha',
                      precision: 'Precisión: 98.5%',
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 1,
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
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 3) {
            Navigator.pushReplacementNamed(context, '/alerts');
          } else if (index == 4) {
            Navigator.pushReplacementNamed(context, '/cultivos');
          }
        },
      ),
    );
  }

  Widget _buildSensorDetailCard({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String sensorId,
    required String value,
    required Color valueColor,
    required String status,
    required String minValue,
    required String optimalValue,
    required String maxValue,
    required String lastReading,
    required String precision,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
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
                    color: iconColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    icon,
                    color: iconColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      sensorId,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: valueColor,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  minValue,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  optimalValue,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: Colors.green,
                  ),
                ),
                Text(
                  maxValue,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: 0.6,
              backgroundColor: Colors.grey[200],
              valueColor: AlwaysStoppedAnimation<Color>(iconColor),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  lastReading,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
                Text(
                  precision,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.green,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _manualControlsCard() {
    return StreamBuilder<DeviceState?>(
      stream: firebaseService.getCurrentDeviceState(userId),
      builder: (context, stateSnapshot) {
        final current = stateSnapshot.data ?? DeviceState.initial(userId);
        _fanSpeed = current.fanSpeed;
        _irrigationDurationSec = current.irrigationDurationSec;
        _lightLevel = current.lightLevel;
        return Card(
          elevation: 2,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Controles Manuales', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                // Ventilar – velocidad ventilador
                Row(
                  children: const [
                    Icon(Icons.air, color: Colors.blue),
                    SizedBox(width: 8),
                    Text('Ventilar – velocidad ventilador'),
                  ],
                ),
                Slider(
                  value: _fanSpeed.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 10,
                  label: '$_fanSpeed%',
                  onChanged: (v) => setState(() => _fanSpeed = v.round()),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      final state = DeviceState(
                        pumpActive: current.pumpActive,
                        fanActive: _fanSpeed > 0,
                        lightsActive: current.lightsActive,
                        heaterActive: current.heaterActive,
                        fanSpeed: _fanSpeed,
                        irrigationDurationSec: current.irrigationDurationSec,
                        lightLevel: current.lightLevel,
                        timestamp: DateTime.now(),
                        userId: userId,
                      );
                      firebaseService.saveDeviceState(state);
                    },
                    child: const Text('Aplicar Ventilación'),
                  ),
                ),
                const SizedBox(height: 12),
                // Regar – duración seg/min
                Row(
                  children: const [
                    Icon(Icons.water, color: Colors.teal),
                    SizedBox(width: 8),
                    Text('Regar – duración seg/min'),
                  ],
                ),
                Slider(
                  value: _irrigationDurationSec.toDouble(),
                  min: 0,
                  max: 600,
                  divisions: 12,
                  label: '${(_irrigationDurationSec / 60).toStringAsFixed(1)} min',
                  onChanged: (v) => setState(() => _irrigationDurationSec = v.round()),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      final state = DeviceState(
                        pumpActive: _irrigationDurationSec > 0,
                        fanActive: current.fanActive,
                        lightsActive: current.lightsActive,
                        heaterActive: current.heaterActive,
                        fanSpeed: current.fanSpeed,
                        irrigationDurationSec: _irrigationDurationSec,
                        lightLevel: current.lightLevel,
                        timestamp: DateTime.now(),
                        userId: userId,
                      );
                      firebaseService.saveDeviceState(state);
                    },
                    child: const Text('Aplicar Riego'),
                  ),
                ),
                const SizedBox(height: 12),
                // Calefacción – aumentar/disminuir luminosidad (ajuste de luz)
                Row(
                  children: const [
                    Icon(Icons.wb_incandescent, color: Colors.amber),
                    SizedBox(width: 8),
                    Text('Calefacción – aumentar/disminuir'),
                  ],
                ),
                Slider(
                  value: _lightLevel.toDouble(),
                  min: 0,
                  max: 100,
                  divisions: 10,
                  label: '$_lightLevel%',
                  onChanged: (v) => setState(() => _lightLevel = v.round()),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton(
                    onPressed: () {
                      final state = DeviceState(
                        pumpActive: current.pumpActive,
                        fanActive: current.fanActive,
                        lightsActive: _lightLevel > 0,
                        heaterActive: current.heaterActive,
                        fanSpeed: current.fanSpeed,
                        irrigationDurationSec: current.irrigationDurationSec,
                        lightLevel: _lightLevel,
                        timestamp: DateTime.now(),
                        userId: userId,
                      );
                      firebaseService.saveDeviceState(state);
                    },
                    child: const Text('Aplicar Luminosidad'),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}