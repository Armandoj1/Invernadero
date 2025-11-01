import 'package:flutter/material.dart';
import '../services/firebase_service.dart';

class AlertsScreen extends StatelessWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final service = FirebaseService();
    return Scaffold(
      appBar: AppBar(
        title: const Text('Alertas'),
        backgroundColor: const Color(0xFF2196F3),
      ),
      body: StreamBuilder<List<Map<String, dynamic>>>(
        stream: service.getRtdbHistorical(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final data = snapshot.data ?? <Map<String, dynamic>>[];
          if (data.isEmpty) {
            return const Center(child: Text('Sin datos todavía.'));
          }

          // Última lectura para Lechuga
          Map<String, dynamic>? latest;
          for (final item in data.reversed) {
            if ((item['planta'] ?? '') == 'Lechuga') { latest = item; break; }
          }
          latest ??= data.last;

          final activeAlerts = _evaluateAlerts(latest);
          final historyAlerts = _buildHistoryAlerts(data);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _sectionTitle('Alertas Activas'),
                const SizedBox(height: 8),
                ...activeAlerts.map(_alertCard),
                const SizedBox(height: 16),

                _sectionTitle('Historial de Alertas'),
                const SizedBox(height: 8),
                ...historyAlerts.map(_historyCard),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: 3,
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
          } else if (index == 4) {
            Navigator.pushReplacementNamed(context, '/cultivos');
          }
        },
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  List<Map<String, dynamic>> _evaluateAlerts(Map<String, dynamic> entry) {
    final double temp = ((entry['temperatura'] ?? 0) as num).toDouble();
    final double humAir = ((entry['humedad_aire'] ?? 0) as num).toDouble();
    final double humSoil = ((entry['humedad_suelo'] ?? 0) as num).toDouble();
    final String fecha = (entry['fecha'] ?? '') as String;

    final List<Map<String, dynamic>> alerts = [];

    // Temperatura - Lechuga
    String tempStatus;
    if (temp < 7) {
      tempStatus = 'Crítica baja';
    } else if (temp < 15) {
      tempStatus = 'Ligeramente baja';
    } else if (temp <= 20) {
      tempStatus = 'Óptima';
    } else if (temp <= 24) {
      tempStatus = 'Ligeramente alta';
    } else if (temp <= 27) {
      tempStatus = 'Alta tolerada';
    } else {
      tempStatus = 'Crítica alta';
    }
    if (tempStatus != 'Óptima') {
      alerts.add({
        'title': 'Temperatura del aire',
        'value': '${temp.toStringAsFixed(1)}°C',
        'status': tempStatus,
        'detail': 'Detectada $fecha',
        'color': Colors.orange,
      });
    }

    // Humedad del aire 70–80%
    String humAirStatus;
    if (humAir < 70) {
      humAirStatus = 'Baja';
    } else if (humAir <= 80) {
      humAirStatus = 'Óptima';
    } else {
      humAirStatus = 'Alta';
    }
    if (humAirStatus != 'Óptima') {
      alerts.add({
        'title': 'Humedad del aire',
        'value': '${humAir.toStringAsFixed(0)}%',
        'status': humAirStatus,
        'detail': 'Detectada $fecha',
        'color': Colors.blue,
      });
    }

    // Humedad de suelo 60–80%
    String humSoilStatus;
    if (humSoil < 60) {
      humSoilStatus = 'Baja';
    } else if (humSoil <= 80) {
      humSoilStatus = 'Óptima';
    } else {
      humSoilStatus = 'Alta';
    }
    if (humSoilStatus != 'Óptima') {
      alerts.add({
        'title': 'Humedad de suelo',
        'value': '${humSoil.toStringAsFixed(0)}%',
        'status': humSoilStatus,
        'detail': 'Detectada $fecha',
        'color': Colors.green,
      });
    }

    return alerts;
  }

  List<Map<String, dynamic>> _buildHistoryAlerts(List<Map<String, dynamic>> data) {
    final List<Map<String, dynamic>> items = [];
    for (final entry in data.reversed.take(20)) {
      if ((entry['planta'] ?? '') != 'Lechuga') continue;
      final alerts = _evaluateAlerts(entry);
      if (alerts.isEmpty) {
        items.add({
          'title': 'Lectura dentro de rango',
          'detail': 'Hace poco - Duración: 5 min',
          'value': '',
          'color': Colors.grey,
        });
      } else {
        for (final a in alerts) {
          items.add({
            'title': a['title'],
            'detail': a['detail'],
            'value': a['value'],
            'color': a['color'],
          });
        }
      }
    }
    return items;
  }

  Widget _alertCard(Map<String, dynamic> alert) {
    return Card(
      elevation: 1,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Icon(Icons.warning, color: alert['color'] as Color),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(alert['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text('${alert['status']} - ${alert['detail']}', style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            Text(alert['value'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(width: 8),
            const Icon(Icons.close, color: Colors.black26),
          ],
        ),
      ),
    );
  }

  Widget _historyCard(Map<String, dynamic> item) {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.grey),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(item['title'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 4),
                  Text(item['detail'] as String, style: const TextStyle(color: Colors.black54)),
                ],
              ),
            ),
            if ((item['value'] as String).isNotEmpty)
              Text(item['value'] as String, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}