import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/crop_controller.dart';
import '../models/crop.dart';
import '../services/gemini_service.dart';
import '../services/notification_service.dart';
import 'notifications_screen.dart';

class CropFormScreen extends StatefulWidget {
  final Crop? crop; // Si no es null, estamos editando

  const CropFormScreen({Key? key, this.crop}) : super(key: key);

  @override
  State<CropFormScreen> createState() => _CropFormScreenState();
}

class _CropFormScreenState extends State<CropFormScreen> {
  final _formKey = GlobalKey<FormState>();
  final controller = Get.find<CropController>();
  final _geminiService = GeminiService();
  final String userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  // Controllers de texto
  late TextEditingController _nameController;
  late TextEditingController _notesController;
  late TextEditingController _tempMinController;
  late TextEditingController _tempMaxController;
  late TextEditingController _humidityMinController;
  late TextEditingController _humidityMaxController;

  // Variables de estado
  String _selectedType = 'Lechuga';
  DateTime _plantedDate = DateTime.now();
  bool _isLoadingGroq = false;

  final List<String> _cropTypes = [
    'Lechuga',
    'Tomate',
    'Pimentón',
  ];

  @override
  void initState() {
    super.initState();

    // Si estamos editando, cargar los datos existentes
    if (widget.crop != null) {
      _nameController = TextEditingController(text: widget.crop!.name);
      _notesController = TextEditingController(text: widget.crop!.notes ?? '');
      _tempMinController = TextEditingController(
        text: widget.crop!.optimalTempMin?.toString() ?? '',
      );
      _tempMaxController = TextEditingController(
        text: widget.crop!.optimalTempMax?.toString() ?? '',
      );
      _humidityMinController = TextEditingController(
        text: widget.crop!.optimalHumidityMin?.toString() ?? '',
      );
      _humidityMaxController = TextEditingController(
        text: widget.crop!.optimalHumidityMax?.toString() ?? '',
      );
      _selectedType = widget.crop!.type;
      _plantedDate = widget.crop!.plantedDate;
    } else {
      _nameController = TextEditingController();
      _notesController = TextEditingController();
      _tempMinController = TextEditingController();
      _tempMaxController = TextEditingController();
      _humidityMinController = TextEditingController();
      _humidityMaxController = TextEditingController();
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _notesController.dispose();
    _tempMinController.dispose();
    _tempMaxController.dispose();
    _humidityMinController.dispose();
    _humidityMaxController.dispose();
    super.dispose();
  }

  Future<void> _selectDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _plantedDate,
      firstDate: DateTime(2020),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: Color(0xFF00BCD4),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null && picked != _plantedDate) {
      setState(() {
        _plantedDate = picked;
      });
    }
  }

  Future<void> _adjustWithGroq() async {
    setState(() {
      _isLoadingGroq = true;
    });

    try {
      final prompt = '''
Eres un experto en agricultura. Necesito los parámetros óptimos para cultivar $_selectedType.

Proporciona la siguiente información en formato JSON exacto:
{
  "tempMin": número (temperatura mínima en °C),
  "tempMax": número (temperatura máxima en °C),
  "humidityMin": número (humedad mínima en %),
  "humidityMax": número (humedad máxima en %),
  "notes": "texto breve con recomendaciones importantes de cultivo (máximo 2-3 líneas)"
}

Solo responde con el JSON, sin texto adicional.
''';

      final response = await _geminiService.sendMessage(prompt);

      // Parsear respuesta JSON
      final jsonMatch = RegExp(r'\{[^}]*\}').firstMatch(response);
      if (jsonMatch != null) {
        final jsonStr = jsonMatch.group(0)!;
        // Parsear manualmente para evitar dependencias adicionales
        final tempMinMatch = RegExp(r'"tempMin":\s*(\d+(?:\.\d+)?)').firstMatch(jsonStr);
        final tempMaxMatch = RegExp(r'"tempMax":\s*(\d+(?:\.\d+)?)').firstMatch(jsonStr);
        final humMinMatch = RegExp(r'"humidityMin":\s*(\d+(?:\.\d+)?)').firstMatch(jsonStr);
        final humMaxMatch = RegExp(r'"humidityMax":\s*(\d+(?:\.\d+)?)').firstMatch(jsonStr);
        final notesMatch = RegExp(r'"notes":\s*"([^"]*)"').firstMatch(jsonStr);

        setState(() {
          if (tempMinMatch != null) {
            _tempMinController.text = tempMinMatch.group(1)!;
          }
          if (tempMaxMatch != null) {
            _tempMaxController.text = tempMaxMatch.group(1)!;
          }
          if (humMinMatch != null) {
            _humidityMinController.text = humMinMatch.group(1)!;
          }
          if (humMaxMatch != null) {
            _humidityMaxController.text = humMaxMatch.group(1)!;
          }
          if (notesMatch != null) {
            _notesController.text = notesMatch.group(1)!.replaceAll(r'\n', '\n');
          }
        });

        Get.snackbar(
          'Éxito',
          'Parámetros ajustados con IA',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green.shade100,
          colorText: Colors.green.shade900,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron obtener los parámetros: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      setState(() {
        _isLoadingGroq = false;
      });
    }
  }

  void _handleSave() {
    if (_formKey.currentState!.validate()) {
      if (widget.crop != null) {
        // Editar cultivo existente
        final updatedCrop = widget.crop!.copyWith(
          name: _nameController.text.trim(),
          type: _selectedType,
          plantedDate: _plantedDate,
          optimalTempMin: _tempMinController.text.isNotEmpty
              ? double.tryParse(_tempMinController.text)
              : null,
          optimalTempMax: _tempMaxController.text.isNotEmpty
              ? double.tryParse(_tempMaxController.text)
              : null,
          optimalHumidityMin: _humidityMinController.text.isNotEmpty
              ? double.tryParse(_humidityMinController.text)
              : null,
          optimalHumidityMax: _humidityMaxController.text.isNotEmpty
              ? double.tryParse(_humidityMaxController.text)
              : null,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );

        controller.updateCrop(updatedCrop);
      } else {
        // Crear nuevo cultivo
        controller.createCrop(
          name: _nameController.text.trim(),
          type: _selectedType,
          plantedDate: _plantedDate,
          optimalTempMin: _tempMinController.text.isNotEmpty
              ? double.tryParse(_tempMinController.text)
              : null,
          optimalTempMax: _tempMaxController.text.isNotEmpty
              ? double.tryParse(_tempMaxController.text)
              : null,
          optimalHumidityMin: _humidityMinController.text.isNotEmpty
              ? double.tryParse(_humidityMinController.text)
              : null,
          optimalHumidityMax: _humidityMaxController.text.isNotEmpty
              ? double.tryParse(_humidityMaxController.text)
              : null,
          notes: _notesController.text.trim().isEmpty
              ? null
              : _notesController.text.trim(),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.crop != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BCD4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AgriSense Pro',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              isEditing ? 'Editar Cultivo' : 'Nuevo Cultivo',
              style: const TextStyle(
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
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nombre del cultivo
              _buildSectionTitle('Información Básica'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _nameController,
                label: 'Nombre del cultivo',
                hint: 'Ej: Lechuga sector A',
                icon: Icons.label,
                validator: (value) {
                  if (value == null || value.trim().isEmpty) {
                    return 'Ingresa un nombre para el cultivo';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Tipo de cultivo
              _buildLabel('Tipo de cultivo'),
              const SizedBox(height: 8),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 12),
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: _selectedType,
                    isExpanded: true,
                    icon: const Icon(Icons.arrow_drop_down),
                    items: _cropTypes.map((String type) {
                      return DropdownMenuItem<String>(
                        value: type,
                        child: Row(
                          children: [
                            SvgPicture.asset(
                              controller.getSvgPathForCropType(type),
                              width: 20,
                              height: 20,
                              colorFilter: ColorFilter.mode(
                                controller.getColorForCropType(type),
                                BlendMode.srcIn,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Text(type),
                          ],
                        ),
                      );
                    }).toList(),
                    onChanged: (String? newValue) {
                      if (newValue != null) {
                        setState(() {
                          _selectedType = newValue;
                        });
                      }
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // Fecha de plantado
              _buildLabel('Fecha de plantado'),
              const SizedBox(height: 8),
              InkWell(
                onTap: _selectDate,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.calendar_today, color: Color(0xFF00BCD4)),
                      const SizedBox(width: 12),
                      Text(
                        DateFormat('dd/MM/yyyy').format(_plantedDate),
                        style: const TextStyle(fontSize: 16),
                      ),
                      const Spacer(),
                      const Icon(Icons.arrow_drop_down),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Parámetros óptimos
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      _buildSectionTitle('Parámetros Óptimos (Opcional)'),
                    ],
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: _isLoadingGroq ? null : _adjustWithGroq,
                      icon: _isLoadingGroq
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFF00BCD4)),
                            )
                          : SvgPicture.asset(
                              'lib/assets/groq-text.svg',
                              height: 14,
                              colorFilter: const ColorFilter.mode(
                                Color(0xFF00BCD4),
                                BlendMode.srcIn,
                              ),
                            ),
                      label: Text(
                        _isLoadingGroq ? 'Ajustando...' : 'Ajustar con GROQ',
                        style: const TextStyle(fontSize: 13),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF00BCD4),
                        side: const BorderSide(color: Color(0xFF00BCD4)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Temperatura
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _tempMinController,
                      label: 'Temp. mínima (°C)',
                      hint: '15',
                      icon: Icons.thermostat,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _tempMaxController,
                      label: 'Temp. máxima (°C)',
                      hint: '25',
                      icon: Icons.thermostat,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Humedad
              Row(
                children: [
                  Expanded(
                    child: _buildTextField(
                      controller: _humidityMinController,
                      label: 'Humedad mín. (%)',
                      hint: '60',
                      icon: Icons.water_drop,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildTextField(
                      controller: _humidityMaxController,
                      label: 'Humedad máx. (%)',
                      hint: '80',
                      icon: Icons.water_drop,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Notas
              _buildSectionTitle('Notas (Opcional)'),
              const SizedBox(height: 12),
              _buildTextField(
                controller: _notesController,
                label: 'Notas adicionales',
                hint: 'Cualquier información adicional sobre este cultivo...',
                icon: Icons.notes,
                maxLines: 3,
              ),
              const SizedBox(height: 32),

              // Botón guardar
              Obx(() {
                return SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: controller.isLoading.value ? null : _handleSave,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00BCD4),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      elevation: 2,
                    ),
                    child: controller.isLoading.value
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            isEditing ? 'Guardar Cambios' : 'Crear Cultivo',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                );
              }),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Colors.black87,
      ),
    );
  }

  Widget _buildLabel(String label) {
    return Text(
      label,
      style: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: Colors.grey.shade700,
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    int maxLines = 1,
    String? Function(String?)? validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildLabel(label),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            prefixIcon: Icon(icon, color: Colors.grey.shade600, size: 20),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: Color(0xFF00BCD4)),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          keyboardType: keyboardType,
          maxLines: maxLines,
          validator: validator,
        ),
      ],
    );
  }
}
