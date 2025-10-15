class UserModel {
  final String uid;
  final String email;
  final String? displayName;
  final String? nombre;
  final String? apellido;
  final String? telefono;
  final String? direccion;

  UserModel({
    required this.uid,
    required this.email,
    this.displayName,
    this.nombre,
    this.apellido,
    this.telefono,
    this.direccion,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      email: json['email'] ?? '',
      displayName: json['displayName'],
      nombre: json['nombre'],
      apellido: json['apellido'],
      telefono: json['telefono'],
      direccion: json['direccion'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'email': email,
      'displayName': displayName,
      'nombre': nombre,
      'apellido': apellido,
      'telefono': telefono,
      'direccion': direccion,
    };
  }
}
