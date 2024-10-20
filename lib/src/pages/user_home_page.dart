import 'package:flutter/material.dart';
import 'package:flutter_chat_app/src/auth/providers/auth_provider.dart';
import 'package:flutter_chat_app/src/login/utils/app_routes.dart';
import 'package:flutter_chat_app/src/widgets/custom_dialog.dart';
import 'package:flutter_chat_app/src/widgets/default_app_bar.dart';
import 'package:provider/provider.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProv>(listen: false, context);
    return DefaultAppBar(
      leading: IconButton(onPressed: () {}, icon: const Icon(Icons.menu)),
      centerTitle: true,
      title: 'Bem vindo!',
      permiteRetornar: false,
      actions: [
        IconButton(
            onPressed: () async {
              showConfirmDialog(context, 'Deseja sair do app?');
              // Faz o logout do usuário
              authProvider.logout();
              // Redireciona para a tela de login
              await Navigator.of(context).pushNamed(AppRoutes.authOrHome);
            },
            icon: const Icon(Icons.exit_to_app))
      ],
    );
  }
}
