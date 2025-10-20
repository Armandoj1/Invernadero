import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:invernadero/controllers/ia_control_controller.dart';
import 'package:invernadero/controllers/auth_controller.dart';

class IAControlScreen extends StatefulWidget {
  const IAControlScreen({super.key});

  @override
  State<IAControlScreen> createState() => _IAControlScreenState();
}

class _IAControlScreenState extends State<IAControlScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<IAControlController>();
      final auth = Get.find<AuthController>();
      if (auth.user != null && controller.control == null) {
        controller.load();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Control de IA'),
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
      ),
      body: Consumer<IAControlController>(
        builder: (context, controller, child) {
          if (controller.isLoading || controller.control == null) {
            return const Center(child: CircularProgressIndicator());
          }

          final c = controller.control!;
          final isAuto = c.modo == 'automatico';
          final isManual = c.modo == 'manual';
          final isHibrido = c.modo == 'hibrido';

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Parámetros Óptimos - Tomate',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      _sliderRow(
                        label: 'Temperatura Objetivo',
                        valueLabel: '${c.temperaturaObjetivo.toStringAsFixed(0)}°C',
                        minLabel: '18°C',
                        maxLabel: '30°C',
                        value: c.temperaturaObjetivo,
                        min: 18,
                        max: 30,
                        divisions: 12,
                        enabled: isManual, // híbrido bloquea temperatura
                        onChanged: controller.updateTemperatura,
                      ),
                      const SizedBox(height: 8),
                      _sliderRow(
                        label: 'Humedad Objetivo',
                        valueLabel: '${c.humedadObjetivo.toStringAsFixed(0)}%',
                        minLabel: '40%',
                        maxLabel: '90%',
                        value: c.humedadObjetivo,
                        min: 40,
                        max: 90,
                        divisions: 10,
                        enabled: isManual || isHibrido,
                        onChanged: controller.updateHumedad,
                      ),
                      const SizedBox(height: 8),
                      _sliderRow(
                        label: 'CO₂ Objetivo',
                        valueLabel: '${c.co2Objetivo.toStringAsFixed(0)} ppm',
                        minLabel: '300 ppm',
                        maxLabel: '800 ppm',
                        value: c.co2Objetivo,
                        min: 300,
                        max: 800,
                        divisions: 10,
                        enabled: isManual, // híbrido bloquea CO2
                        onChanged: controller.updateCo2,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                _card(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Modo de Control',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 8),
                      RadioListTile<String>(
                        value: 'automatico',
                        groupValue: c.modo,
                        onChanged: (v) => controller.setModo(v!),
                        title: const Text('Automático (IA Difusa)'),
                        subtitle: const Text('El sistema ajusta automáticamente todos los parámetros'),
                      ),
                      RadioListTile<String>(
                        value: 'manual',
                        groupValue: c.modo,
                        onChanged: (v) => controller.setModo(v!),
                        title: const Text('Manual'),
                        subtitle: const Text('Control manual de todos los sistemas'),
                      ),
                      RadioListTile<String>(
                        value: 'hibrido',
                        groupValue: c.modo,
                        onChanged: (v) => controller.setModo(v!),
                        title: const Text('Híbrido'),
                        subtitle: const Text('IA con supervisión manual (ajuste de humedad)'),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Align(
                  alignment: Alignment.centerRight,
                  child: ElevatedButton.icon(
                    onPressed: () async {
                      final ok = await controller.save();
                      if (!mounted) return;
                      if (ok) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('✓ Configuración guardada'),
                            backgroundColor: Color(0xFF2E7D32),
                            duration: Duration(milliseconds: 800),
                          ),
                        );
                        Future.delayed(const Duration(milliseconds: 600), () {
                          if (mounted) Get.back();
                        });
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(controller.error ?? 'Error al guardar'),
                            backgroundColor: Colors.red,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.save),
                    label: const Text('Guardar'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _card({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sliderRow({
    required String label,
    required String valueLabel,
    required String minLabel,
    required String maxLabel,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required bool enabled,
    required ValueChanged<double> onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(label),
            Text(valueLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
          ],
        ),
        Slider(
          value: value,
          min: min,
          max: max,
          divisions: divisions,
          onChanged: enabled ? onChanged : null,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(minLabel, style: TextStyle(color: Colors.grey[600])),
            Text(maxLabel, style: TextStyle(color: Colors.grey[600])),
          ],
        ),
      ],
    );
  }
}