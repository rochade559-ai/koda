import 'package:flutter/material.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart'; // 👈 IMPORT OBRIGATÓRIO
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/campo_email.dart';
import '../../widgets/campo_senha.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();

  bool _carregando = false;
  bool _carregandoGoogle = false;
  bool _carregandoApple = false; // 👈 VARIÁVEL ADICIONADA
  String? _erro;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _entrar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await AuthService.login(
        email: _emailCtrl.text,
        senha: _senhaCtrl.text,
      );
      if (!mounted) return;
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } catch (e) {
      setState(() => _erro = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  Future<void> _entrarComGoogle() async {
    setState(() {
      _carregandoGoogle = true;
      _erro = null;
    });

    try {
      final user = await AuthService.loginComGoogle();
      if (!mounted) return;

      if (user != null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      } else {
        setState(() => _carregandoGoogle = false);
      }
    } catch (e) {
      setState(() => _erro = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _carregandoGoogle = false);
    }
  }

  // 👇 FUNÇÃO DO APPLE ADICIONADA 👇
  Future<void> _entrarComApple() async {
    setState(() {
      _carregandoApple = true;
      _erro = null;
    });

    try {
      final user = await AuthService.loginComApple();
      if (!mounted) return;

      if (user != null) {
        Navigator.pushNamedAndRemoveUntil(
          context,
          AppRoutes.home,
          (route) => false,
        );
      } else {
        setState(() => _carregandoApple = false);
      }
    } catch (e) {
      setState(() => _erro = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _carregandoApple = false);
    }
  }

  void _esqueci() {
    Navigator.pushNamed(context, AppRoutes.recuperarSenha);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Entrar')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                const Text(
                  'Bem-vindo de volta',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Acesse sua conta Kodaff.',
                  style: TextStyle(color: AppColors.textGray),
                ),
                const SizedBox(height: 32),

                // ============ E-MAIL E SENHA ============
                CampoEmail(controller: _emailCtrl),
                const SizedBox(height: 16),
                CampoSenha(
                  label: 'Senha',
                  controller: _senhaCtrl,
                  validator: (v) =>
                      (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
                ),

                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _esqueci,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: const Text(
                      'Esqueci minha senha',
                      style: TextStyle(
                        color: AppColors.electricBlue,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),

                // ============ ERRO ============
                if (_erro != null) ...[
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.error.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: AppColors.error.withOpacity(0.3),
                      ),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.error_outline,
                            color: AppColors.error, size: 20),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _erro!,
                            style: const TextStyle(
                                color: AppColors.error, fontSize: 13),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // ============ BOTÃO ENTRAR ============
                ElevatedButton(
                  onPressed: _carregando ? null : _entrar,
                  child: _carregando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Entrar'),
                ),

                const SizedBox(height: 20),

                // ============ DIVISOR "OU" ============
                Row(
                  children: [
                    const Expanded(
                      child: Divider(color: AppColors.borderLight),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'ou',
                        style: TextStyle(
                          color: AppColors.textGray,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const Expanded(
                      child: Divider(color: AppColors.borderLight),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ============ BOTÃO GOOGLE ============
                SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _carregandoGoogle ? null : _entrarComGoogle,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(
                          color: AppColors.borderLight, width: 1.5),
                      backgroundColor: Colors.white,
                      foregroundColor: AppColors.textDark,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _carregandoGoogle
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                                color: AppColors.electricBlue, strokeWidth: 2),
                          )
                        : Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                width: 24,
                                height: 24,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Color(0xFF4285F4),
                                ),
                                alignment: Alignment.center,
                                child: const Text(
                                  'G',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                    height: 1.1,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Text(
                                'Entrar com Google',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                // 👇 BOTÃO DA APPLE ADICIONADO AQUI 👇
                if (Theme.of(context).platform == TargetPlatform.iOS) ...[
                  const SizedBox(height: 12),
                  SizedBox(
                    height: 56,
                    child: _carregandoApple
                        ? const Center(child: CircularProgressIndicator())
                        : SignInWithAppleButton(
                            onPressed: _entrarComApple,
                            style: SignInWithAppleButtonStyle.black,
                            borderRadius: BorderRadius.circular(14),
                          ),
                  ),
                ],

                const SizedBox(height: 20),

                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.cadastroConta,
                    );
                  },
                  child: const Text('Não tem conta? Cadastre-se'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
