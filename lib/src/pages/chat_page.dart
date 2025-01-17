import 'dart:async';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/src/chat/application/impl/chat_service_mobile.dart';
import 'package:flutter_chat_app/src/chat/application/impl/chat_service_web.dart';
import 'package:flutter_chat_app/src/chat/domain/models/message.dart';
import 'package:flutter_chat_app/src/chat/domain/models/user_chat.dart';
import 'package:flutter_chat_app/src/pages/full_screen_image.dart';
import 'package:flutter_chat_app/src/widgets/custom_dialog.dart';
import 'package:flutter_chat_app/src/widgets/default_app_bar.dart';
import 'package:flutter_chat_app/src/widgets/default_text_form_field.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';

class ChatPage extends StatefulWidget {
  final UserChat userChat;

  const ChatPage({
    super.key,
    required this.userChat,
  });

  @override
  ChatPageState createState() => ChatPageState();
}

class ChatPageState extends State<ChatPage> {
  final _recorder = FlutterSoundRecorder();
  final _player = FlutterSoundPlayer();
  final _messageController = TextEditingController();
  final _scrollController = ScrollController();
  final _messages = <Message>[];
  bool isRecording = false;
  String? _audioPath;
  Timer? _timer;
  Duration _recordDuration = Duration.zero;
  int? currentlyPlayingIndex;
  final chatServiceWeb = ChatServiceWeb();
  final chatServiceMobile = ChatServiceMobile();
  // Para monitorar se o botão está sendo arrastado
  bool isDragging = false;
  bool isSendingMessage = false;
  String? arquivoNome;

