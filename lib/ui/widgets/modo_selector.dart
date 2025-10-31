import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';
import '../../controllers/ia_control_controller.dart';

/// Widget para seleccionar/visualizar el modo de operación
class ModoSelector extends StatelessWidget {
  const ModoSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<IAControlController>(
      builder: (context, controller, _) {
        final modo = controller.control?.modo ?? 'automatico';
        
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Icon(
                  _getIcono(modo),
                  color: _getColor(modo),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Modo de Operación',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _getNombreModo(modo),
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: _getColor(modo),
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.tune),
                  onPressed: () => Get.toNamed('/ia-control'),
                  tooltip: 'Configurar IA',
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  IconData _getIcono(String modo) {
    switch (modo) {
      case 'automatico':
        return Icons.auto_awesome;
      case 'manual':
        return Icons.touch_app;
      case 'hibrido':
        return Icons.swap_horiz;
      default:
        return Icons.settings;
    }
  }

  Color _getColor(String modo) {
    switch (modo) {
      case 'automatico':
        return const Color(0xFF00BCD4);
      case 'manual':
        return const Color(0xFF1565C0);
      case 'hibrido':
        return const Color(0xFF00B4D8);
      default:
        return Colors.grey;
    }
  }

  String _getNombreModo(String modo) {
    switch (modo) {
      case 'automatico':
        return 'Automático (IA)';
      case 'manual':
        return 'Manual';
      case 'hibrido':
        return 'Híbrido';
      default:
        return 'Desconocido';
    }
  }
}

