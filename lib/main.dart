import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/src/auth/providers/auth_provider.dart';
import 'package:flutter_chat_app/src/login/utils/app_routes.dart';
import 'package:flutter_chat_app/src/pages/auth_or_home_page.dart';
import 'package:flutter_chat_app/src/pages/start_page.dart';
import 'package:flutter_chat_app/src/pages/user_home_page.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");

  await Firebase.initializeApp(
      options: FirebaseOptions(
    apiKey: dotenv.get('apiKey'),
    appId: '356304904601',
    messagingSenderId: '356304904601',
    projectId: 'flutter-chat-app-9558b',
  )); // Inicializa o Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProv()),
      ],
      child: MaterialApp(
        title: 'App chat',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
          useMaterial3: true,
        ),
        routes: {
          AppRoutes.authOrHome: (_) => const AuthOrHomePage(),
          AppRoutes.startPage: (_) => const StartPage(),
          AppRoutes.userHomePage: (_) => const UserHomePage(),
        },
      ),
    );
  }
}
