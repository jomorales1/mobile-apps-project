import 'package:flutter/material.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

class ChatbotView extends StatefulWidget {
  final VoidCallback onBack;

  const ChatbotView({super.key, required this.onBack});

  @override
  State<ChatbotView> createState() => _ChatbotViewState();
}

class _ChatbotViewState extends State<ChatbotView> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  static const String n8nWebhookUrl = 'URL_DE_TU_WEBHOOK_N8N';

  @override
  void initState() {
    super.initState();
    _addBotMessage('¡Hola! Soy UN bot. ¿En qué puedo ayudarte?');
  }

  void _resetChat() {
    setState(() {
      _messages.clear();
    });
    _messageController.clear();
    _addBotMessage('¡Hola! Soy UN bot. ¿En qué puedo ayudarte?');
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _addBotMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: false,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _addUserMessage(String text) {
    setState(() {
      _messages.add(ChatMessage(
        text: text,
        isUser: true,
        timestamp: DateTime.now(),
      ));
    });
    _scrollToBottom();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleSendMessage() {
    final text = _messageController.text.trim();
    if (text.isEmpty || _isLoading) return;

    _addUserMessage(text);
    _messageController.clear();

    // Agregar indicador de "escribiendo..."
    setState(() {
      _isLoading = true;
    });
    _addBotMessage('escribiendo...');

    _sendToBot(text);
  }

  Future<void> _sendToBot(String userMessage) async {
    try {
      // Llamada a la API de n8n con Groq
      final response = await http.post(
        Uri.parse(n8nWebhookUrl),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'message': userMessage,
        }),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw TimeoutException('La solicitud tardó demasiado');
        },
      );

      // Remover el mensaje "escribiendo..."
      setState(() {
        _isLoading = false;
        if (_messages.isNotEmpty && _messages.last.text == 'escribiendo...') {
          _messages.removeLast();
        }
      });

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final botResponse = data['response'] ?? 'Lo siento, no pude procesar tu mensaje.';
        _addBotMessage(botResponse);
      } else {
        _addBotMessage('Lo siento, hubo un error al procesar tu mensaje. Por favor intenta de nuevo.');
        print('Error: ${response.statusCode} - ${response.body}');
      }
    } on TimeoutException {
      setState(() {
        _isLoading = false;
        if (_messages.isNotEmpty && _messages.last.text == 'escribiendo...') {
          _messages.removeLast();
        }
      });
      _addBotMessage('⏱️ La respuesta está tardando demasiado. Por favor intenta con una pregunta más corta.');
    } catch (e) {
      setState(() {
        _isLoading = false;
        if (_messages.isNotEmpty && _messages.last.text == 'escribiendo...') {
          _messages.removeLast();
        }
      });
      _addBotMessage('❌ Error de conexión. Verifica tu internet e intenta de nuevo.');
      print('Error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    const greenDark = Color(0xFF1B5E20);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: greenDark,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: widget.onBack,
        ),
        title: Row(
          children: const [
            CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.smart_toy, color: greenDark),
            ),
            SizedBox(width: 12),
            Text(
              'UN bot',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        actions: [
          // Botón para reiniciar el chat
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: () {
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: const Text('¿Reiniciar chat?'),
                    content: const Text('¿Deseas reiniciar la conversación?'),
                    actions: [
                      TextButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text('Cancelar'),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          _resetChat();
                        },
                        child: const Text('Reiniciar'),
                      ),
                    ],
                  );
                },
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _messages.isEmpty
                ? Center(
                    child: Text(
                      'Inicia una conversación',
                      style: TextStyle(
                        color: Colors.grey[400],
                        fontSize: 16,
                      ),
                    ),
                  )
                : ListView.builder(
                    controller: _scrollController,
                    padding: const EdgeInsets.all(16),
                    itemCount: _messages.length,
                    itemBuilder: (context, index) {
                      return MessageBubble(message: _messages[index]);
                    },
                  ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  offset: const Offset(0, -2),
                  blurRadius: 4,
                  color: Colors.black.withOpacity(0.1),
                ),
              ],
            ),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    enabled: !_isLoading,
                    decoration: InputDecoration(
                      hintText: _isLoading ? 'Esperando respuesta...' : 'Escribe un mensaje...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide.none,
                      ),
                      filled: true,
                      fillColor: _isLoading ? Colors.grey[200] : Colors.grey[100],
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 10,
                      ),
                    ),
                    onSubmitted: (_) => _handleSendMessage(),
                    textInputAction: TextInputAction.send,
                  ),
                ),
                const SizedBox(width: 8),
                CircleAvatar(
                  backgroundColor: _isLoading ? Colors.grey : greenDark,
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            color: Colors.white,
                            strokeWidth: 2,
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.send, color: Colors.white, size: 20),
                          onPressed: _handleSendMessage,
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class ChatMessage {
  final String text;
  final bool isUser;
  final DateTime timestamp;

  ChatMessage({
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}

class MessageBubble extends StatelessWidget {
  final ChatMessage message;

  const MessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    const greenDark = Color(0xFF1B5E20);
    final isTyping = message.text == 'escribiendo...';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment:
            message.isUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!message.isUser) ...[
            const CircleAvatar(
              radius: 16,
              backgroundColor: greenDark,
              child: Icon(Icons.smart_toy, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: message.isUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: message.isUser ? greenDark : Colors.grey[200],
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: isTyping
                      ? Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              message.text,
                              style: const TextStyle(
                                color: Colors.black87,
                                fontSize: 15,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const SizedBox(
                              width: 12,
                              height: 12,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(greenDark),
                              ),
                            ),
                          ],
                        )
                      : Text(
                          message.text,
                          style: TextStyle(
                            color: message.isUser ? Colors.white : Colors.black87,
                            fontSize: 15,
                          ),
                        ),
                ),
                if (!isTyping) ...[
                  const SizedBox(height: 4),
                  Text(
                    _formatTime(message.timestamp),
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 11,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (message.isUser) ...[
            const SizedBox(width: 8),
            const CircleAvatar(
              radius: 16,
              backgroundColor: Color(0xFFB9F6CA),
              child: Icon(Icons.person, color: greenDark, size: 18),
            ),
          ],
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    return '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}