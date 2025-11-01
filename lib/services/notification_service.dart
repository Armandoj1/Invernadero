import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/notification_model.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final String _notificationsCollection = 'notifications';

  /// Crear una notificación
  Future<void> createNotification({
    required String userId,
    required String type,
    required String title,
    required String message,
    String? iconType,
    Map<String, dynamic>? data,
  }) async {
    try {
      final now = DateTime.now();
      final notification = NotificationModel(
        id: now.millisecondsSinceEpoch.toString(),
        userId: userId,
        type: type,
        title: title,
        message: message,
        iconType: iconType ?? 'info',
        timestamp: now,
        isRead: false,
        data: data,
      );

      await _firestore
          .collection(_notificationsCollection)
          .doc(notification.id)
          .set(notification.toJson());
    } catch (e) {
      print('Error al crear notificación: $e');
    }
  }

  /// Obtener todas las notificaciones de un usuario
  Stream<List<NotificationModel>> getNotifications(String userId) {
    return _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .orderBy('timestamp', descending: true)
        .limit(50)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return NotificationModel.fromJson(data);
      }).toList();
    });
  }

  /// Obtener solo notificaciones no leídas
  Stream<List<NotificationModel>> getUnreadNotifications(String userId) {
    return _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return NotificationModel.fromJson(data);
      }).toList();
    });
  }

  /// Contar notificaciones no leídas
  Stream<int> getUnreadCount(String userId) {
    return _firestore
        .collection(_notificationsCollection)
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// Marcar notificación como leída
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore
          .collection(_notificationsCollection)
          .doc(notificationId)
          .update({'isRead': true});
    } catch (e) {
      print('Error al marcar notificación como leída: $e');
    }
  }

  /// Marcar todas las notificaciones como leídas
  Future<void> markAllAsRead(String userId) async {
    try {
      final notifications = await _firestore
          .collection(_notificationsCollection)
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();

      for (final doc in notifications.docs) {
        await doc.reference.update({'isRead': true});
      }
    } catch (e) {
      print('Error al marcar todas las notificaciones como leídas: $e');
    }
  }

  /// Eliminar notificación
  Future<void> deleteNotification(String notificationId) async {
    try {
      await _firestore
          .collection(_notificationsCollection)
          .doc(notificationId)
          .delete();
    } catch (e) {
      print('Error al eliminar notificación: $e');
    }
  }

  /// Eliminar todas las notificaciones de un usuario
  Future<void> deleteAllNotifications(String userId) async {
    try {
      final notifications = await _firestore
          .collection(_notificationsCollection)
          .where('userId', isEqualTo: userId)
          .get();

      for (final doc in notifications.docs) {
        await doc.reference.delete();
      }
    } catch (e) {
      print('Error al eliminar todas las notificaciones: $e');
    }
  }

  // === Notificaciones específicas para eventos ===

  /// Notificación de cultivo creado
  Future<void> notifyCropCreated(String userId, String cropName, String cropType) async {
    await createNotification(
      userId: userId,
      type: 'crop',
      title: 'Cultivo creado',
      message: 'Se ha creado el cultivo "$cropName" de tipo $cropType',
      iconType: 'success',
      data: {'cropName': cropName, 'cropType': cropType},
    );
  }

  /// Notificación de cultivo cosechado
  Future<void> notifyCropHarvested(String userId, String cropName) async {
    await createNotification(
      userId: userId,
      type: 'crop',
      title: 'Cultivo cosechado',
      message: 'El cultivo "$cropName" ha sido cosechado exitosamente',
      iconType: 'success',
      data: {'cropName': cropName},
    );
  }

  /// Notificación de alerta de sensor
  Future<void> notifyAlert(String userId, String alertTitle, String alertMessage) async {
    await createNotification(
      userId: userId,
      type: 'alert',
      title: alertTitle,
      message: alertMessage,
      iconType: 'warning',
    );
  }

  /// Notificación de sistema
  Future<void> notifySystem(String userId, String title, String message, {String iconType = 'info'}) async {
    await createNotification(
      userId: userId,
      type: 'system',
      title: title,
      message: message,
      iconType: iconType,
    );
  }

  /// Notificación de IA
  Future<void> notifyAI(String userId, String title, String message) async {
    await createNotification(
      userId: userId,
      type: 'ai',
      title: title,
      message: message,
      iconType: 'info',
    );
  }
}
