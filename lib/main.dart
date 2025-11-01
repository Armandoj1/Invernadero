// main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:get/get.dart';
import 'package:invernadero/ui/auth/register_view.dart';
import 'firebase_options.dart';
import 'controllers/auth_controller.dart';
import 'ui/auth/login_view.dart';
import 'screens/dashboard_screen.dart';
import 'screens/alerts_screen.dart';
import 'screens/sensors_screen.dart';
import 'screens/crops_screen.dart';
import 'screens/lettuce_detail_screen.dart';
import 'screens/trends_detail_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  // Inicializar el controlador de autenticación
  Get.put(AuthController());
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Invernadero Inteligente',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF00BCD4),
          primary: const Color(0xFF00BCD4),
        ),
        useMaterial3: true,
      ),
      initialRoute: '/login',
      getPages: [
        GetPage(name: '/login', page: () => const LoginView()),
        GetPage(
          name: '/dashboard', 
          page: () => GetBuilder<AuthController>(
            builder: (controller) => DashboardScreen(userId: controller.user?.uid ?? ''),
          ),
        ),
        GetPage(name: '/register', page: () => RegisterView()),
        GetPage(name: '/sensors', page: () => const SensorsScreen()),
        GetPage(name: '/alerts', page: () => const AlertsScreen()),
        GetPage(name: '/cultivos', page: () => const CropsScreen()),
        GetPage(name: '/cultivos/lechuga', page: () => LettuceDetailScreen()),
        GetPage(name: '/trends', page: () => const TrendsDetailScreen()),
      ],
    );
  }
}