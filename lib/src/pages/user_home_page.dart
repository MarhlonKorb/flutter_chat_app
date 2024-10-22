import 'package:flutter/material.dart';
import 'package:flutter_chat_app/src/auth/providers/auth_provider.dart';
import 'package:flutter_chat_app/src/login/utils/app_routes.dart';
import 'package:flutter_chat_app/src/pages/chat_page.dart';
import 'package:flutter_chat_app/src/widgets/custom_dialog.dart';
import 'package:flutter_chat_app/src/widgets/default_app_bar.dart';
import 'package:provider/provider.dart';

class UserHomePage extends StatelessWidget {
  const UserHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    /// GlobalKey para acessar o estado do Scaffold
    final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

    return Scaffold(
      key: scaffoldKey,
      appBar: DefaultAppBar(
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () {
            // Usa a chave para abrir o Drawer
            scaffoldKey.currentState?.openDrawer();
          },
        ),
        centerTitle: true,
        title: 'Bem vindo!',
        permiteRetornar: false,
        actions: [
          IconButton(
            onPressed: () async {
              await callLogoutUsuario(context);
            },
            icon: const Icon(Icons.exit_to_app),
          )
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            DrawerHeader(
              decoration: const BoxDecoration(
                color: Colors.black87,
              ),
              child: Container(
                alignment: Alignment.bottomLeft,
                child: const Text(
                  'Menu',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                  ),
                ),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.chat),
              title: const Text('Chats'),
              onTap: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const ChatPage(),
                  ),
                );
              },
            ),
            ListTile(
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              onTap: () async {
                // Fecha o drawer
                Navigator.of(context).pop();
                await callLogoutUsuario(context);
              },
            ),
          ],
        ),
      ),
      body: const Text('Chats'),
    );
  }

  Future<void> callLogoutUsuario(BuildContext context) async {
    final authProvider = Provider.of<AuthProv>(listen: false, context);
    final confirmou = await showConfirmDialog(context, 'Deseja sair do app?');
    if (confirmou) {
      // Faz o logout do usuário
      authProvider.logout();
      // Redireciona para a tela de login e remove todas as rotas anteriores
      await Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.authOrHome,
        (Route<dynamic> route) => false,
      );
    }
  }
}
