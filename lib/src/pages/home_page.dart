import 'package:flutter/material.dart';
import 'package:flutter_chat_app/src/auth/providers/auth_provider.dart';
import 'package:flutter_chat_app/src/chat/domain/models/user_chat.dart';
import 'package:flutter_chat_app/src/login/utils/app_routes.dart';
import 'package:flutter_chat_app/src/pages/chat_page.dart';
import 'package:flutter_chat_app/src/widgets/custom_dialog.dart';
import 'package:flutter_chat_app/src/widgets/default_app_bar.dart';
import 'package:provider/provider.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    /// GlobalKey para acessar o estado do Scaffold
    final scaffoldKey = GlobalKey<ScaffoldState>();
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
        title: 'Conversas',
        permiteRetornar: false,
      ),
      drawer: Drawer(
        width: 230,
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  const DrawerHeader(
                    decoration: BoxDecoration(
                      color: Colors.indigo,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CircleAvatar(
                          radius: 40,
                          backgroundImage:
                              AssetImage('assets/images/homem.png'),
                        ),
                        SizedBox(height: 10),
                        Text(
                          'Anderson',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ListTile(
                    leading: const Icon(Icons.chat),
                    title: const Text('Chats'),
                    onTap: () async => Navigator.of(context).pop(context),
                  ),
                  ListTile(
                    leading: const Icon(Icons.settings_suggest),
                    title: const Text('Configurações'),
                    onTap: () async => Navigator.of(context).pop(context),
                  ),
                ],
              ),
            ),
            ListTile(
              iconColor: Colors.red,
              leading: const Icon(Icons.exit_to_app),
              title: const Text('Logout'),
              onTap: () async {
                Navigator.of(context).pop();
                await callLogoutUsuario(context);
              },
            ),
            const Padding(
              padding: EdgeInsets.all(8.0),
              child: Text(
                'All rights reserved © 2024 MK Desenv.',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ),
          ],
        ),
      ),
      body: ListView.builder(
        itemCount: 12,
        itemBuilder: (_, index) {
          return GestureDetector(
            onTap: () async => await Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatPage(
                  userChat: UserChat(id: index, username: 'Julio'),
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 5,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(
                            Icons.chat,
                            color: Colors.indigo,
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Chat ${index + 1}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.indigo[800],
                            ),
                          ),
                        ],
                      ),
                      Text(
                        'Este é o preview da conversa número ${index + 1}.',
                        style: TextStyle(
                          color: Colors.indigo[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
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
