import 'package:flutter/material.dart';
import 'package:flutter_chat_app/src/auth/providers/auth_provider.dart';
import 'package:flutter_chat_app/src/pages/start_page.dart';
import 'package:flutter_chat_app/src/pages/user_home_page.dart';
import 'package:provider/provider.dart';

class AuthOrHomePage extends StatelessWidget {
  const AuthOrHomePage({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProv>(context);
    return Scaffold(
      body: FutureBuilder(
        future: auth.tryAutoLogin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          } 
          else if (snapshot.error != null) {
            return const Center(
              child: Text('Ocorreu um erro.'),
            );
          }
           else {
            return auth.isAuth ? const UserHomePage() : const StartPage();
          }
        },
      ),
    );
  }
}