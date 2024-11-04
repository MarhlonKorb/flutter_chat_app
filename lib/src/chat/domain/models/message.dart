import 'dart:io';

class Message {
  final String? content;
  final String? filename;
  final File? file;
  final bool? isAudio;
  final bool? isImage;
  final bool? isVideo;
  final bool? isArchiveWeb;
  final bool? isSentByMe;
  final DateTime? time;
  final bool? isSending;
  Message({
    this.content,
    this.file,
    this.isAudio = false,
    this.isImage = false,
    this.isVideo = false,
    this.isArchiveWeb = false,
    this.isSentByMe = true,
    this.time,
    this.isSending = false,
    this.filename, 
  });

  Map<String, String> toJson() {
    return {
      'arquivo': content!,
    };
  }

}
