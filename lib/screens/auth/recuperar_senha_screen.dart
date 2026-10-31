import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/validators.dart';
import '../../routes/app_routes.dart';
import '../../widgets/campo_email.dart';

class RecuperarSenhaScreen extends StatefulWidget {
  const RecuperarSenhaScreen({super.key});

  @override
  State<RecuperarSenhaScreen> createState() => _RecuperarSenhaScreenState();
}

class _RecuperarSenhaScreenState extends State<RecuperarSenhaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();

  bool _carregando = false;
  bool _enviado = false;
  String? _erro;

  @override
  void dispose() {
    _emailCtrl.dispose();
    super.dispose();
  }

  Future<void> _enviar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await AuthService.enviarResetSenha(_emailCtrl.text.trim());
      if (!mounted) return;
      setState(() => _enviado = true);
    } catch (e) {
      setState(() => _erro = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Recuperar senha')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: _enviado ? _buildSucesso() : _buildFormulario(),
        ),
      ),
    );
  }

  // ============================================================
  // ESTADO 1 — Formulário
  // ============================================================
  Widget _buildFormulario() {
    return Form(
      key: _formKey,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 8),
          Center(
            child: Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                color: AppColors.electricBlue.withOpacity(0.08),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.lock_reset_rounded,
                size: 44,
                color: AppColors.electricBlue,
              ),
            ),
          ),
          const SizedBox(height: 28),
          const Text(
            'Esqueceu sua senha?',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Digite o e-mail cadastrado na sua conta Kodaff. Enviaremos um link seguro para você criar uma nova senha.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 15,
              color: AppColors.textGray,
              height: 1.55,
            ),
          ),
          const SizedBox(height: 32),
          CampoEmail(
            controller: _emailCtrl,
            label: 'E-mail cadastrado',
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
                      style:
                          const TextStyle(color: AppColors.error, fontSize: 13),
                    ),
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 28),
          ElevatedButton(
            onPressed: _carregando ? null : _enviar,
            child: _carregando
                ? const SizedBox(
                    height: 20,
                    width: 20,
                    child: CircularProgressIndicator(
                        color: Colors.white, strokeWidth: 2),
                  )
                : const Text('Enviar link de recuperação'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Voltar para o login',
              style: TextStyle(
                color: AppColors.textGray,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // ESTADO 2 — Email enviado com sucesso
  // ============================================================
  Widget _buildSucesso() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 40),
        Center(
          child: Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.mark_email_read_outlined,
              size: 48,
              color: AppColors.success,
            ),
          ),
        ),
        const SizedBox(height: 28),
        const Text(
          'Link enviado!',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w800,
            color: AppColors.textDark,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'Enviamos um link de recuperação para:\n${_emailCtrl.text.trim()}',
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
            color: AppColors.electricBlue.withOpacity(0.06),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.electricBlue.withOpacity(0.2),
            ),
          ),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(Icons.info_outline,
                      color: AppColors.electricBlue, size: 20),
                  SizedBox(width: 8),
                  Text(
                    'Próximos passos',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: AppColors.electricBlue,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
              SizedBox(height: 10),
              _Passo(texto: '1. Abra seu e-mail'),
              _Passo(texto: '2. Clique no link da Kodaff'),
              _Passo(texto: '3. Crie sua nova senha'),
              _Passo(texto: '4. Volte aqui e faça login'),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const Text(
          'Não recebeu? Confira a caixa de spam ou tente novamente em alguns minutos.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 12,
            color: AppColors.textGray,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 40),
        ElevatedButton(
          onPressed: () {
            Navigator.pushReplacementNamed(context, AppRoutes.login);
          },
          child: const Text('Voltar para o login'),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: () {
            setState(() {
              _enviado = false;
              _erro = null;
            });
          },
          child: const Text(
            'Enviar para outro e-mail',
            style: TextStyle(
              color: AppColors.electricBlue,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }
}

class _Passo extends StatelessWidget {
  final String texto;
  const _Passo({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 13,
          color: AppColors.textDark,
          height: 1.5,
        ),
      ),
    );
  }
}
