import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/utils/validators.dart';
import '../../routes/app_routes.dart';
import '../../widgets/campo_texto.dart';

class CadastroInvestidorScreen extends StatefulWidget {
  const CadastroInvestidorScreen({super.key});

  @override
  State<CadastroInvestidorScreen> createState() =>
      _CadastroInvestidorScreenState();
}

class _CadastroInvestidorScreenState extends State<CadastroInvestidorScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _whatsCtrl = TextEditingController();

  final _whatsMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _whatsCtrl.dispose();
    super.dispose();
  }

  void _continuar() {
    if (!_formKey.currentState!.validate()) return;
    Navigator.pushNamed(context, AppRoutes.quizInvestidor);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cadastro do Investidor')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Vamos começar',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Precisamos de alguns dados para seguir.',
                  style: TextStyle(color: AppColors.textGray),
                ),
                const SizedBox(height: 32),
                CampoTexto(
                  label: 'Nome completo',
                  controller: _nomeCtrl,
                  validator: (v) => Validators.nome(v),
                ),
                const SizedBox(height: 16),
                CampoTexto(
                  label: 'E-mail',
                  controller: _emailCtrl,
                  keyboard: TextInputType.emailAddress,
                  validator: (v) => Validators.email(v),
                ),
                const SizedBox(height: 16),
                CampoTexto(
                  label: 'WhatsApp',
                  controller: _whatsCtrl,
                  keyboard: TextInputType.phone,
                  inputFormatters: [_whatsMask],
                  validator: (v) => Validators.whatsapp(v),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _continuar,
                  child: const Text('Continuar'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