  @override
  void initState() {
    super.initState();
    _initializeRecorder();
    // Mensagens simuladas de outro usuário
    _messages.addAll([
      Message(
        content: 'Oi, como posso lhe ajudar hoje?',
        isSentByMe: false,
        time: DateTime.now().subtract(const Duration(minutes: 2)),
      ),
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

  Future<void> _stopRecording({bool sendRecord = true}) async {
    await _recorder.stopRecorder();
    setState(() {
      isRecording = false;
      _timer?.cancel();
    });

    if (_audioPath != null && sendRecord) {
      await _addMessage(content: _audioPath, isAudio: true);
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

  Future<void> _addMessage({
    required String? content,
    required bool isAudio,
    bool isImage = false,
    bool isVideo = false,
    bool isArquiveWeb = false,
  }) async {
    late final String resultMsg;

    try {
      setState(() {
        isSendingMessage = true;
      });
      String fileName = '';
      if (kIsWeb) {
        if (isAudio || isImage || isVideo || isArquiveWeb) {
          Uint8List? fileBytes;

          if (content != null) {
            // Para web e mobile, obtemos o arquivo pelo `FilePicker`
            FilePickerResult? result = await FilePicker.platform.pickFiles();

            if (result != null && result.files.isNotEmpty) {
              fileBytes = result.files.single.bytes;
              fileName = result.files.single.name;
            } else {
              throw ('Seleção de arquivo cancelada ou falhou.');
            }
          } else {
            throw ('Arquivo não encontrado ou caminho inválido.');
          }
          // Envia o arquivo usando os bytes e o nome do arquivo
          final resultMessage =
              await chatServiceWeb.sendFile(fileBytes!, fileName);
          resultMsg = resultMessage ?? 'Erro ao processar a resposta.';
        } else {
          // Envia uma mensagem de texto
          resultMsg = await chatServiceWeb.sendMessage(content!);
        }
      } else {
        if (isAudio || isImage || isVideo) {
          // Envia o arquivo usando os bytes e o nome do arquivo
          final resultMessage =
              await chatServiceMobile.sendFileMobile(content!);
          resultMsg = await resultMessage?.stream.bytesToString() ??
              'Erro ao processar a resposta.';
        } else {
          // Envia o arquivo usando os bytes e o nome do arquivo
          final resultMessage =
              await chatServiceMobile.sendTextMessage(content!);
          resultMsg = resultMessage;
        }
      }
      // Atualiza o estado e exibe a mensagem enviada
      setState(() {
        _messages.add(Message(
          content: content,
          isAudio: isAudio,
          isImage: isImage,
          isVideo: isVideo,
          isArchiveWeb: isArquiveWeb,
          filename: fileName,
          time: DateTime.now(),
        ));
      });
    } catch (e) {
      await showCustomDialog(context, DialogType.error,
          'Não foi possível enviar a mensagem. Por favor, tente novamente mais tarde.');
    } finally {
      setState(() {
        isSendingMessage = false;
      });
    }

    // Exibe mensagem de processamento e resposta
    await Future.delayed(const Duration(milliseconds: 500), () {
      _messages.add(
        Message(
          content: 'Processando mensagem...',
          isAudio: false,
          isImage: false,
          isVideo: false,
          time: DateTime.now(),
          isSentByMe: false,
        ),
      );
      setState(() {});
    });

    await Future.delayed(const Duration(seconds: 2), () {
      _messages.add(
        Message(
          content: resultMsg,
          isAudio: false,
          isImage: false,
          isVideo: false,
          time: DateTime.now(),
          isSentByMe: false,
        ),
      );
      setState(() {});
    });

    // Exibe mensagem de processamento e resposta
    await Future.delayed(const Duration(milliseconds: 500), () {
      _messages.add(
        Message(
          content: 'Algo mais ou seria isso?',
          isAudio: false,
          isImage: false,
          isVideo: false,
          time: DateTime.now(),
          isSentByMe: false,
        ),
      );
      setState(() {});
    });
  
    // Executa scroll para a última mensagem após adicionar uma nova
    _scrollToBottom();
  }

  String getDateFromResponse(StreamedResponse resultMessage) {
    // Extrai o cabeçalho de data em formato de string
    final dateHeader = resultMessage.headers['date'];
    // Converte a string de data para DateTime, caso esteja presente
    DateTime? date;
    if (dateHeader != null) {
      date = HttpDate.parse(
          dateHeader); // Usa a classe HttpDate para parse automático
    }
    return date.toString();
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
        permiteRetornar: true,
        title: widget.userChat.username ?? "Nome do usuário",
        actions: [
          PopupMenuButton(
            icon: const Icon(Icons.more_vert),
            itemBuilder: (context) => [
              // PopupMenuItem(
              //   value: 1,
              //   child: GestureDetector(
              //     onTap: () async => await uploadFile(),
              //     child: const Row(
              //       mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //       children: [
              //         Text('Anexar arquivo'),
              //         Icon(
              //           Icons.attach_file_sharp,
              //           color: Colors.indigo,
              //         ),
              //       ],
              //     ),
              //   ),
              // ),
            ],
          ),
        ],
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: _messages.isEmpty
                    ? Image.asset(
                        'assets/images/nao-encontrado.png',
                        fit: BoxFit.contain,
                        width: 200,
                        height: 100,
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        itemCount: _messages.length,
                        itemBuilder: (context, index) {
                          final message = _messages[index];
                          Widget messageContent;
                          if (message.isAudio!) {
                            messageContent = Row(
                              children: [
                                IconButton(
                                  icon: Icon(
                                    currentlyPlayingIndex == index
                                        ? Icons.stop
                                        : Icons.play_arrow,
                                    color: Colors.indigoAccent,
                                  ),
                                  onPressed: () async =>
                                      await _playAudio(index, message.content!),
                                ),
                                Text(
                                  'Áudio: ${_formatDuration(_recordDuration)}',
                                  style: const TextStyle(color: Colors.indigo),
                                ),
                              ],
                            );
                          } else if (message.isImage!) {
                            messageContent = GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => FullScreenImage(
                                      imagePath: message.content!,
                                    ),
                                  ),
                                );
                              },
                              child: Hero(
                                tag: message.content!,
                                child: kIsWeb
                                    ? Image.network(
                                        message.content!,
                                        width: 150,
                                      )
                                    : Image.file(
                                        File(message.content!),
                                        height: 150,
                                        width: 150,
                                        fit: BoxFit.cover,
                                      ),
                              ),
                            );
                          } else if (message.isArchiveWeb!) {
                            messageContent = Center(
                              child: Column(
                                children: [
                                  const Icon(
                                    Icons.archive_sharp,
                                    size: 50,
                                  ),
                                  Text(message.filename!.toString()),
                                ],
                              ),
                            );
                          } else if (message.isVideo!) {
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
                              message.content ?? '',
                              style: const TextStyle(
                                fontSize: 16,
                                color: Colors.indigo,
                              ),
                            );
                          }

                          return Align(
                            alignment: message.isSentByMe!
                                ? Alignment.centerRight
                                : Alignment.centerLeft,
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10.0, vertical: 5.0),
                              child: IntrinsicWidth(
                                child: ConstrainedBox(
                                  constraints: const BoxConstraints(),
                                  child: Card(
                                    color: message.isSentByMe!
                                        ? Colors.blue[50]
                                        : Colors.grey[200],
                                    elevation: 2,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(15),
                                    ),
                                    child: Padding(
                                      padding: const EdgeInsets.all(10.0),
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          // Conteúdo da mensagem
                                          messageContent,
                                          const SizedBox(height: 5),
                                          Align(
                                            alignment: Alignment.bottomRight,
                                            child: Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.end,
                                              children: [
                                                Text(
                                                  _formatTime(message.time!),
                                                  style: const TextStyle(
                                                      fontSize: 12),
                                                ),
                                                const SizedBox(width: 2),
                                                Icon(
                                                  isSendingMessage
                                                      ? Icons.done
                                                      : Icons.done_all,
                                                  color: isSendingMessage
                                                      ? null
                                                      : Colors.indigoAccent,
                                                  size: 15,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
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
                      child: DefaultTextFormField(
                        hintText: 'Digite sua mensagem...',
                        controller: _messageController,
                      ),
                    ),
                  ),
                  kIsWeb
                      ? const SizedBox.shrink()
                      : GestureDetector(
                          onLongPressStart: (details) {
                            _startRecording();
                            setState(() {
                              // Inicia sem arrastar
                              isDragging = false;
                            });
                          },
                          onLongPressMoveUpdate: (details) {
                            // Verifica a posição do toque
                            RenderBox renderBox =
                                context.findRenderObject() as RenderBox;
                            Offset localPosition =
                                renderBox.globalToLocal(details.globalPosition);

                            // Verifica se o toque saiu do botão
                            if (localPosition.distance > 800) {
                              // Exemplo: se arrastado acima do botão
                              setState(() {
                                // Está arrastando
                                isDragging = true;
                                isRecording = false;
                              });
                            }
                          },
                          onLongPressUp: () {
                            if (isDragging) {
                              // Cancela a gravação se arrastado
                              _discardRecording();
                            } else {
                              // Para a gravação normalmente
                              _stopRecording();
                            }
                            setState(() {
                              // Reinicializa o estado
                              isDragging = false;
                            });
                          },
                          child: CircleAvatar(
                            radius: isRecording ? 30 : 25,
                            backgroundColor:
                                isRecording ? Colors.red : Colors.indigo,
                            child: Icon(
                              isRecording ? Icons.stop : Icons.mic,
                              color: Colors.white,
                              size: isRecording ? 35 : 20,
                            ),
                          ),
                        ),
                  kIsWeb
                      ? IconButton(
                          icon: const Icon(Icons.attach_file_sharp),
                          onPressed: () async => await _addMessage(
                            content: '',
                            isAudio: false,
                            isArquiveWeb: true,
                          ),
                        )
                      : IconButton(
                          icon: const Icon(Icons.camera_alt),
                          onPressed: _showCameraOptions,
                        ),
                  IconButton(
                    icon: const Icon(Icons.send),
                    onPressed: _sendTextMessage,
                  ),
                ],
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
      await _addMessage(
        content: pickedFile.path,
        isAudio: false,
        isImage: isImage,
        isVideo: !isImage,
        isArquiveWeb: isImage,
      );
      setState(() {});
    }
  }

  Future<void> _sendTextMessage() async {
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      _messageController.clear();
      await _addMessage(content: messageText, isAudio: false);
    }
  }

  void _discardRecording() {
    _stopRecording(sendRecord: false);
    if (_audioPath != null) {
      File(_audioPath!).delete();
    }
  }

  String _formatTime(DateTime datetime) {
    return '${datetime.hour.toString().padLeft(2, '0')}:${datetime.minute.toString().padLeft(2, '0')}';
  }

  Future<void> uploadFile() async {
    // Seleciona o arquivo com o FilePicker
    FilePickerResult? result = await FilePicker.platform.pickFiles();

    if (result != null && result.files.isNotEmpty) {
      // Obtém os bytes do arquivo selecionado para uso na web
      Uint8List? fileBytes = result.files.single.bytes;
      String fileName = result.files.single.name;

      if (fileBytes != null) {
        // Envia o arquivo usando os bytes e o nome do arquivo
        final resultMessage =
            await chatServiceWeb.sendFile(fileBytes, fileName);

        if (resultMessage != null) {
          // Processa a resposta conforme necessário
          // Exemplo: await _processResponse(resultMessage);
        }
      }
    }
  }

  Future<String?> sendMessageWeb(Message? message) async {
    if (kIsWeb) {
      if (message != null &&
          (message.isAudio! || message.isImage! || message.isVideo!)) {
        Uint8List? fileBytes;
        String fileName;

        if (message.content != null) {
          // Para web e mobile, obtemos o arquivo pelo `FilePicker`
          FilePickerResult? result = await FilePicker.platform.pickFiles();

          setState(() {});
          if (result != null && result.files.isNotEmpty) {
            fileBytes = result.files.single.bytes;
            fileName = result.files.single.name;
          } else {
            throw ('Seleção de arquivo cancelada ou falhou.');
          }
        } else {
          throw ('Arquivo não encontrado ou caminho inválido.');
        }

        // Envia o arquivo usando os bytes e o nome do arquivo
        final resultMessage =
            await chatServiceWeb.sendFile(fileBytes!, fileName);
        return resultMessage ?? 'Erro ao processar a resposta.';
      }
    }
    return null;
  }
}
