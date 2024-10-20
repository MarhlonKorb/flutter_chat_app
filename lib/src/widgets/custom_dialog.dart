import 'package:flutter/material.dart';

// Enum para definir os tipos de diálogos
enum DialogType { success, alert, error }

// Classe para o CustomDialog
class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final DialogType type;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    Color dialogColor;
    Icon dialogIcon;

    // Defina a cor e o ícone com base no tipo
    switch (type) {
      case DialogType.success:
        dialogColor = Colors.green;
        dialogIcon = const Icon(Icons.check_circle, color: Colors.white);
        break;
      case DialogType.alert:
        dialogColor = Colors.amber;
        dialogIcon = const Icon(Icons.warning, color: Colors.black);
        break;
      case DialogType.error:
        dialogColor = Colors.red;
        dialogIcon = const Icon(Icons.error, color: Colors.white);
        break;
    }

    return AlertDialog(
      backgroundColor: dialogColor,
      title: Row(
        children: [
          dialogIcon,
          const SizedBox(width: 10),
          Text(title, style: const TextStyle(color: Colors.white)),
        ],
      ),
      content: Text(message, style: const TextStyle(color: Colors.white)),
      actions: [
        TextButton(
          onPressed: () {
            Navigator.of(context).pop(); // Fecha o diálogo
          },
          child: const Text('Fechar', style: TextStyle(color: Colors.white)),
        ),
      ],
    );
  }
}

// Função para mostrar o CustomDialog
Future<void> showCustomDialog(BuildContext context, DialogType type, String message) async {
  String title;

  // Defina o título com base no tipo do diálogo
  switch (type) {
    case DialogType.success:
      title = "Sucesso!";
      break;
    case DialogType.alert:
      title = "Atenção!";
      break;
    case DialogType.error:
      title = "Erro!";
      break;
  }

  // Use showDialog para mostrar o CustomDialog
  await showDialog(
    context: context,
    builder: (context) {
      return CustomDialog(
        title: title,
        message: message,
        type: type,
      );
    },
  );
}


// Diálogo de confirmação que retorna um valor bool
Future<bool> showConfirmDialog(BuildContext context, String message) async {
  return await showDialog(
    context: context,
    barrierDismissible: false, // Usuário precisa escolher uma opção
    builder: (context) {
      return AlertDialog(
        title: const Text('Confirmação'),
        content: Text(message),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(false); // Retorna false para "Não"
            },
            child: const Text('Não'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop(true); // Retorna true para "Sim"
            },
            child: const Text('Sim'),
          ),
        ],
      );
    },
  ) ?? false; // Retorna false se o diálogo for fechado de outra forma
}
