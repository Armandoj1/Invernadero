import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../widgets/app_drawer.dart';
import 'dashboard_screen.dart';
import 'sensors_screen.dart';
import 'ai_settings_screen.dart';
import 'ai_control_screen.dart';
import 'crops_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({Key? key}) : super(key: key);

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _selectedIndex = 0;
  late final List<Widget> _screens;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    final authController = Get.find<AuthController>();
    final userId = authController.user?.uid ?? '';

    // Crear las pantallas una sola vez - Solo 4 pantallas principales
    _screens = [
      DashboardScreen(userId: userId),
      const SensorsScreen(),
      const AISettingsScreen(),
      const CropsScreen(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      drawer: AppDrawer(
        onNavigate: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _selectedIndex >= 2 ? _selectedIndex + 1 : _selectedIndex,
          onTap: (index) {
            if (index == 2) {
              // Botón del medio - Abrir Chat IA
              Get.to(() => const AIControlScreen());
            } else {
              // Ajustar índice para las otras pantallas
              // Botón 0,1 -> Pantalla 0,1
              // Botón 3,4 -> Pantalla 2,3
              final screenIndex = index > 2 ? index - 1 : index;
              _onItemTapped(screenIndex);
            }
          },
          items: [
            const BottomNavigationBarItem(
              icon: Icon(Icons.dashboard),
              label: 'Dashboard',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.sensors),
              label: 'Sensores',
            ),
            BottomNavigationBarItem(
              icon: Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  color: Color(0xFF00BCD4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.chat_bubble_outline,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              label: 'Chat IA',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.tune),
              label: 'Control IA',
            ),
            const BottomNavigationBarItem(
              icon: Icon(Icons.eco),
              label: 'Cultivos',
            ),
          ],
          selectedItemColor: const Color(0xFF00BCD4),
          unselectedItemColor: Colors.grey,
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          elevation: 0,
          selectedFontSize: 12,
          unselectedFontSize: 12,
        ),
      ),
    );
  }
}
