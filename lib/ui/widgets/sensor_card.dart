import 'package:flutter/material.dart';

/// Widget reutilizable para mostrar datos de sensores
class SensorCard extends StatelessWidget {
  final String titulo;
  final double? valor;
  final String unidad;
  final IconData icono;
  final Color? color;
  final VoidCallback? onTap;

  const SensorCard({
    super.key,
    required this.titulo,
    this.valor,
    required this.unidad,
    required this.icono,
    this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorFinal = color ?? Theme.of(context).primaryColor;
    
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: colorFinal.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icono,
                  size: 40,
                  color: colorFinal,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                titulo,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                valor != null ? '${valor!.toStringAsFixed(1)} $unidad' : '-- $unidad',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: colorFinal,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

