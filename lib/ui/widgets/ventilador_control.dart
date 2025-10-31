import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/dispositivo_controller.dart';

/// Widget para controlar la velocidad del ventilador
class VentiladorControl extends StatelessWidget {
  const VentiladorControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DispositivoController>(
      builder: (context, controller, _) {
        final velocidad = controller.velocidadVentilador;
        
        return Card(
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.air,
                        size: 32,
                        color: Colors.blue,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Control de Ventilador',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Ajusta la velocidad del ventilador',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text('Velocidad'),
                              Text(
                                '${velocidad.toStringAsFixed(0)}%',
                                style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ],
                          ),
                          Slider(
                            value: velocidad,
                            min: 0,
                            max: 100,
                            divisions: 10,
                            label: '${velocidad.toStringAsFixed(0)}%',
                            onChanged: (value) async {
                              await controller.setVelocidadVentilador(value);
                            },
                          ),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('0%', style: TextStyle(color: Colors.grey[600])),
                              Text('100%', style: TextStyle(color: Colors.grey[600])),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: _getEstadoColor(velocidad).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _getEstadoIcon(velocidad),
                        color: _getEstadoColor(velocidad),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _getEstadoTexto(velocidad),
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: _getEstadoColor(velocidad),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getEstadoColor(double velocidad) {
    if (velocidad == 0) return Colors.grey;
    if (velocidad < 30) return Colors.green;
    if (velocidad < 60) return Colors.orange;
    if (velocidad < 100) return Colors.blue;
    return Colors.red;
  }

  IconData _getEstadoIcon(double velocidad) {
    if (velocidad == 0) return Icons.power_off;
    if (velocidad < 30) return Icons.air;
    if (velocidad < 60) return Icons.air_outlined;
    return Icons.airplanemode_active;
  }

  String _getEstadoTexto(double velocidad) {
    if (velocidad == 0) return 'Apagado';
    if (velocidad < 30) return 'Bajo';
    if (velocidad < 60) return 'Medio';
    if (velocidad < 100) return 'Alto';
    return 'Máximo';
  }
}

