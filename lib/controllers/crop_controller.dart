import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../models/crop.dart';
import '../services/firebase_service.dart';
import '../services/notification_service.dart';
import 'auth_controller.dart';

class CropController extends GetxController {
  final FirebaseService _firebaseService = FirebaseService();
  final NotificationService _notificationService = NotificationService();
  final AuthController _authController = Get.find<AuthController>();

  final RxList<Crop> crops = <Crop>[].obs;
  final RxList<Crop> cropHistory = <Crop>[].obs;
  final RxBool isLoading = false.obs;

  String get userId => _authController.user?.uid ?? '';

  @override
  void onInit() {
    super.onInit();
    loadCrops();
    loadCropHistory();
  }

  // Cargar cultivos activos
  void loadCrops() {
    if (userId.isEmpty) {
      print('⚠️ CropController: userId está vacío, no se pueden cargar cultivos');
      return;
    }

    print('📦 CropController: Cargando cultivos para userId: $userId');

    _firebaseService.getUserCrops(userId).listen(
      (cropList) {
        print('✅ CropController: ${cropList.length} cultivos cargados');
        crops.value = cropList;
      },
      onError: (error) {
        print('❌ CropController: Error al cargar cultivos: $error');
        Get.snackbar(
          'Error',
          'No se pudieron cargar los cultivos: ${error.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      },
    );
  }

  // Cargar historial de cultivos
  void loadCropHistory() {
    if (userId.isEmpty) {
      print('⚠️ CropController: userId está vacío, no se puede cargar historial');
      return;
    }

    print('📦 CropController: Cargando historial para userId: $userId');

    _firebaseService.getCropHistory(userId).listen(
      (historyList) {
        print('✅ CropController: ${historyList.length} items en historial');
        cropHistory.value = historyList;
      },
      onError: (error) {
        print('❌ CropController: Error al cargar historial: $error');
        Get.snackbar(
          'Error',
          'No se pudo cargar el historial: ${error.toString()}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red.shade100,
          colorText: Colors.red.shade900,
        );
      },
    );
  }

  // Crear nuevo cultivo
  Future<void> createCrop({
    required String name,
    required String type,
    required DateTime plantedDate,
    double? optimalTempMin,
    double? optimalTempMax,
    double? optimalHumidityMin,
    double? optimalHumidityMax,
    String? notes,
  }) async {
    try {
      isLoading.value = true;

      print('🌱 CropController: Creando cultivo "$name" de tipo $type');

      final crop = Crop.initial(
        userId: userId,
        name: name,
        type: type,
        plantedDate: plantedDate,
      ).copyWith(
        optimalTempMin: optimalTempMin,
        optimalTempMax: optimalTempMax,
        optimalHumidityMin: optimalHumidityMin,
        optimalHumidityMax: optimalHumidityMax,
        notes: notes,
      );

      await _firebaseService.saveCrop(crop);

      print('✅ CropController: Cultivo creado con ID: ${crop.id}');

      // Crear notificación
      await _notificationService.notifyCropCreated(userId, name, type);

      Get.back();

      // Esperar un poco para que Firebase procese
      await Future.delayed(const Duration(milliseconds: 500));

      Get.snackbar(
        'Éxito',
        'Cultivo creado correctamente',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green.shade100,
        colorText: Colors.green.shade900,
        duration: const Duration(seconds: 2),
      );

      // Forzar recarga de cultivos
      loadCrops();
    } catch (e) {
      print('❌ CropController: Error al crear cultivo: $e');
      Get.snackbar(
        'Error',
        'No se pudo crear el cultivo: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red.shade100,
        colorText: Colors.red.shade900,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Actualizar cultivo existente
  Future<void> updateCrop(Crop crop) async {
    try {
      isLoading.value = true;

      final updatedCrop = crop.copyWith(
        updatedAt: DateTime.now(),
      );

      await _firebaseService.saveCrop(updatedCrop);

      Get.back();
      Get.snackbar(
        'Éxito',
        'Cultivo actualizado correctamente',
        snackPosition: SnackPosition.BOTTOM,
      );
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo actualizar el cultivo: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Eliminar cultivo (mover a historial)
  Future<void> deleteCrop(String cropId, String cropName) async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirmar eliminación'),
          content: Text('¿Estás seguro de eliminar "$cropName"?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Eliminar', style: TextStyle(color: Colors.red)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        isLoading.value = true;
        await _firebaseService.deleteCrop(cropId);

        // Crear notificación
        await _notificationService.notifySystem(
          userId,
          'Cultivo eliminado',
          'El cultivo "$cropName" ha sido eliminado y movido al historial',
          iconType: 'info',
        );

        Get.snackbar(
          'Éxito',
          'Cultivo eliminado y movido al historial',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo eliminar el cultivo: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Marcar como cosechado
  Future<void> harvestCrop(String cropId, String cropName) async {
    try {
      final confirmed = await Get.dialog<bool>(
        AlertDialog(
          title: const Text('Confirmar cosecha'),
          content: Text('¿Marcar "$cropName" como cosechado?'),
          actions: [
            TextButton(
              onPressed: () => Get.back(result: false),
              child: const Text('Cancelar'),
            ),
            TextButton(
              onPressed: () => Get.back(result: true),
              child: const Text('Cosechar', style: TextStyle(color: Colors.green)),
            ),
          ],
        ),
      );

      if (confirmed == true) {
        isLoading.value = true;
        await _firebaseService.harvestCrop(cropId);

        // Crear notificación
        await _notificationService.notifyCropHarvested(userId, cropName);

        Get.snackbar(
          'Éxito',
          'Cultivo cosechado exitosamente',
          snackPosition: SnackPosition.BOTTOM,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo marcar como cosechado: $e',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading.value = false;
    }
  }

  // Obtener ruta del SVG según tipo de cultivo
  String getSvgPathForCropType(String type) {
    switch (type.toLowerCase()) {
      case 'lechuga':
        return 'lib/assets/lechuga.svg';
      case 'tomate':
        return 'lib/assets/tomate.svg';
      case 'pimentón':
      case 'pimenton':
        return 'lib/assets/pimenton.svg';
      default:
        return 'lib/assets/lechuga.svg';
    }
  }

  // Obtener icono según tipo de cultivo (deprecated - usar getSvgPathForCropType)
  IconData getIconForCropType(String type) {
    switch (type.toLowerCase()) {
      case 'lechuga':
        return Icons.spa;
      case 'tomate':
        return Icons.local_florist;
      case 'pimentón':
      case 'pimenton':
        return Icons.local_fire_department;
      default:
        return Icons.yard;
    }
  }

  // Obtener color según tipo de cultivo
  Color getColorForCropType(String type) {
    switch (type.toLowerCase()) {
      case 'lechuga':
        return Colors.green;
      case 'tomate':
        return Colors.red;
      case 'pimentón':
      case 'pimenton':
        return Colors.deepOrange;
      default:
        return Colors.blue;
    }
  }
}
