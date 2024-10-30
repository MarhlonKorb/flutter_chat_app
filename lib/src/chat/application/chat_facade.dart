
abstract class ChatFacade {

  Future<void> sendFile(String filePath);
  Future<void> sendMessage(String message);
}