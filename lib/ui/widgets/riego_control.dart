import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/dispositivo_controller.dart';

/// Widget para controlar el riego
class RiegoControl extends StatefulWidget {
  const RiegoControl({super.key});

  @override
  State<RiegoControl> createState() => _RiegoControlState();
}

class _RiegoControlState extends State<RiegoControl> {
  final TextEditingController _duracionController = TextEditingController();
  int _duracionSeleccionada = 0; // segundos

  @override
  void dispose() {
    _duracionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DispositivoController>(
      builder: (context, controller, _) {
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
                        Icons.water_drop,
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
                            'Control de Riego',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Configura la duración del riego',
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
                TextField(
                  controller: _duracionController,
                  decoration: InputDecoration(
                    labelText: 'Duración (segundos)',
                    hintText: 'Ej: 30, 60, 120',
                    prefixIcon: const Icon(Icons.timer),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    filled: true,
                    fillColor: Colors.grey.shade50,
                  ),
                  keyboardType: TextInputType.number,
                  onChanged: (value) {
                    _duracionSeleccionada = int.tryParse(value) ?? 0;
                  },
                ),
                const SizedBox(height: 16),
                // Botones rápidos
                Row(
                  children: [
                    Expanded(
                      child: _buildBotonRapido('30s', 30, controller),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildBotonRapido('1min', 60, controller),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _buildBotonRapido('2min', 120, controller),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _duracionSeleccionada > 0
                        ? () async {
                            final exitoso = await controller.iniciarRiego(_duracionSeleccionada);
                            if (context.mounted && exitoso) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Riego iniciado: $_duracionSeleccionada segundos'),
                                  backgroundColor: Colors.green,
                                  duration: const Duration(seconds: 2),
                                ),
                              );
                              _duracionController.clear();
                              _duracionSeleccionada = 0;
                            }
                          }
                        : null,
                    icon: const Icon(Icons.water_drop),
                    label: const Text('Iniciar Riego'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildBotonRapido(String etiqueta, int segundos, DispositivoController controller) {
    return OutlinedButton(
      onPressed: () {
        _duracionController.text = segundos.toString();
        _duracionSeleccionada = segundos;
      },
      style: OutlinedButton.styleFrom(
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      child: Text(etiqueta),
    );
  }
}

