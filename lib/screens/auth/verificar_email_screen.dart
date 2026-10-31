import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../routes/app_routes.dart';

class VerificarEmailScreen extends StatefulWidget {
  final String email;
  const VerificarEmailScreen({super.key, required this.email});

  @override
  State<VerificarEmailScreen> createState() => _VerificarEmailScreenState();
}

class _VerificarEmailScreenState extends State<VerificarEmailScreen> {
  bool _checando = false;
  Timer? _timer;

  // 👇 Variáveis para o cooldown do botão de reenviar
  int _segundosCooldown = 0;
  Timer? _timerCooldown;

  @override
  void initState() {
    super.initState();
    // Auto-checa a cada 3s se o e-mail foi verificado (mesmo sem clicar)
    _timer = Timer.periodic(const Duration(seconds: 3), (_) async {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return;
      try {
        await user.reload();
        final updated = FirebaseAuth.instance.currentUser;
        if (updated != null && updated.emailVerified && mounted) {
          _timer?.cancel();
          _irParaHome();
        }
      } catch (_) {}
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _timerCooldown?.cancel(); // Cancela o cooldown ao sair da tela
    super.dispose();
  }

  void _irParaHome() {
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
    );
  }

  Future<void> _reenviar() async {
    // Impede o envio se o cooldown estiver ativo
    if (_segundosCooldown > 0) return;

    try {
      await AuthService.reenviarVerificacao();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('📧 Email reenviado!'),
          behavior: SnackBarBehavior.floating,
        ),
      );

      // Inicia o cooldown de 60 segundos
      setState(() => _segundosCooldown = 60);
      _timerCooldown?.cancel();
      _timerCooldown = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!mounted) {
          timer.cancel();
          return;
        }
        setState(() {
          if (_segundosCooldown > 0) {
            _segundosCooldown--;
          } else {
            timer.cancel();
          }
        });
      });
    } catch (e) {
      if (!mounted) return;

      String mensagem = 'Erro: ${e.toString()}';
      // Mensagem amigável para o erro de muitas requisições
      if (e.toString().contains('too-many-requests')) {
        mensagem =
            'Muitas tentativas. Aguarde alguns minutos antes de tentar novamente.';
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(mensagem)),
      );
    }
  }

  Future<void> _jaVerifiquei() async {
    setState(() => _checando = true);
    try {
      await AuthService.recarregarUsuario();
      final user = FirebaseAuth.instance.currentUser;

      if (user != null && user.emailVerified) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ E-mail verificado! Bem-vindo à Kodaff.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
        _timer?.cancel();
        _irParaHome(); // ← ESSA É A CORREÇÃO
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Ainda não verificamos. Confira sua caixa de entrada.',
            ),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _checando = false);
    }
  }

  Future<void> _sair() async {
    _timer?.cancel();
    await AuthService.logout();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 96,
                  height: 96,
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mark_email_unread_outlined,
                    size: 48,
                    color: AppColors.electricBlue,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Confirme seu e-mail',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Enviamos um link de confirmação para:\n${widget.email}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 15,
                  color: AppColors.textGray,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 32),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.gold.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.gold.withOpacity(0.3),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline, color: AppColors.gold, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Por segurança, só liberamos o acesso após você confirmar o e-mail.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textDark,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Não encontrou o e-mail? Verifique sua caixa de spam ou lixeira.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textGray,
                  height: 1.4,
                ),
              ),
              const Spacer(),
              ElevatedButton(
                onPressed: _checando ? null : _jaVerifiquei,
                child: _checando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Já verifiquei meu e-mail'),
              ),
              const SizedBox(height: 10),
              TextButton(
                // Desabilita o botão se estiver no cooldown
                onPressed: _segundosCooldown > 0 ? null : _reenviar,
                child: Text(
                  // Altera o texto mostrando o tempo restante
                  _segundosCooldown > 0
                      ? 'Aguarde ${_segundosCooldown}s para reenviar'
                      : 'Reenviar e-mail',
                  style: TextStyle(
                    color: _segundosCooldown > 0
                        ? AppColors.textGray
                        : AppColors.electricBlue,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              TextButton(
                onPressed: _sair,
                child: const Text(
                  'Sair da conta',
                  style: TextStyle(color: AppColors.textGray),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
