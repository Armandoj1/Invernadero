// ui/app.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:invernadero/controllers/perfilcontrollers.dart';
import 'package:invernadero/services/perfilservices.dart';
import 'package:invernadero/ui/home/perfil.dart';
import 'package:invernadero/models/perfil.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Inicializar el servicio en modo mock con datos estáticos
    final userService = UserService.mock(
      initialUser: UserModel(
        id: 'user123',
        nombre: 'Dario',
        apellido: 'Pérez',
        email: 'dario@example.com',
        telefono: '555-123-456',
        direccion: 'Calle 123, Ciudad',
        fechaRegistro: DateTime(2024, 1, 1),
      ),
    );

    return MultiProvider(
      providers: [
        // Proveedor del controlador de perfil
        ChangeNotifierProvider(
          create: (_) => ProfileController(userService: userService),
        ),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Hibernadero',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF1565C0)),
          useMaterial3: true,
          appBarTheme: const AppBarTheme(
            backgroundColor: Color(0xFF1565C0),
            foregroundColor: Colors.white,
            elevation: 0,
            centerTitle: true,
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF1565C0),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: const Color(0xFF1565C0),
            ),
          ),
          inputDecorationTheme: InputDecorationTheme(
            border: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: const BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.grey[300]!),
            ),
            focusedBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Color(0xFF1565C0), width: 2),
            ),
            errorBorder: const OutlineInputBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
              borderSide: BorderSide(color: Colors.red),
            ),
            filled: true,
            fillColor: Colors.grey[50],
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          // cardTheme configurado por defecto para compatibilidad con la versión actual de Flutter
        ),
        home: const ProfileScreen(),
      ),
    );
  }
}