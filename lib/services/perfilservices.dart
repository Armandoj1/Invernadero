// services/user_service.dart

import 'dart:convert';

import 'package:invernadero/models/perfil.dart';
import 'package:http/http.dart' as http;

class UserService {
  final String baseUrl;

  // MODO MOCK (datos en memoria para desarrollo sin backend)
  final bool _mockMode;
  final Map<String, UserModel> _store;

  // Constructor real (API)
  UserService({required this.baseUrl})
      : _mockMode = false,
        _store = {};

  // Constructor mock (usa datos estáticos en memoria)
  UserService.mock({UserModel? initialUser})
      : baseUrl = '_mock',
        _mockMode = true,
        _store = {
          (initialUser?.id ?? 'user123'):
              initialUser ??
                  UserModel(
                    id: 'user123',
                    nombre: 'Dario',
                    apellido: 'Pérez',
                    email: 'dario@example.com',
                    telefono: '555-123-456',
                    direccion: 'Calle 123, Ciudad',
                    fechaRegistro: DateTime(2024, 1, 1),
                  ),
        };

  // Obtener perfil del usuario
  Future<UserModel> getUserProfile(String userId) async {
    if (_mockMode) {
      await Future.delayed(const Duration(milliseconds: 400));
      final user = _store[userId];
      if (user != null) return user;
      throw Exception('Usuario no encontrado');
    }

    try {
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      } else {
        throw Exception('Error al cargar el perfil');
      }
    } catch (e) {
      throw Exception('Error de conexión: $e');
    }
  }

  // Actualizar datos personales
  Future<bool> updateUserProfile(UserModel user) async {
    if (_mockMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      _store[user.id] = user;
      return true;
    }

    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/${user.id}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(user.toJson()),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al actualizar perfil: $e');
    }
  }

  // Cambiar contraseña
  Future<bool> changePassword(
    String userId,
    String currentPassword,
    String newPassword,
  ) async {
    if (_mockMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      // En modo mock, validamos que la nueva contraseña sea distinta
      if (currentPassword == newPassword) {
        throw Exception('La nueva contraseña debe ser diferente');
      }
      return true;
    }

    try {
      final response = await http.post(
        Uri.parse('$baseUrl/users/$userId/change-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        }),
      );

      if (response.statusCode == 200) {
        return true;
      } else if (response.statusCode == 401) {
        throw Exception('Contraseña actual incorrecta');
      } else {
        throw Exception('Error al cambiar contraseña');
      }
    } catch (e) {
      throw Exception('Error: $e');
    }
  }

  // Actualizar email
  Future<bool> updateEmail(String userId, String newEmail) async {
    if (_mockMode) {
      await Future.delayed(const Duration(milliseconds: 300));
      final user = _store[userId];
      if (user == null) throw Exception('Usuario no encontrado');
      _store[userId] = user.copyWith(email: newEmail);
      return true;
    }

    try {
      final response = await http.patch(
        Uri.parse('$baseUrl/users/$userId/email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': newEmail}),
      );

      return response.statusCode == 200;
    } catch (e) {
      throw Exception('Error al actualizar email: $e');
    }
  }
}