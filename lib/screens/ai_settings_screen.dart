import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/notification_service.dart';
import 'notifications_screen.dart';

class AISettingsScreen extends StatefulWidget {
  const AISettingsScreen({Key? key}) : super(key: key);

  @override
  State<AISettingsScreen> createState() => _AISettingsScreenState();
}

class _AISettingsScreenState extends State<AISettingsScreen> {
  double _tempTarget = 24.0;
  double _humidityTarget = 70.0;
  double _co2Target = 500.0;
  String _controlMode = 'automatic'; // automatic, manual, hybrid
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  Widget build(BuildContext context) {
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
              'Control IA',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
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
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Parámetros Óptimos Card
            Container(
              padding: const EdgeInsets.all(20),
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
                    'Parámetros Óptimos - Lechuga',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Temperatura Objetivo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Temperatura Objetivo',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${_tempTarget.toStringAsFixed(0)}°C',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00BCD4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('18°C', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Expanded(
                        child: Slider(
                          value: _tempTarget,
                          min: 18,
                          max: 30,
                          divisions: 12,
                          activeColor: const Color(0xFF00BCD4),
                          onChanged: (value) {
                            setState(() {
                              _tempTarget = value;
                            });
                          },
                        ),
                      ),
                      const Text('30°C', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Humedad Objetivo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Humedad Objetivo',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${_humidityTarget.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00BCD4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('40%', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Expanded(
                        child: Slider(
                          value: _humidityTarget,
                          min: 40,
                          max: 90,
                          divisions: 10,
                          activeColor: const Color(0xFF00BCD4),
                          onChanged: (value) {
                            setState(() {
                              _humidityTarget = value;
                            });
                          },
                        ),
                      ),
                      const Text('90%', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // CO2 Objetivo
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'CO₂ Objetivo',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${_co2Target.toStringAsFixed(0)} ppm',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF00BCD4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Text('300 ppm', style: TextStyle(fontSize: 12, color: Colors.grey)),
                      Expanded(
                        child: Slider(
                          value: _co2Target,
                          min: 300,
                          max: 800,
                          divisions: 10,
                          activeColor: const Color(0xFF00BCD4),
                          onChanged: (value) {
                            setState(() {
                              _co2Target = value;
                            });
                          },
                        ),
                      ),
                      const Text('800 ppm', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Modo de Control Card
            Container(
              padding: const EdgeInsets.all(20),
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
                    'Modo de Control',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Automático (IA Difusa)
                  _buildControlModeOption(
                    value: 'automatic',
                    title: 'Automático (IA Difusa)',
                    description: 'El sistema ajusta automáticamente todos los parámetros',
                    icon: Icons.auto_awesome,
                  ),
                  const SizedBox(height: 12),

                  // Manual
                  _buildControlModeOption(
                    value: 'manual',
                    title: 'Manual',
                    description: 'Control manual de todos los sistemas',
                    icon: Icons.touch_app,
                  ),
                  const SizedBox(height: 12),

                  // Híbrido
                  _buildControlModeOption(
                    value: 'hybrid',
                    title: 'Híbrido',
                    description: 'IA con supervisión manual',
                    icon: Icons.change_circle,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Botón Guardar
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Configuración guardada exitosamente'),
                      backgroundColor: Colors.green,
                    ),
                  );
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD4),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  elevation: 2,
                ),
                child: const Text(
                  'Guardar Configuración',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildControlModeOption({
    required String value,
    required String title,
    required String description,
    required IconData icon,
  }) {
    final isSelected = _controlMode == value;
    return InkWell(
      onTap: () {
        setState(() {
          _controlMode = value;
        });
      },
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected ? const Color(0xFF00BCD4).withOpacity(0.1) : Colors.grey.shade50,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? const Color(0xFF00BCD4) : Colors.grey.shade300,
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Radio<String>(
              value: value,
              groupValue: _controlMode,
              onChanged: (newValue) {
                setState(() {
                  _controlMode = newValue!;
                });
              },
              activeColor: const Color(0xFF00BCD4),
            ),
            const SizedBox(width: 12),
            Icon(
              icon,
              color: isSelected ? const Color(0xFF00BCD4) : Colors.grey.shade600,
              size: 28,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                      color: isSelected ? const Color(0xFF00BCD4) : Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
