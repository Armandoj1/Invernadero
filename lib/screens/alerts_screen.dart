import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../services/alert_service.dart';
import '../models/alert_model.dart';
import '../controllers/auth_controller.dart';
import 'package:intl/intl.dart';

class AlertsScreen extends StatefulWidget {
  const AlertsScreen({Key? key}) : super(key: key);

  @override
  State<AlertsScreen> createState() => _AlertsScreenState();
}

class _AlertsScreenState extends State<AlertsScreen> {
  final AlertService _alertService = AlertService();

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final userId = authController.user?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BCD4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.menu, color: Colors.white),
          onPressed: () {
            // TODO: Abrir drawer/menú lateral
          },
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
            icon: const Icon(Icons.done_all, color: Colors.white),
            onPressed: () async {
              await _alertService.markAllAsRead(userId);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Todas las alertas marcadas como leídas')),
              );
            },
            tooltip: 'Marcar todas como leídas',
          ),
          IconButton(
            icon: const Icon(Icons.delete_sweep, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Eliminar todas las alertas'),
                  content: const Text('¿Deseas eliminar todas las alertas?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () async {
                        await _alertService.deleteAllAlerts(userId);
                        Navigator.pop(context);
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Alertas eliminadas')),
                        );
                      },
                      child: const Text('Eliminar'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Eliminar todas',
          ),
        ],
      ),
      body: StreamBuilder<List<AlertModel>>(
        stream: _alertService.getAlerts(userId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final alerts = snapshot.data ?? [];

          if (alerts.isEmpty) {
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

          // Separar alertas no leídas y leídas
          final unreadAlerts = alerts.where((a) => !a.isRead).toList();
          final readAlerts = alerts.where((a) => a.isRead).toList();

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              if (unreadAlerts.isNotEmpty) ...[
                _sectionTitle('Alertas Activas', unreadAlerts.length),
                const SizedBox(height: 8),
                ...unreadAlerts.map((alert) => _buildAlertCard(alert, userId)),
                const SizedBox(height: 24),
              ],
              if (readAlerts.isNotEmpty) ...[
                _sectionTitle('Alertas Leídas', readAlerts.length),
                const SizedBox(height: 8),
                ...readAlerts.map((alert) => _buildAlertCard(alert, userId, isRead: true)),
              ],
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

  Widget _buildAlertCard(AlertModel alert, String userId, {bool isRead = false}) {
    final timeFormat = DateFormat('dd/MM/yyyy HH:mm');
    final severityConfig = _getSeverityConfig(alert.severity);

    return Dismissible(
      key: Key(alert.id),
      direction: DismissDirection.endToStart,
      onDismissed: (direction) {
        _alertService.deleteAlert(alert.id);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Alerta eliminada'),
            action: SnackBarAction(
              label: 'Deshacer',
              onPressed: () {
                _alertService.saveAlert(alert);
              },
            ),
          ),
        );
      },
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      child: Card(
        elevation: isRead ? 0 : 2,
        margin: const EdgeInsets.only(bottom: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(
            color: isRead ? Colors.grey.shade200 : severityConfig['color'],
            width: isRead ? 1 : 2,
          ),
        ),
        child: InkWell(
          onTap: () {
            if (!alert.isRead) {
              _alertService.markAsRead(alert.id);
            }
          },
          borderRadius: BorderRadius.circular(12),
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
                                  alert.title,
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: isRead ? Colors.grey : Colors.black87,
                                  ),
                                ),
                              ),
                              if (!alert.isRead)
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
                  alert.message,
                  style: TextStyle(
                    fontSize: 14,
                    color: isRead ? Colors.grey.shade600 : Colors.black87,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(Icons.eco, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      alert.plantType,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    Icon(Icons.access_time, size: 16, color: Colors.grey.shade600),
                    const SizedBox(width: 4),
                    Text(
                      timeFormat.format(alert.timestamp),
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
