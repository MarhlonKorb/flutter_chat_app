import 'dart:io';

class Message {
  final String? content;
  final File? file;
  final bool? isAudio;
  final bool? isImage;
  final bool? isVideo;
  final bool? isSentByMe;
  final DateTime? time;

  Message({
    this.content,
    this.file,
    this.isAudio = false,
    this.isImage = false,
    this.isVideo = false,
    this.isSentByMe = false,
    this.time,
  });

  Map<String, String> toJson() {
    return {
      'arquivo': content!,
    };
  }
}
