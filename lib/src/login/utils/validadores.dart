class Validadores {
  // Validação de email usando RegEx
  static const String _pattern =
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$';

  static bool email(String? email) {
    if (email == null || email.isEmpty) {
      return false;
    }
    RegExp regExp = RegExp(_pattern);
    if (!regExp.hasMatch(email)) {
      return false;
    }
    return true;
  }
}
