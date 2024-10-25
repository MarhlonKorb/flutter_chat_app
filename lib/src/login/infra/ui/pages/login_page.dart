import 'package:flutter/material.dart';
import 'package:flutter_chat_app/src/auth/exceptions/auth_exception.dart';
import 'package:flutter_chat_app/src/auth/providers/auth_provider.dart';
import 'package:flutter_chat_app/src/login/utils/app_routes.dart';
import 'package:flutter_chat_app/src/login/utils/validadores.dart';
import 'package:flutter_chat_app/src/widgets/custom_dialog.dart';
import 'package:flutter_chat_app/src/widgets/default_elevated_button.dart';
import 'package:flutter_chat_app/src/widgets/default_text_form_field.dart';
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

  /// Define o ícone inicial
  IconData _passwordIcon = Icons.lock_open;

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
      duration: const Duration(milliseconds: 300),
    );
    _opacityAnimation = Tween(begin: 0.0, end: 1.0).animate(
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

    // Adiciona o listener para atualizar o ícone quando o texto muda
    _emailController.addListener(_updateEmail);
    // Adiciona o listener para atualizar o ícone quando o texto muda
    _passwordController.addListener(_updatePassword);
  }

  // Método que seta o estado ao escutar alterações do controller de email
  void _updateEmail() {
    setState(() {});
  }

  // Método que atualiza o ícone conforme o texto da senha
  void _updatePassword() {
    setState(() {
      _passwordIcon = _passwordController.text.isEmpty
          ? Icons.lock_open
          : Icons.lock_outline;
    });
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

  bool _isLogin() => _authMode == AuthMode.login;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/chat-1.gif',
                fit: BoxFit.contain,
              ),
              const Text(
                'BEM VINDO AO SEU APP DE CONVERSAS!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.deepPurple,
                  letterSpacing: 1,
                  wordSpacing: 2,
                  shadows: [
                    Shadow(
                      blurRadius: 2.0,
                      color: Colors.pinkAccent,
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(
                height: 20,
              ),
              DefaultTextFormField(
                icon: Icons.email_outlined,
                iconColor: !Validadores.email(_emailController.text)
                    ? Colors.redAccent
                    : null,
                controller: _emailController,
                labelText: 'Email',
                keyboardType: TextInputType.emailAddress,
                validator: (value) {
                  if (!Validadores.email(value)) {
                    return 'Por favor, insira um email válido';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 20),
              DefaultTextFormField(
                icon: _passwordIcon,
                iconColor:
                    _passwordController.text.isEmpty ? Colors.redAccent : null,
                keyboardType: TextInputType.visiblePassword,
                obscureText: true,
                controller: _passwordController,
                labelText: 'Senha',
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Por favor, insira a senha';
                  }
                  return null;
                },
              ),
              _isLogin() ? const SizedBox.shrink() : const SizedBox(height: 20),
              AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                curve: Curves.linear,
                constraints: BoxConstraints(
                  minHeight: _isLogin() ? 0 : 60,
                  maxHeight: _isLogin() ? 0 : 120,
                ),
                child: FadeTransition(
                  opacity: _opacityAnimation!,
                  child: SlideTransition(
                    position: _slideAnimation!,
                    child: DefaultTextFormField(
                      icon: Icons.done_all_rounded,
                      keyboardType: TextInputType.visiblePassword,
                      iconColor:
                          _passwordController.text.isEmpty ? Colors.red : null,
                      obscureText: true,
                      labelText: 'Confirmar senha',
                      validator: (value) {
                        if (_authMode == AuthMode.signup) {
                          if (value == null || value.isEmpty) {
                            return 'Por favor, insira a senha';
                          }
                          if (value != _passwordController.text) {
                            return 'Senhas informadas não conferem';
                          }
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
              const SizedBox(height: 20),
              const LineWithText(text: 'OU'),
              const SizedBox(height: 20),
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
        await auth.login(
            email: _emailController.text, password: _passwordController.text);
        await Navigator.of(context).pushNamed(AppRoutes.userHomePage);
      } else {
        await auth.signUp(
            email: _emailController.text, password: _passwordController.text);
        await Navigator.of(context).pushNamed(AppRoutes.userHomePage);
      }
    } on AuthException catch (e) {
      await showCustomDialog(context, DialogType.error, e.toString());
    }
  }
}
