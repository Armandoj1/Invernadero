// ui/screens/profile_screen.dart
import 'package:provider/provider.dart';
import 'package:invernadero/controllers/perfilcontrollers.dart';
import 'package:invernadero/ui/home/editPerfil.dart';
import 'package:flutter/material.dart';


class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  @override
  void initState() {
    super.initState();
    // Cargar perfil al iniciar sólo si no existe en memoria (modo mock ya lo provee)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final controller = context.read<ProfileController>();
      if (controller.user == null) {
        controller.loadUserProfile('user123');
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mi Perfil'),
        backgroundColor: const Color(0xFF1565C0),
        elevation: 0,
      ),
      body: Consumer<ProfileController>(
        builder: (context, controller, child) {
          if (controller.isLoading && controller.user == null) {
            return const Center(child: CircularProgressIndicator());
          }

          if (controller.error != null && controller.user == null) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 60, color: Colors.red[300]),
                  const SizedBox(height: 16),
                  Text(
                    'Error al cargar perfil',
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => controller.loadUserProfile('user123'),
                    child: const Text('Reintentar'),
                  ),
                ],
              ),
            );
          }

          final user = controller.user!;

          return RefreshIndicator(
            onRefresh: () => controller.loadUserProfile(user.id),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Avatar y nombre
                  _buildHeader(user),
                  const SizedBox(height: 24),

                  // Información personal
                  _buildInfoCard(
                    title: 'Información Personal',
                    icon: Icons.person,
                    children: [
                      _buildInfoRow('Nombre', user.nombre),
                      const Divider(),
                      _buildInfoRow('Apellido', user.apellido),
                      const Divider(),
                      _buildInfoRow(
                        'Teléfono',
                        user.telefono ?? 'No especificado',
                      ),
                      const Divider(),
                      _buildInfoRow(
                        'Dirección',
                        user.direccion ?? 'No especificada',
                      ),
                    ],
                    onEdit: () => _showEditProfileDialog(context, user),
                  ),
                  const SizedBox(height: 16),

                  // Información de cuenta
                  _buildInfoCard(
                    title: 'Cuenta',
                    icon: Icons.email,
                    children: [
                      _buildInfoRow('Correo', user.email),
                    ],
                    onEdit: () => _showChangeEmailDialog(context),
                  ),
                  const SizedBox(height: 16),

                  // Seguridad
                  _buildActionCard(
                    title: 'Seguridad',
                    icon: Icons.lock,
                    actions: [
                      ListTile(
                        leading: const Icon(Icons.vpn_key, color: Colors.orange),
                        title: const Text('Cambiar Contraseña'),
                        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                        onTap: () => _showChangePasswordDialog(context),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildHeader(user) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          CircleAvatar(
            radius: 50,
            backgroundColor: const Color(0xFF1565C0),
            child: Text(
              user.nombre[0].toUpperCase(),
              style: const TextStyle(fontSize: 36, color: Colors.white),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user.nombreCompleto,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user.email,
            style: TextStyle(fontSize: 16, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard({
    required String title,
    required IconData icon,
    required List<Widget> children,
    VoidCallback? onEdit,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF1565C0)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (onEdit != null)
                  IconButton(
                    icon: const Icon(Icons.edit, color: Color(0xFF00B4D8)),
                    onPressed: onEdit,
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(children: children),
          ),
        ],
      ),
    );
  }

  Widget _buildActionCard({
    required String title,
    required IconData icon,
    required List<Widget> actions,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(icon, color: const Color(0xFF1565C0)),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          ...actions,
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
              fontWeight: FontWeight.w500,
            ),
          ),
          Flexible(
            child: Text(
              value,
              style: const TextStyle(fontSize: 16),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }

  void _showEditProfileDialog(BuildContext context, user) {
    showDialog(
      context: context,
      builder: (context) => EditProfileDialog(user: user),
    );
  }

  void _showChangePasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ChangePasswordDialog(),
    );
  }

  void _showChangeEmailDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const ChangeEmailDialog(),
    );
  }
}