class Message {

  String author;
  String message;
  DateTime timestamp;

  Message({
    required this.author,
    required this.message,
    required this.timestamp,
  });

  Map<String, dynamic> toJson() => {
        'author': author,
        'message': message,
        'timestamp': timestamp,
      };

  bool isMe(nickname) => author == nickname;
}
