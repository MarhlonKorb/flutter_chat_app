import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http_parser/http_parser.dart';
import 'package:mime/mime.dart';
import 'package:path/path.dart';

class ChatServiceWeb {
  final String apiUrl = '${dotenv.get('apiBaseUrl')}/operacao/processar/midia';

  // Novo método para enviar arquivo usando Uint8List e nome
  Future<String?> sendFile(Uint8List fileBytes, String fileName) async {
    // Obtém o tipo de mídia usando a extensão do nome do arquivo
    final mediaType = lookupMimeType(fileName);
    if (mediaType == null) {
      throw ('Tipo de arquivo não suportado: ${extension(fileName)}');
    }

    // Constrói a requisição Multipart usando os bytes do arquivo
    final request = http.MultipartRequest('POST', Uri.parse(apiUrl));
    request.headers['accept'] = 'application/json';
    
    request.files.add(http.MultipartFile.fromBytes(
      'file', // Nome do campo esperado pelo backend
      fileBytes,
      filename: fileName,
      contentType: MediaType.parse(mediaType),
    ));

    try {
      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        return responseBody.body;
      } else {
        throw ('Erro ao enviar o arquivo: ${response.statusCode}');
      }
    } catch (e) {
      throw ('Erro ao enviar o arquivo: $e');
    }
  }

  // Método para enviar uma mensagem de texto ao servidor
  Future<String> sendMessage(String message) async {
    final headers = {'accept': 'application/json'};
    final uri = Uri.parse(apiUrl);

    try {
      final request = http.MultipartRequest('POST', uri);
      request.headers.addAll(headers);

      // Adiciona a mensagem como campo de texto
      request.fields['content'] = message;

      final response = await request.send();
      final responseBody = await http.Response.fromStream(response);

      if (response.statusCode == 200) {
        return responseBody.body;
      } else {
        throw ('Erro ao enviar a mensagem: ${response.statusCode}');
      }
    } catch (e) {
      throw ('Erro ao enviar a mensagem: $e');
    }
  }
}
