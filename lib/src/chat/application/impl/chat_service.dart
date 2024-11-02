import 'dart:io';
import 'package:flutter_chat_app/src/chat/domain/models/message.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_chat_app/src/chat/application/chat_facade.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart';

class ChatService implements ChatFacade {
  final String apiUrl = '${dotenv.get('apiBaseUrl')}/operacao/processar/midia';

  @override
  Future<StreamedResponse?> sendFile(String filePath) async {
    final file = File(filePath);
    if (!await _fileExists(file)) {
      throw ('Arquivo não encontrado: $filePath');
    }
    final mediaType = _getMediaType(file);
    if (mediaType == null) {
      throw ('Tipo de arquivo não suportado: ${extension(file.path)}');
    }
    final request = await _buildMultipartRequest(apiUrl, file, mediaType);
   return await _sendMultipartRequest(request);
  }

  // Verifica se o arquivo existe
  Future<bool> _fileExists(File file) async {
    return await file.exists();
  }

  // Retorna o tipo de mídia baseado na extensão do arquivo
  MediaType? _getMediaType(File file) {
    final fileExtension = extension(file.path).toLowerCase();

    switch (fileExtension) {
      case '.jpg':
      case '.jpeg':
        return MediaType('image', 'jpeg');
      case '.png':
        return MediaType('image', 'png');
      case '.gif':
        return MediaType('image', 'gif');
      case '.mp4':
        return MediaType('video', 'mp4');
      case '.mp3':
        return MediaType('audio', 'mpeg');
      case '.wav':
        return MediaType('audio', 'wav');
      case '.aac':
        return MediaType('audio', 'aac');
      default:
        return null;
    }
  }

  // Constrói a requisição multipart
  Future<http.MultipartRequest> _buildMultipartRequest(
    String apiUrl,
    File file,
    MediaType mediaType,
  ) async {
    final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    // Adiciona cabeçalhos
    request.headers['accept'] = 'application/json';
    request.headers['Content-Type'] = 'multipart/form-data';
    // Adiciona o arquivo ao corpo da requisição
    request.files.add(await http.MultipartFile.fromPath(
      'arquivo',
      file.path,
      contentType: mediaType,
    ));
    return request;
  }

Future<http.StreamedResponse?> _sendMultipartRequest(MultipartRequest request) async {
  try {
    // Envia a requisição
    final StreamedResponse response = await request.send();
    // Verifica o código de status e processa o conteúdo
    if (response.statusCode == 200) {
      // Exemplo: decodifica a resposta JSON
      return response;
    } 
    return null;
  } catch (e) {
    throw ('Erro ao enviar o arquivo: $e');
  }
}


  @override
  Future<void> sendMessage(String message) async {
    final headers = {
      'accept': 'application/json',
    };
    try {
      await http.post(Uri.parse(apiUrl),
          body: Message(content: message).toJson(), headers: headers);
    } catch (e) {
      throw ('Erro ao enviar a mensagem: $e');
    }
  }
}
