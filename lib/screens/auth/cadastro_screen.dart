import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/validators.dart';
import '../../routes/app_routes.dart';
import '../../widgets/campo_texto.dart';
import '../../widgets/campo_email.dart';
import '../../widgets/campo_senha.dart';

class CadastroScreen extends StatefulWidget {
  final String tipo;
  const CadastroScreen({super.key, this.tipo = 'empresa'});

  @override
  State<CadastroScreen> createState() => _CadastroScreenState();
}

class _CadastroScreenState extends State<CadastroScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _confirmaCtrl = TextEditingController();

  bool _carregando = false;
  bool _carregandoGoogle = false; // 👈 ADICIONADO
  String? _erro;
  bool _aceitouTermos = false;

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _senhaCtrl.dispose();
    _confirmaCtrl.dispose();
    super.dispose();
  }

  // ============================================================
  // ABRIR URL EXTERNA
  // ============================================================
  Future<void> _abrirUrl(String url) async {
    final uri = Uri.parse(url);
    try {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o link.')),
      );
    }
  }

  // ============================================================
  // CRIAR CONTA COM EMAIL/SENHA
  // ============================================================
  Future<void> _criar() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_aceitouTermos) {
      setState(() => _erro =
          'Você precisa aceitar os Termos de Uso e a Política de Privacidade.');
      return;
    }
    if (_senhaCtrl.text != _confirmaCtrl.text) {
      setState(() => _erro = 'As senhas não coincidem.');
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await AuthService.criarConta(
        email: _emailCtrl.text,
        senha: _senhaCtrl.text,
        nome: _nomeCtrl.text.trim(),
        tipo: widget.tipo,
      );
      if (!mounted) return;

      Navigator.pushReplacementNamed(
        context,
        AppRoutes.verificarEmail,
        arguments: _emailCtrl.text.trim(),
      );
    } catch (e) {
      setState(() => _erro = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  // ============================================================
  // CADASTRAR COM GOOGLE 👈 ADICIONADO
  // ============================================================
  Future<void> _cadastrarComGoogle() async {
    if (!_aceitouTermos) {
      setState(() => _erro =
          'Você precisa aceitar os Termos de Uso e a Política de Privacidade.');
      return;
    }

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Criar conta')),
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
                  'Crie sua conta Kodaff',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Leva menos de 1 minuto. Usamos padrão bancário de segurança.',
                  style: TextStyle(color: AppColors.textGray, height: 1.45),
                ),
                const SizedBox(height: 32),
                CampoTexto(
                  label: 'Nome completo',
                  controller: _nomeCtrl,
                  validator: (v) => Validators.nome(v),
                ),
                const SizedBox(height: 16),
                CampoEmail(controller: _emailCtrl),
                const SizedBox(height: 16),
                CampoSenha(
                  label: 'Senha',
                  controller: _senhaCtrl,
                  mostrarForca: true,
                  validator: (v) => Validators.senha(v),
                ),
                const SizedBox(height: 16),
                CampoSenha(
                  label: 'Confirmar senha',
                  controller: _confirmaCtrl,
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Campo obrigatório';
                    if (v != _senhaCtrl.text) return 'Senhas não coincidem';
                    return null;
                  },
                ),
                const SizedBox(height: 20),

                // ============================================================
                // CHECKBOX DOS TERMOS COM LINKS CLICÁVEIS
                // ============================================================
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 24,
                      height: 24,
                      child: Checkbox(
                        value: _aceitouTermos,
                        onChanged: (v) =>
                            setState(() => _aceitouTermos = v ?? false),
                        activeColor: AppColors.electricBlue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: RichText(
                          text: TextSpan(
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textGray,
                              height: 1.4,
                            ),
                            children: [
                              const TextSpan(text: 'Concordo com os '),
                              TextSpan(
                                text: 'Termos de Uso',
                                style: const TextStyle(
                                  color: AppColors.electricBlue,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => _abrirUrl(
                                        'https://www.kodaff.com/termos',
                                      ),
                              ),
                              const TextSpan(text: ' e a '),
                              TextSpan(
                                text: 'Política de Privacidade',
                                style: const TextStyle(
                                  color: AppColors.electricBlue,
                                  fontWeight: FontWeight.w700,
                                  decoration: TextDecoration.underline,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () => _abrirUrl(
                                        'https://www.kodaff.com/privacidade',
                                      ),
                              ),
                              const TextSpan(text: ' da Kodaff.'),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),

                if (_erro != null) ...[
                  const SizedBox(height: 16),
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
                const SizedBox(height: 28),
                ElevatedButton(
                  onPressed: _carregando ? null : _criar,
                  child: _carregando
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                              color: Colors.white, strokeWidth: 2),
                        )
                      : const Text('Criar minha conta'),
                ),
                const SizedBox(height: 20),

                // ============================================================
                // DIVISOR "OU" 👈 ADICIONADO
                // ============================================================
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

                // ============================================================
                // BOTÃO CADASTRAR COM GOOGLE 👈 ADICIONADO
                // ============================================================
                SizedBox(
                  height: 56,
                  child: OutlinedButton(
                    onPressed: _carregandoGoogle ? null : _cadastrarComGoogle,
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
                                'Cadastrar com Google',
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

                const SizedBox(height: 12),
                TextButton(
                  onPressed: () {
                    Navigator.pushReplacementNamed(
                      context,
                      AppRoutes.login,
                    );
                  },
                  child: const Text('Já tenho conta? Entrar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
