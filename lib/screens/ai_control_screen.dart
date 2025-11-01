import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/ai_controller.dart';
import '../controllers/auth_controller.dart';
import '../services/notification_service.dart';
import '../models/chat_message.dart';
import 'package:intl/intl.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'notifications_screen.dart';

class AIControlScreen extends StatefulWidget {
  const AIControlScreen({Key? key}) : super(key: key);

  @override
  State<AIControlScreen> createState() => _AIControlScreenState();
}

class _AIControlScreenState extends State<AIControlScreen> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  late AIController _aiController;

  @override
  void initState() {
    super.initState();
    // Obtener o crear el controlador de IA (evita duplicados)
    if (Get.isRegistered<AIController>()) {
      _aiController = Get.find<AIController>();
    } else {
      _aiController = Get.put(AIController());
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final authController = Get.find<AuthController>();
    final userId = authController.user?.uid ?? '';

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        backgroundColor: const Color(0xFF00BCD4),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Get.back(),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'AgriSense Pro',
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            Row(
              children: [
                const Text(
                  'Chat IA - Powered by ',
                  style: TextStyle(
                    fontSize: 11,
                    color: Colors.white70,
                  ),
                ),
                SvgPicture.asset(
                  'lib/assets/groq-text.svg',
                  height: 12,
                  colorFilter: const ColorFilter.mode(
                    Colors.white70,
                    BlendMode.srcIn,
                  ),
                ),
              ],
            ),
          ],
        ),
        actions: [
          StreamBuilder<int>(
            stream: NotificationService().getUnreadCount(userId),
            builder: (context, snapshot) {
              final unreadCount = snapshot.data ?? 0;

              return IconButton(
                icon: Stack(
                  children: [
                    const Icon(Icons.notifications_outlined, color: Colors.white),
                    if (unreadCount > 0)
                      Positioned(
                        right: 0,
                        top: 0,
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          constraints: const BoxConstraints(
                            minWidth: 16,
                            minHeight: 16,
                          ),
                          child: Text(
                            '$unreadCount',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                  ],
                ),
                onPressed: () {
                  Get.to(() => const NotificationsScreen());
                },
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.assessment, color: Colors.white),
            onPressed: () {
              _aiController.generateReport();
            },
            tooltip: 'Generar reporte',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              _aiController.refreshContext();
            },
            tooltip: 'Actualizar contexto',
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Limpiar chat'),
                  content: const Text('¿Deseas borrar todo el historial de conversación?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Cancelar'),
                    ),
                    TextButton(
                      onPressed: () {
                        _aiController.clearChat();
                        Navigator.pop(context);
                      },
                      child: const Text('Limpiar'),
                    ),
                  ],
                ),
              );
            },
            tooltip: 'Limpiar chat',
          ),
        ],
      ),
      body: Column(
        children: [
          // Área de chat
          Expanded(
            child: Obx(() {
              final messages = _aiController.messages;

              // Auto scroll al final cuando hay nuevos mensajes
              WidgetsBinding.instance.addPostFrameCallback((_) {
                _scrollToBottom();
              });

              if (messages.isEmpty) {
                return const Center(
                  child: CircularProgressIndicator(),
                );
              }

              return ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(16),
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[index];
                  return _buildMessageBubble(message);
                },
              );
            }),
          ),

          // Indicador de carga
          Obx(() {
            if (_aiController.isLoading.value) {
              return Container(
                padding: const EdgeInsets.all(8),
                color: Colors.white,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    SizedBox(width: 8),
                    Text('Pensando...', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              );
            }
            return const SizedBox.shrink();
          }),

          // Campo de entrada de texto
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            padding: const EdgeInsets.all(12),
            child: SafeArea(
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _messageController,
                      decoration: InputDecoration(
                        hintText: 'Pregunta sobre tu invernadero...',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: BorderSide(color: Colors.grey.shade300),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(24),
                          borderSide: const BorderSide(color: Color(0xFF2196F3)),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        filled: true,
                        fillColor: Colors.grey.shade50,
                      ),
                      maxLines: null,
                      textInputAction: TextInputAction.send,
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Obx(() {
                    final isLoading = _aiController.isLoading.value;
                    return FloatingActionButton(
                      onPressed: isLoading ? null : _sendMessage,
                      backgroundColor: isLoading
                          ? Colors.grey.shade300
                          : const Color(0xFF2196F3),
                      mini: true,
                      child: Icon(
                        Icons.send,
                        color: isLoading ? Colors.grey : Colors.white,
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageBubble(ChatMessage message) {
    final isUser = message.isUser;
    final timeFormat = DateFormat('HH:mm');

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isUser) ...[
            CircleAvatar(
              backgroundColor: const Color(0xFF00BCD4),
              radius: 16,
              child: const Icon(Icons.smart_toy, size: 16, color: Colors.white),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.7,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: isUser ? const Color(0xFF2196F3) : Colors.white,
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(16),
                  topRight: const Radius.circular(16),
                  bottomLeft: Radius.circular(isUser ? 16 : 4),
                  bottomRight: Radius.circular(isUser ? 4 : 16),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Usar Markdown para mensajes de la IA, Text para mensajes del usuario
                  if (isUser)
                    Text(
                      message.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                      ),
                    )
                  else
                    MarkdownBody(
                      data: message.message,
                      styleSheet: MarkdownStyleSheet(
                        p: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          height: 1.5,
                        ),
                        strong: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                        listBullet: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                        ),
                        listIndent: 20,
                        em: const TextStyle(
                          color: Colors.black87,
                          fontSize: 15,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                      shrinkWrap: true,
                    ),
                  const SizedBox(height: 4),
                  Text(
                    timeFormat.format(message.timestamp),
                    style: TextStyle(
                      color: isUser ? Colors.white70 : Colors.grey.shade600,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ),
          if (isUser) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              backgroundColor: const Color(0xFF2196F3),
              radius: 16,
              child: const Icon(Icons.person, size: 16, color: Colors.white),
            ),
          ],
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      _aiController.sendMessage(text);
      _messageController.clear();
      // Auto scroll después de enviar
      Future.delayed(const Duration(milliseconds: 100), _scrollToBottom);
    }
  }
}
