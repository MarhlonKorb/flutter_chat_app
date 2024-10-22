class User {
  final String? token;
  final String? email;
  final String? userId;

  User({
    this.token,
    this.email,
    this.userId,
  });

  /// Método para criar uma instância de User a partir de um Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      token: map['token'] as String?,
      email: map['email'] as String?,
      userId: map['userId'] as String?,
    );
  }

  /// Método para converter uma instância de User em um Map
  Map<String, dynamic> toMap() {
    return {
      'token': token,
      'email': email,
      'userId': userId,
    };
  }
}
