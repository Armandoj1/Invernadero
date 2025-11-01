import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class LettuceDetailScreen extends StatelessWidget {
  LettuceDetailScreen({Key? key}) : super(key: key);

  final FirebaseService _firebaseService = FirebaseService();

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
                color: Colors.green,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.spa, color: Colors.white, size: 20),
            ),
            const SizedBox(width: 8),
            const Text('Lechuga – Historial', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: _firebaseService.getRtdbHistorical(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final entries = snapshot.data ?? <Map<String, dynamic>>[];
          final lettuceEntries = entries.where((e) => (e['planta'] ?? '') == 'Lechuga').toList();
          if (lettuceEntries.isEmpty) {
            return const Center(child: Text('Sin lecturas de Lechuga aún.'));
          }
          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: lettuceEntries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (context, index) {
              final item = lettuceEntries[lettuceEntries.length - 1 - index];
              final String fecha = (item['fecha'] ?? '') as String;
              final double temperatura = ((item['temperatura'] ?? 0) as num).toDouble();
              final double humedadAire = ((item['humedad_aire'] ?? 0) as num).toDouble();
              final double humedadSuelo = ((item['humedad_suelo'] ?? 0) as num).toDouble();
              return Card(
                elevation: 2,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(fecha, style: const TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          _metricChip(Icons.thermostat, Colors.red, '${temperatura.toStringAsFixed(1)}°C'),
                          const SizedBox(width: 8),
                          _metricChip(Icons.water_drop, Colors.blue, '${humedadAire.toStringAsFixed(0)}%'),
                          const SizedBox(width: 8),
                          _metricChip(Icons.grass, Colors.green, '${humedadSuelo.toStringAsFixed(0)}%'),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 4,
        type: BottomNavigationBarType.fixed,
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Dashboard'),
          BottomNavigationBarItem(icon: Icon(Icons.sensors), label: 'Sensores'),
          BottomNavigationBarItem(icon: Icon(Icons.auto_awesome), label: 'Control IA'),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: 'Alertas'),
          BottomNavigationBarItem(icon: Icon(Icons.eco), label: 'Cultivos'),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: 'Reportes'),
        ],
        onTap: (index) {
          if (index == 0) {
            Navigator.pushReplacementNamed(context, '/dashboard');
          } else if (index == 1) {
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

  Widget _metricChip(IconData icon, Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(width: 6),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}