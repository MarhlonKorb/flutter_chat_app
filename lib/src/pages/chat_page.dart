import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/src/widgets/default_app_bar.dart';
import 'package:flutter_sound/flutter_sound.dart';
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
  List<Map<String, dynamic>> _messages = [];
  bool isRecording = false;
  String? _audioPath;
  Timer? _timer;
  Duration _recordDuration = Duration.zero;
  int? currentlyPlayingIndex; // Índice da mensagem que está sendo reproduzida

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
  }

  Future<void> _initializeRecorder() async {
    await Permission.microphone.request();
    await _recorder.openRecorder();
  }

  @override
  void dispose() {
    _recorder.closeRecorder();
    _player.closePlayer();
    _timer?.cancel();
    _messageController.dispose();
    super.dispose();
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
      // Se já estiver tocando o áudio atual, pare o player
      await _player.stopPlayer();
      setState(() {
        currentlyPlayingIndex = null;
      });
    } else {
      // Para o áudio anterior, se houver, e começa o novo
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

  void _addMessage({required String? content, required bool isAudio}) {
    setState(() {
      _messages.add({
        'content': content,
        'isAudio': isAudio,
        'time': DateTime.now(),
      });
    });
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
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isAudio = message['isAudio'] as bool;
                return Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  child: Card(
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          isAudio
                              ? Row(
                                  children: [
                                    IconButton(
                                      icon: Icon(
                                        currentlyPlayingIndex == index
                                            ? Icons.stop
                                            : Icons.play_arrow,
                                        color: Colors.blueAccent,
                                      ),
                                      onPressed: () =>
                                          _playAudio(index, message['content']),
                                    ),
                                    Text(
                                        'Áudio: ${_formatDuration(_recordDuration)}'),
                                  ],
                                )
                              : Text(
                                  message['content'],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    color: Colors.black87,
                                  ),
                                ),
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
                      hintText: 'Digite sua mensagem...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  isRecording ? Icons.stop : Icons.mic,
                  color: isRecording ? Colors.red : Colors.blue,
                ),
                onPressed: isRecording ? _stopRecording : _startRecording,
              ),
              IconButton(
                icon: const Icon(Icons.camera_alt),
                onPressed: _sendMessage,
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

  String _formatTime(DateTime datetime) {
    return '${datetime.hour.toString().padLeft(2, '0')}:${datetime.minute.toString().padLeft(2, '0')}';
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      _addMessage(content: text, isAudio: false);
      _messageController.clear();
    }
  }
}
