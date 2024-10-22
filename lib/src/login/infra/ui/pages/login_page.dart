import 'package:flutter/material.dart';
import 'package:flutter_chat_app/src/auth/exceptions/auth_exception.dart';
import 'package:flutter_chat_app/src/auth/providers/auth_provider.dart';
import 'package:flutter_chat_app/src/login/utils/app_routes.dart';
import 'package:flutter_chat_app/src/login/utils/validadores.dart';
import 'package:flutter_chat_app/src/widgets/custom_dialog.dart';
import 'package:flutter_chat_app/src/widgets/default_elevated_button.dart';
import 'package:flutter_chat_app/src/widgets/line_with_text.dart';
import 'package:provider/provider.dart';

enum AuthMode { signup, login }

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage>
    with SingleTickerProviderStateMixin {
  /// Globalkey do formulário
  final _formKey = GlobalKey<FormState>();

  /// Controller do email
  final TextEditingController _emailController = TextEditingController();

  /// Controller do password
  final TextEditingController _passwordController = TextEditingController();

  /// Modo de acesso do formulário
  AuthMode _authMode = AuthMode.login;

  /// Valida se o usuário está em modo de login
  bool _isLogin() => _authMode == AuthMode.login;

  /// Controller do animador do campo de password
  AnimationController? _animacaoPasswordController;
  // Instância do objeto a ser animado
  Animation<double>? _opacityAnimation;
  Animation<Offset>? _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animacaoPasswordController = AnimationController(
      vsync: this,
      duration: const Duration(
        milliseconds: 300,
      ),
    );
    // Classe que recebe as configurações de animação
    _opacityAnimation = Tween(
      begin: 0.0,
      end: 1.0,
    ).animate(
      CurvedAnimation(
        parent: _animacaoPasswordController!,
        curve: Curves.linear,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1.5),
      end: const Offset(0, 0),
    ).animate(
      CurvedAnimation(
        parent: _animacaoPasswordController!,
        curve: Curves.linear,
      ),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  /// Método que altera a acessibilidade aos inputs de senha do usuário
  void _switchAuthMode() {
    setState(() {
      // Reseta os campos do formulário
      _formKey.currentState?.reset();
      if (_isLogin()) {
        _authMode = AuthMode.signup;
        // Aqui é feita a alternância da animação de acordo com a escolha do usuário
        _animacaoPasswordController?.forward();
      } else {
        _authMode = AuthMode.login;
        // Aqui é feita a alternância da animação de acordo com a escolha do usuário
        _animacaoPasswordController?.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: <Widget>[
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: 'Email'),
                validator: (value) {
                  if (!Validadores.email(value)) {
                    return 'Por favor, insira um email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a senha';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.linear,
                constraints: BoxConstraints(
                    minHeight: _isLogin() ? 0 : 60,
                    maxHeight: _isLogin() ? 0 : 120),
                child: FadeTransition(
                  opacity: _opacityAnimation!,
                  child: SlideTransition(
                    position: _slideAnimation!,
                    child: TextFormField(
                      decoration:
                          const InputDecoration(labelText: 'Confirmar senha'),
                      keyboardType: TextInputType.emailAddress,
                      obscureText: true,
                      validator: _isLogin()
                          ? null
                          : (_password) {
                              final password = _password ?? '';
                              if (password.isEmpty) {
                                return 'Por favor, insira a senha';
                              }
                              if (password != _passwordController.text) {
                                return 'Senhas informadas não conferem';
                              }
                              return null;
                            },
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              DefaultElevatedButton(
                icon: _isLogin() ? Icons.login : Icons.done,
                iconBefore: false,
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    await _executaCadastroOuLogin();
                  }
                },
                child: Text(_isLogin() ? 'ACESSAR' : 'CADASTRAR'),
              ),
              const SizedBox(height: 40),
              const LineWithText(text: 'OU'),
              const SizedBox(height: 40),
              DefaultElevatedButton(
                icon: _isLogin() ? null : Icons.login,
                isWhiteStyle: true,
                onPressed: () => _switchAuthMode(),
                child: Text(_isLogin()
                    ? 'Ainda não se cadastrou? Cadastre-se.'
                    : 'Já possui uma conta? Acesse!'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _executaCadastroOuLogin() async {
    try {
      final auth = Provider.of<AuthProv>(context, listen: false);
      if (_isLogin()) {
        // Chama o método de login
        await auth.login(
            email: _emailController.text, password: _passwordController.text);
        // Redireciona para a home do usuário
        await Navigator.of(context).pushNamed(AppRoutes.userHomePage);
      } else {
        await auth.signUp(
            email: _emailController.text, password: _passwordController.text);
        // Redireciona para a home do usuário
        await Navigator.of(context).pushNamed(AppRoutes.userHomePage);
      }
    } on AuthException catch (e) {
      await showCustomDialog(context, DialogType.error, e.toString());
    }
  }
}
