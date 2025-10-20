import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/perfil.dart';

class UserService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<ProfileModel?> getUserProfile(String userId) async {
    try {
      print('🔍 UserService - Buscando perfil para usuario: $userId');
      DocumentSnapshot doc = await _firestore.collection('users').doc(userId).get();
      
      if (doc.exists) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        print('🔍 UserService - Datos encontrados: $data');
        ProfileModel profile = ProfileModel.fromJson(data);
        print('🔍 UserService - ProfileModel creado: ${profile.toJson()}');
        return profile;
      } else {
        print('🔍 UserService - No se encontró documento para el usuario');
      }
      return null;
    } catch (e) {
      print('Error al obtener perfil de usuario: $e');
      return null;
    }
  }

  Future<bool> updateUserProfile(String userId, ProfileModel profile) async {
    try {
      await _firestore
          .collection('users')
          .doc(userId)
          .set(profile.toJson(), SetOptions(merge: true));
      return true;
    } catch (e) {
      print('Error al actualizar perfil de usuario: $e');
      return false;
    }
  }

  Future<bool> changePassword(String userId, String currentPassword, String newPassword) async {
    try {
      // En una implementación real, aquí se cambiaría la contraseña en Firebase Auth
      // Por ahora, simulamos que siempre es exitoso
      return true;
    } catch (e) {
      print('Error al cambiar contraseña: $e');
      return false;
    }
  }
}