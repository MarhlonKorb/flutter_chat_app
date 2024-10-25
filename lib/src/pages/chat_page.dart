import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/src/pages/full_screen_image.dart';
import 'package:flutter_chat_app/src/widgets/default_app_bar.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatPage extends StatefulWidget {
  const ChatPage({super.key});

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final FlutterSoundRecorder _recorder = FlutterSoundRecorder();
  final FlutterSoundPlayer _player = FlutterSoundPlayer();
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController =
      ScrollController(); // Scroll controller
  final List<Map<String, dynamic>> _messages = [];
  bool isRecording = false;
  String? _audioPath;
  Timer? _timer;
  Duration _recordDuration = Duration.zero;
  int? currentlyPlayingIndex;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    // Mensagens simuladas de outro usuário
    _messages.addAll([
      {
        'content': 'Oi, como você está?',
        'isAudio': false,
        'isImage': false,
        'isVideo': false,
        'isSentByMe': false,
        'time': DateTime.now().subtract(const Duration(minutes: 2)),
      },
      {
        'content': 'Estou bem, e você?',
        'isAudio': false,
        'isImage': false,
        'isVideo': false,
        'isSentByMe': true,
        'time': DateTime.now().subtract(const Duration(minutes: 1)),
      },
    ]);
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    _timer?.cancel();
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _initializeRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
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

  Future<void> _startRecording() async {
    if (await Permission.microphone.request().isGranted) {
      final path =
          '${Directory.systemTemp.path}/audio_${DateTime.now().millisecondsSinceEpoch}.aac';
      await _recorder.startRecorder(toFile: path);
      setState(() {
        isRecording = true;
        _audioPath = path;
        _recordDuration = Duration.zero;
      });

      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        setState(() {
          _recordDuration = Duration(seconds: timer.tick);
        });
      });
    }
  }

  Future<void> _stopRecording() async {
    await _recorder.stopRecorder();
    setState(() {
      isRecording = false;
      _timer?.cancel();
    });

    if (_audioPath != null) {
      _addMessage(content: _audioPath, isAudio: true);
    }
  }

  Future<void> _playAudio(int index, String audioPath) async {
    if (currentlyPlayingIndex == index) {
      await _player.stopPlayer();
      setState(() {
        currentlyPlayingIndex = null;
      });
    } else {
      if (currentlyPlayingIndex != null) {
        await _player.stopPlayer();
      }
      await _player.openPlayer();
      setState(() {
        currentlyPlayingIndex = index;
      });
      await _player.startPlayer(
        fromURI: audioPath,
        whenFinished: () {
          setState(() {
            currentlyPlayingIndex = null;
          });
        },
      );
    }
  }

  void _addMessage({
    required String? content,
    required bool isAudio,
    bool isImage = false,
    bool isVideo = false,
    bool isSentByMe = true,
  }) {
    setState(() {
      _messages.add({
        'content': content,
        'isAudio': isAudio,
        'isImage': isImage,
        'isVideo': isVideo,
        'isSentByMe': isSentByMe,
        'time': DateTime.now(),
      });
    });
    // Rola para a última mensagem após adicionar uma nova
    _scrollToBottom();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: DefaultAppBar(
        title: "Marhlon",
        actions: [
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: _scrollController,
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isAudio = message['isAudio'] as bool;
                final isImage = message['isImage'] as bool;
                final isVideo = message['isVideo'] as bool;
                final isSentByMe = message['isSentByMe'] as bool;
                Widget messageContent;
                if (isAudio) {
                  messageContent = Row(
                    children: [
                      IconButton(
                        icon: Icon(
                          currentlyPlayingIndex == index
                              ? Icons.stop
                              : Icons.play_arrow,
                          color: Colors.blueAccent,
                        ),
                        onPressed: () => _playAudio(index, message['content']),
                      ),
                      Text('Áudio: ${_formatDuration(_recordDuration)}'),
                    ],
                  );
                } else if (isImage) {
                  messageContent = GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) =>
                              FullScreenImage(imagePath: message['content']),
                        ),
                      );
                    },
                    child: Hero(
                      tag: message['content'],
                      child: Image.file(
                        File(message['content']),
                        height: 150,
                        width: 150,
                        fit: BoxFit.cover,
                      ),
                    ),
                  );
                } else if (isVideo) {
                  messageContent = GestureDetector(
                    onTap: () {
                      // Lógica para abrir um player de vídeo
                    },
                    child: Container(
                      height: 150,
                      width: 150,
                      color: Colors.black,
                      child: const Center(
                        child: Icon(Icons.play_arrow,
                            color: Colors.white, size: 40),
                      ),
                    ),
                  );
                } else {
                  messageContent = Text(
                    message['content'],
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.black87,
                    ),
                  );
                }

                return Align(
                  alignment:
                      isSentByMe ? Alignment.centerRight : Alignment.centerLeft,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 10.0, vertical: 5.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        maxWidth: MediaQuery.of(context).size.width *
                            0.7, // Card menor
                      ),
                      child: Card(
                        color: isSentByMe
                            ? Colors.blue[50]
                            : Colors.grey[200], // Cores diferentes
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              messageContent,
                              const SizedBox(height: 5),
                              Align(
                                alignment: Alignment.bottomRight,
                                child: Text(
                                  _formatTime(message['time']),
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          if (isRecording)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text('Gravando: ${_formatDuration(_recordDuration)}'),
            ),
          Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      focusColor: Colors.blueAccent,
                      hintText: 'Digite sua mensagem...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),
              GestureDetector(
                onLongPress: _startRecording, 
                onLongPressUp: _stopRecording,
                child: CircleAvatar(
                  radius: isRecording ? 20 : 15,
                  backgroundColor: isRecording ? Colors.red : Colors.indigoAccent,
                  child: Icon(
                    isRecording ? Icons.stop : Icons.mic,
                    color: Colors.white,
                    size: isRecording ? 25 : 20,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: _showCameraOptions,
              ),
              IconButton(
                icon: const Icon(Icons.send),
                onPressed: _sendMessage,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _showCameraOptions() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: const Icon(Icons.photo_camera),
                title: const Text('Tirar Foto'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageOrVideo(ImageSource.camera, true);
                },
              ),
              ListTile(
                leading: const Icon(Icons.videocam),
                title: const Text('Gravar Vídeo'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageOrVideo(ImageSource.camera, false);
                },
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da Galeria'),
                onTap: () {
                  Navigator.of(context).pop();
                  _pickImageOrVideo(ImageSource.gallery, true);
                },
              ),
            ],
          ),
        );
      },
    );
  }

  void _pickImageOrVideo(ImageSource source, bool isImage) async {
    final picker = ImagePicker();
    XFile? pickedFile;

    if (isImage) {
      pickedFile = await picker.pickImage(source: source);
    } else {
      pickedFile = await picker.pickVideo(source: source);
    }

    if (pickedFile != null) {
      setState(() {
        _addMessage(
          content: pickedFile!.path,
          isAudio: false,
          isImage: isImage,
          isVideo: !isImage,
        );
      });
    }
  }

  void _sendMessage() {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      _addMessage(content: messageText, isAudio: false);
      _messageController.clear();
    }
  }

  String _formatTime(DateTime datetime) {
    return '${datetime.hour.toString().padLeft(2, '0')}:${datetime.minute.toString().padLeft(2, '0')}';
  }
}
