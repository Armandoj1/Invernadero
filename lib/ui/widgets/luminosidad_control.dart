import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../controllers/dispositivo_controller.dart';

/// Widget para controlar la intensidad de luminosidad
class LuminosidadControl extends StatelessWidget {
  const LuminosidadControl({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<DispositivoController>(
      builder: (context, controller, _) {
        final nivel = controller.intensidadLuminosidad;
        
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
                        color: Colors.amber.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.lightbulb,
                        size: 32,
                        color: Colors.amber,
                      ),
                    ),
                    const SizedBox(width: 16),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Intensidad Lumínica',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Controla el nivel de iluminación',
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
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(5, (index) {
                    final nivelActual = index + 1;
                    final estaActivo = nivelActual <= nivel;
                    
                    return GestureDetector(
                      onTap: () async {
                        await controller.setIntensidadLuminosidad(nivelActual);
                      },
                      child: Container(
                        width: 56,
                        height: 56,
                        decoration: BoxDecoration(
                          color: estaActivo
                              ? Colors.amber.withOpacity(0.2)
                              : Colors.grey.withOpacity(0.1),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: estaActivo ? Colors.amber : Colors.grey,
                            width: estaActivo ? 2 : 1,
                          ),
                        ),
                        child: Icon(
                          estaActivo ? Icons.lightbulb : Icons.lightbulb_outline,
                          color: estaActivo ? Colors.amber : Colors.grey,
                          size: 32,
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.amber.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.brightness_6,
                        color: Colors.amber.shade800,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        'Nivel $nivel/5',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: Colors.amber.shade800,
                          fontSize: 16,
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
}

