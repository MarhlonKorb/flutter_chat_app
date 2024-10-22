import 'package:flutter/material.dart';
import 'package:flutter_chat_app/src/login/infra/ui/pages/login_page.dart';
import 'package:flutter_chat_app/src/widgets/default_app_bar.dart';

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: DefaultAppBar(
        title: 'App chat',
        
      ),
      body: LoginPage(),
    );
  }
}
