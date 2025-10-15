// controllers/profile_controller.dart

import 'package:flutter/material.dart';
import 'package:invernadero/models/perfil.dart';
import 'package:invernadero/models/user_model.dart';
import 'package:invernadero/services/perfilservices.dart';


class ProfileController extends ChangeNotifier {
  final UserService _userService;
  
  ProfileModel? _user;
  bool _isLoading = false;
  String? _error;
  
  ProfileModel? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;

  ProfileController({required UserService userService})
      : _userService = userService;

  // Establecer usuario desde AuthController
  void setUserFromAuth(UserModel authUser) {
    print('🔍 ProfileController - Datos recibidos del AuthController:');
    print('Nombre: ${authUser.nombre}');
    print('Apellido: ${authUser.apellido}');
    print('Teléfono: ${authUser.telefono}');
    print('Dirección: ${authUser.direccion}');
    
    _user = ProfileModel(
      id: authUser.uid,
      nombre: authUser.nombre ?? '',
      apellido: authUser.apellido ?? '',
      email: authUser.email,
      telefono: authUser.telefono ?? '',
      direccion: authUser.direccion ?? '',
      fechaRegistro: DateTime.now(),
    );
    
    print('🔍 ProfileController - ProfileModel creado:');
    print('Teléfono: ${_user?.telefono}');
    print('Dirección: ${_user?.direccion}');
    
    notifyListeners();
  }

  // Cargar perfil
  Future<void> loadUserProfile(String userId) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _user = await _userService.getUserProfile(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar datos personales
  Future<bool> updateProfile({
    required String nombre,
    required String apellido,
    String? telefono,
    String? direccion,
  }) async {
    if (_user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedUser = _user!.copyWith(
        nombre: nombre,
        apellido: apellido,
        telefono: telefono,
        direccion: direccion,
      );

      final success = await _userService.updateUserProfile(_user!.id, updatedUser);
      
      if (success) {
        _user = updatedUser;
        _error = null;
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Cambiar contraseña
  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    if (_user == null) return false;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final success = await _userService.changePassword(
        _user!.id,
        currentPassword,
        newPassword,
      );
      
      if (!success) {
        _error = 'No se pudo cambiar la contraseña';
      }
      
      return success;
    } catch (e) {
      _error = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Actualizar email
  Future<void> updateEmail(String newEmail) async {
    if (_user == null) return;
    
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Actualizar directamente en el modelo local
      _user = _user!.copyWith(email: newEmail);
      _error = null;
      
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _error = 'Error al actualizar email: $e';
      _isLoading = false;
      notifyListeners();
    }
  }

  // Limpiar error
  void clearError() {
    _error = null;
    notifyListeners();
  }
}