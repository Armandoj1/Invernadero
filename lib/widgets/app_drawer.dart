import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/auth_controller.dart';
import '../screens/notifications_screen.dart';
import '../screens/alerts_screen.dart';
import '../screens/ai_control_screen.dart';

class AppDrawer extends StatelessWidget {
  final Function(int)? onNavigate;

  const AppDrawer({Key? key, this.onNavigate}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final user = authController.user;

    return Drawer(
      child: Column(
        children: [
          // Header del drawer
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF00BCD4), Color(0xFF2196F3)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: Colors.white,
              child: Text(
                user?.email?.substring(0, 1).toUpperCase() ?? 'U',
                style: const TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00BCD4),
                ),
              ),
            ),
            accountName: Text(
              user?.displayName ?? 'Usuario',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            accountEmail: Text(
              user?.email ?? '',
              style: const TextStyle(fontSize: 14),
            ),
          ),

          // Opciones del menú
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                ListTile(
                  leading: const Icon(Icons.dashboard, color: Color(0xFF00BCD4)),
                  title: const Text('Dashboard'),
                  onTap: () {
                    Navigator.pop(context);
                    if (onNavigate != null) {
                      onNavigate!(0);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.sensors, color: Color(0xFF00BCD4)),
                  title: const Text('Sensores'),
                  onTap: () {
                    Navigator.pop(context);
                    if (onNavigate != null) {
                      onNavigate!(1);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.tune, color: Color(0xFF00BCD4)),
                  title: const Text('Control IA'),
                  onTap: () {
                    Navigator.pop(context);
                    if (onNavigate != null) {
                      onNavigate!(2);
                    }
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.eco, color: Color(0xFF00BCD4)),
                  title: const Text('Cultivos'),
                  onTap: () {
                    Navigator.pop(context);
                    if (onNavigate != null) {
                      onNavigate!(3);
                    }
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.chat, color: Color(0xFF00BCD4)),
                  title: const Text('Chat IA'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() => const AIControlScreen());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.notifications, color: Color(0xFF00BCD4)),
                  title: const Text('Notificaciones'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() => const NotificationsScreen());
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.warning_amber, color: Color(0xFF00BCD4)),
                  title: const Text('Alertas'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.to(() => const AlertsScreen());
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.help_outline, color: Color(0xFF00BCD4)),
                  title: const Text('Ayuda'),
                  onTap: () {
                    Navigator.pop(context);
                    Get.snackbar(
                      'Ayuda',
                      'Documentación próximamente disponible',
                      snackPosition: SnackPosition.BOTTOM,
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.info_outline, color: Color(0xFF00BCD4)),
                  title: const Text('Acerca de'),
                  onTap: () {
                    Navigator.pop(context);
                    showAboutDialog(
                      context: context,
                      applicationName: 'AgriSense Pro',
                      applicationVersion: '1.0.0',
                      applicationIcon: const FlutterLogo(size: 48),
                      children: [
                        const Text(
                          'Sistema inteligente de monitoreo y control para invernaderos.',
                        ),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),

          // Botón de cerrar sesión
          Container(
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: Colors.grey.shade300),
              ),
            ),
            child: ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text(
                'Cerrar Sesión',
                style: TextStyle(color: Colors.red),
              ),
              onTap: () async {
                Navigator.pop(context);
                await authController.signOut();
                Get.offAllNamed('/login');
              },
            ),
          ),
        ],
      ),
    );
  }
}
