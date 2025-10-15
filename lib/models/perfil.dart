// models/profile_model.dart

class ProfileModel {
  final String id;
  final String nombre;
  final String apellido;
  final String email;
  final String? telefono;
  final String? direccion;
  final DateTime fechaRegistro;

  ProfileModel({
    required this.id,
    required this.nombre,
    required this.apellido,
    required this.email,
    this.telefono,
    this.direccion,
    required this.fechaRegistro,
  });

  // Método para crear desde JSON
  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'] ?? '',
      nombre: json['nombre'] ?? '',
      apellido: json['apellido'] ?? '',
      email: json['email'] ?? '',
      telefono: json['telefono'],
      direccion: json['direccion'],
      fechaRegistro: json['fechaRegistro'] != null
          ? DateTime.parse(json['fechaRegistro'])
          : DateTime.now(),
    );
  }

  // Método para convertir a JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nombre': nombre,
      'apellido': apellido,
      'email': email,
      'telefono': telefono,
      'direccion': direccion,
      'fechaRegistro': fechaRegistro.toIso8601String(),
    };
  }

  // Método para copiar con cambios
  ProfileModel copyWith({
    String? id,
    String? nombre,
    String? apellido,
    String? email,
    String? telefono,
    String? direccion,
    DateTime? fechaRegistro,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      nombre: nombre ?? this.nombre,
      apellido: apellido ?? this.apellido,
      email: email ?? this.email,
      telefono: telefono ?? this.telefono,
      direccion: direccion ?? this.direccion,
      fechaRegistro: fechaRegistro ?? this.fechaRegistro,
    );
  }

  String get nombreCompleto => '$nombre $apellido';
}

// models/change_password_request.dart
class ChangePasswordRequest {
  final String currentPassword;
  final String newPassword;

  ChangePasswordRequest({
    required this.currentPassword,
    required this.newPassword,
  });

  Map<String, dynamic> toJson() {
    return {
      'currentPassword': currentPassword,
      'newPassword': newPassword,
    };
  }
}