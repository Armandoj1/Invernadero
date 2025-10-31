import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/planta_model.dart';
import '../../controllers/dashboard_controller.dart';

/// Widget para seleccionar el tipo de planta
class PlantaSelector extends StatelessWidget {
  const PlantaSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DashboardController>(
      builder: (context, controller, _) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: DropdownButtonFormField<TipoPlanta>(
              value: controller.plantaSeleccionada,
              decoration: InputDecoration(
                labelText: 'Tipo de Planta',
                prefixIcon: const Icon(Icons.eco),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: Colors.grey.shade50,
              ),
              items: TipoPlanta.values.map((tipo) {
                return DropdownMenuItem(
                  value: tipo,
                  child: Row(
                    children: [
                      Icon(
                        _getIconoPlanta(tipo),
                        color: _getColorPlanta(tipo),
                      ),
                      const SizedBox(width: 8),
                      Text(tipo.displayName),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (tipo) async {
                if (tipo != null) {
                  await controller.cambiarPlanta(tipo);
                  
                  // Mostrar información de la planta
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Planta seleccionada: ${tipo.displayName}'),
                        duration: const Duration(seconds: 2),
                        backgroundColor: _getColorPlanta(tipo),
                      ),
                    );
                  }
                }
              },
            ),
          ),
        );
      },
    );
  }

  IconData _getIconoPlanta(TipoPlanta tipo) {
    switch (tipo) {
      case TipoPlanta.lechuga:
        return Icons.eco;
      case TipoPlanta.pimenton:
        return Icons.spa;
      case TipoPlanta.tomate:
        return Icons.wb_sunny;
    }
  }

  Color _getColorPlanta(TipoPlanta tipo) {
    switch (tipo) {
      case TipoPlanta.lechuga:
        return Colors.green;
      case TipoPlanta.pimenton:
        return Colors.orange;
      case TipoPlanta.tomate:
        return Colors.red;
    }
  }
}

