import 'package:flutter/material.dart';
import 'package:flutter_chat_app/src/auth/providers/auth_provider.dart';
import 'package:flutter_chat_app/src/chat/domain/models/message.dart';
import 'package:flutter_chat_app/src/user/domain/models/user.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

class ChatPage extends StatefulWidget {
  static const pageName = '/chat';

  const ChatPage({super.key});

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final datePattern = 'dd/MM/yyyy, HH:mm';

  List<Message> messages = [
    Message(
      author: 'John Doe',
      message: 'Hey dev!',
      timestamp: DateTime.now()
        ..subtract(
          const Duration(minutes: 5),
        ),
    ),
    Message(
      author: 'John Doe',
      message: 'How are you?',
      timestamp: DateTime.now()
        ..subtract(
          const Duration(minutes: 4),
        ),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final currentUser = getCurrentUser(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Chat")),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          children: [
            Flexible(
              flex: 1,
              child: (messages.isEmpty)
                  ? const Center(
                      child: Text('Nenhuma mensagem recebida...'),
                    )
                  : ListView.builder(
                      itemCount: messages.length,
                      reverse: true,
                      controller: _scrollController,
                      itemBuilder: (_, index) {
                        final message = messages[index];
                        return Column(
                          crossAxisAlignment: message.isMe(currentUser.email)
                              ? CrossAxisAlignment.end
                              : CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: message.isMe(currentUser.email)
                                  ? MainAxisAlignment.end
                                  : MainAxisAlignment.start,
                              children: [
                                Container(
                                  padding: const EdgeInsets.all(10),
                                  margin: message.isMe(currentUser.email)
                                      ? const EdgeInsets.only(right: 10)
                                      : const EdgeInsets.only(left: 10),
                                  width: 200,
                                  decoration: BoxDecoration(
                                    color: Colors.black12,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        message.author,
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        message.message,
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            Container(
                              margin: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Text(
                                DateFormat(datePattern).format(
                                  message.timestamp,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
            ),
            SizedBox(
              height: 60,
              width: double.infinity,
              child: Row(
                children: [
                  Flexible(
                    child: TextField(
                      controller: _messageController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                      ),
                    ),
                  ),
                  PopupMenuButton<String>(
                    icon: const Icon(Icons.attach_file),
                    onSelected: (value) {
                      // Ação para cada item selecionado
                      if (value == 'audio') {
                        // Abrir gravação de áudio
                      } else if (value == 'video') {
                        // Abrir gravação de vídeo
                      } else if (value == 'photo') {
                        // Tirar foto
                      }
                    },
                    itemBuilder: (BuildContext context) => [
                      const PopupMenuItem(
                        value: 'audio',
                        child: Text('Gravar Áudio'),
                      ),
                      const PopupMenuItem(
                        value: 'video',
                        child: Text('Gravar Vídeo'),
                      ),
                      const PopupMenuItem(
                        value: 'photo',
                        child: Text('Tirar Foto'),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.only(left: 8),
                    child: IconButton(
                      icon: const Icon(Icons.send_rounded),
                      onPressed: () async => await _handleSubmit(context),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _handleSubmit(BuildContext context) async {
    if (_messageController.text.isNotEmpty) {
      messages.add(
        Message(
          author: getCurrentUser(context).email!,
          message: _messageController.text,
          timestamp: DateTime.now(),
        ),
      );
      _messageController.clear();
      messages.sort((a, b) => b.timestamp.compareTo(a.timestamp));
      setState(() {});
    }
  }

  User getCurrentUser(context) {
    final authProvider = Provider.of<AuthProv>(listen: false, context);
    return authProvider.getUserInfo()!;
  }
}
