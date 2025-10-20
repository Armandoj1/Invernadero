import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:invernadero/controllers/perfilcontrollers.dart';
import 'package:invernadero/services/perfilservices.dart';
import 'package:invernadero/models/perfil.dart';
import 'package:invernadero/ui/home/perfil.dart';
import 'package:invernadero/controllers/ia_control_controller.dart';
import 'package:invernadero/services/ia_control_service.dart';
import 'package:invernadero/ui/home/ia_control.dart';
import 'controllers/auth_controller.dart';
import 'firebase_options.dart';
import 'ui/auth/login_view.dart';
import 'ui/auth/register_view.dart';
import 'ui/home/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Configurar Firestore con configuración optimizada para evitar errores de conexión
  FirebaseFirestore.instance.settings = const Settings(
    persistenceEnabled: false,
    cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
    sslEnabled: true,
  );

  // Inicializar el controlador de autenticación
  Get.put(AuthController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider<ProfileController>(
          create: (_) {
            final auth = Get.find<AuthController>();
            final u = auth.user;
            ProfileModel? initial;
            if (u != null) {
              final parts = (u.displayName ?? '').trim().split(' ');
              final nombre = parts.isNotEmpty && parts.first.isNotEmpty ? parts.first : 'Usuario';
              final apellido = parts.length > 1 ? parts.sublist(1).join(' ') : '';
              initial = ProfileModel(
                id: u.uid,
                nombre: nombre,
                apellido: apellido,
                email: u.email,
                telefono: null,
                direccion: null,
                fechaRegistro: DateTime.now(),
              );
            }
            return ProfileController(userService: UserService());
          },
        ),
        ChangeNotifierProvider<IAControlController>(
          create: (_) => IAControlController(service: IAControlService()),
        ),
      ],
      child: GetMaterialApp(
        title: 'Invernadero',
        debugShowCheckedModeBanner: false,
        showPerformanceOverlay: false,
        showSemanticsDebugger: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00BCD4),
            primary: const Color(0xFF00BCD4),
          ),
          useMaterial3: true,
        ),
        // Configurar rutas
        initialRoute: '/',
        getPages: [
          GetPage(
            name: '/',
            page: () => const AuthWrapper(),
          ),
          GetPage(
            name: '/login',
            page: () => const LoginView(),
          ),
          GetPage(
            name: '/register',
            page: () => const RegisterView(),
          ),
          GetPage(
            name: '/home',
            page: () => const HomeView(),
          ),
          GetPage(
            name: '/profile',
            page: () => const ProfileScreen(),
          ),
          GetPage(
            name: '/ia-control',
            page: () => const IAControlScreen(),
          ),
        ],
      ),
    );
  }
}

// Widget para manejar la autenticación
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();

    return Obx(() {
      // Si hay un usuario autenticado, mostrar HomeView
      if (authController.user != null) {
        return const HomeView();
      }
      // Si no hay usuario, mostrar LoginView
      return const LoginView();
    });
  }
}