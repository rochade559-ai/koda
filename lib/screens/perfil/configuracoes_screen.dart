import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/utils/validators.dart';
import '../../routes/app_routes.dart';
import '../../widgets/campo_senha.dart';

class ConfiguracoesScreen extends StatefulWidget {
  const ConfiguracoesScreen({super.key});

  @override
  State<ConfiguracoesScreen> createState() => _ConfiguracoesScreenState();
}

class _ConfiguracoesScreenState extends State<ConfiguracoesScreen> {
  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Minha Conta')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ============ DADOS DO USUÁRIO ============
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.borderLight),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        color: AppColors.electricBlue.withOpacity(0.12),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.person_rounded,
                        color: AppColors.electricBlue,
                        size: 32,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.displayName ?? 'Usuário',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            user?.email ?? '-',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textGray,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // ============ SEGURANÇA ============
              const _TituloSecao('SEGURANÇA'),
              const SizedBox(height: 12),

              _ItemConfig(
                icone: Icons.lock_outline_rounded,
                titulo: 'Trocar senha',
                descricao: 'Altere sua senha de acesso',
                corIcone: AppColors.electricBlue,
                onTap: () => _abrirTrocarSenha(context),
              ),

              const SizedBox(height: 10),

              _ItemConfig(
                icone: Icons.mail_outline_rounded,
                titulo: 'Verificação de e-mail',
                descricao: user?.emailVerified == true
                    ? 'E-mail verificado'
                    : 'Reenviar link de verificação',
                corIcone: AppColors.success,
                onTap: user?.emailVerified == true
                    ? null
                    : () => _reenviarVerificacao(context),
              ),

              const SizedBox(height: 32),

              // ============ SUPORTE ============
              const _TituloSecao('SUPORTE'),
              const SizedBox(height: 12),

              _ItemConfig(
                icone: Icons.support_agent_rounded,
                titulo: 'Falar com o suporte',
                descricao: 'Envie sua dúvida ou problema para nossa equipe',
                corIcone: const Color(0xFF16A34A),
                onTap: () => _abrirSuporte(context),
              ),

              const SizedBox(height: 10),

              _ItemContatoSuporte(),

              const SizedBox(height: 32),

              // ============ PRIVACIDADE / LGPD ============
              const _TituloSecao('PRIVACIDADE E DADOS'),
              const SizedBox(height: 12),

              _ItemConfig(
                icone: Icons.description_outlined,
                titulo: 'Termos de Uso',
                descricao: 'Leia os termos da plataforma',
                corIcone: AppColors.textGray,
                onTap: () =>
                    _abrirUrl(context, 'https://www.kodaff.com/termos'),
              ),

              const SizedBox(height: 10),

              _ItemConfig(
                icone: Icons.privacy_tip_outlined,
                titulo: 'Política de Privacidade',
                descricao: 'Veja como tratamos seus dados',
                corIcone: AppColors.textGray,
                onTap: () =>
                    _abrirUrl(context, 'https://www.kodaff.com/privacidade'),
              ),

              const SizedBox(height: 10),

              _ItemConfig(
                icone: Icons.delete_outline_rounded,
                titulo: 'Excluir minha conta',
                descricao: 'Todos os seus dados serão removidos',
                corIcone: AppColors.error,
                textoVermelho: true,
                onTap: () => _confirmarDelete(context),
              ),

              const SizedBox(height: 32),

              // ============ SAIR ============
              OutlinedButton.icon(
                onPressed: () async {
                  await AuthService.logout();
                  if (!context.mounted) return;
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.logout_rounded, size: 20),
                label: const Text('Sair da conta'),
                style: OutlinedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                  side: const BorderSide(
                      color: AppColors.borderLight, width: 1.5),
                  foregroundColor: AppColors.textDark,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
              ),

              const SizedBox(height: 32),

              // ============ INFO LGPD ============
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.shield_outlined,
                        color: AppColors.electricBlue, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Seus dados são protegidos conforme a LGPD (Lei 13.709/2018). Você pode excluir sua conta a qualquer momento.',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textGray,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // TROCAR SENHA
  // ============================================================
  void _abrirTrocarSenha(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _TrocarSenhaSheet(),
    );
  }

  // ============================================================
  // SUPORTE
  // ============================================================
  void _abrirSuporte(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _SuporteSheet(),
    );
  }

  // ============================================================
  // REENVIAR VERIFICAÇÃO
  // ============================================================
  Future<void> _reenviarVerificacao(BuildContext context) async {
    try {
      await AuthService.reenviarVerificacao();
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('E-mail de verificação reenviado.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e')),
      );
    }
  }

  // ============================================================
  // ABRIR URL EXTERNA
  // ============================================================
  Future<void> _abrirUrl(BuildContext context, String url) async {
    try {
      await launchUrl(
        Uri.parse(url),
        mode: LaunchMode.externalApplication,
      );
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o link.')),
      );
    }
  }

  // ============================================================
  // CONFIRMAR DELETE
  // ============================================================
  void _confirmarDelete(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _DeleteContaSheet(),
    );
  }
}

// ============================================================
// TÍTULO DE SEÇÃO
// ============================================================
class _TituloSecao extends StatelessWidget {
  final String texto;
  const _TituloSecao(this.texto);

  @override
  Widget build(BuildContext context) {
    return Text(
      texto,
      style: const TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: AppColors.textGray,
        letterSpacing: 0.8,
      ),
    );
  }
}

// ============================================================
// ITEM DE CONFIGURAÇÃO
// ============================================================
class _ItemConfig extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String descricao;
  final Color corIcone;
  final VoidCallback? onTap;
  final bool textoVermelho;

  const _ItemConfig({
    required this.icone,
    required this.titulo,
    required this.descricao,
    required this.corIcone,
    this.onTap,
    this.textoVermelho = false,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: corIcone.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icone, color: corIcone, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: textoVermelho
                            ? AppColors.error
                            : AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      descricao,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.textGray,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              if (onTap != null)
                const Icon(Icons.arrow_forward_ios_rounded,
                    size: 14, color: AppColors.textGray),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CARD DE CONTATO DO SUPORTE (email direto)
// ============================================================
class _ItemContatoSuporte extends StatelessWidget {
  static const String emailSuporte = 'atendimento@kodaff.com';

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () async {
          final uri = Uri(
            scheme: 'mailto',
            path: emailSuporte,
            query: 'subject=Suporte Kodaff',
          );
          try {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
          } catch (_) {
            if (!context.mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Não foi possível abrir o e-mail.'),
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.borderLight),
          ),
          child: Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.mail_outline_rounded,
                    color: AppColors.electricBlue, size: 22),
              ),
              const SizedBox(width: 14),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'E-mail direto',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      emailSuporte,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: AppColors.electricBlue,
                        fontWeight: FontWeight.w600,
                        height: 1.3,
                      ),
                    ),
                    SizedBox(height: 2),
                    Text(
                      'Resposta em até 24h úteis',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.open_in_new_rounded,
                  size: 16, color: AppColors.textGray),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MODAL — TROCAR SENHA
// ============================================================
class _TrocarSenhaSheet extends StatefulWidget {
  const _TrocarSenhaSheet();

  @override
  State<_TrocarSenhaSheet> createState() => _TrocarSenhaSheetState();
}

class _TrocarSenhaSheetState extends State<_TrocarSenhaSheet> {
  final _formKey = GlobalKey<FormState>();
  final _atualCtrl = TextEditingController();
  final _novaCtrl = TextEditingController();

  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _atualCtrl.dispose();
    _novaCtrl.dispose();
    super.dispose();
  }

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await AuthService.trocarSenha(
        senhaAtual: _atualCtrl.text,
        novaSenha: _novaCtrl.text,
      );
      if (!mounted) return;
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Senha alterada com sucesso.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setState(() => _erro = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Trocar senha',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Digite sua senha atual e escolha uma nova.',
                style: TextStyle(color: AppColors.textGray),
              ),
              const SizedBox(height: 24),
              CampoSenha(
                label: 'Senha atual',
                controller: _atualCtrl,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
              ),
              const SizedBox(height: 16),
              CampoSenha(
                label: 'Nova senha',
                controller: _novaCtrl,
                mostrarForca: true,
                validator: (v) => Validators.senha(v),
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
                  child: Text(
                    _erro!,
                    style:
                        const TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _carregando ? null : _salvar,
                child: _carregando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Alterar senha'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MODAL — SUPORTE
// ============================================================
class _SuporteSheet extends StatefulWidget {
  const _SuporteSheet();

  @override
  State<_SuporteSheet> createState() => _SuporteSheetState();
}

class _SuporteSheetState extends State<_SuporteSheet> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();

  String _assunto = 'Problema técnico';
  bool _carregando = false;
  String? _erro;
  bool _enviado = false;

  static const int _maxDescricao = 500;

  static const List<String> _assuntos = [
    'Problema técnico',
    'Pagamento ou Cryptons',
    'Anúncio no Market',
    'Permuta e construção',
    'Conta e login',
    'Outro',
  ];

  @override
  void initState() {
    super.initState();
    // Preenche automático com o e-mail da conta
    _emailCtrl.text = FirebaseAuth.instance.currentUser?.email ?? '';
    _descricaoCtrl.addListener(_atualizarContador);
  }

  @override
  void dispose() {
    _descricaoCtrl.removeListener(_atualizarContador);
    _emailCtrl.dispose();
    _descricaoCtrl.dispose();
    super.dispose();
  }

  void _atualizarContador() => setState(() {});

  String? _validarEmail(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Informe um e-mail para retorno';
    return Validators.emailProfissional(t);
  }

  String? _validarDescricao(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Descreva o problema';
    if (t.length < 20) return 'Descreva com pelo menos 20 caracteres';
    if (t.length > _maxDescricao) {
      return 'Máximo de $_maxDescricao caracteres';
    }
    if (Validators.contemPalavrao(t)) return 'Termos não permitidos';
    return null;
  }

  Future<void> _enviar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final user = FirebaseAuth.instance.currentUser;

      await FirebaseFirestore.instance.collection('suporte').add({
        'uid': user?.uid ?? 'anonimo',
        'email_conta': user?.email ?? '',
        'email_retorno': _emailCtrl.text.trim(),
        'assunto': _assunto,
        'descricao': _descricaoCtrl.text.trim(),
        'status': 'aberto',
        'criado_em': FieldValue.serverTimestamp(),
      });

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
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.9,
        ),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: _enviado ? _buildSucesso() : _buildFormulario(),
      ),
    );
  }

  // ============================================================
  // TELA DE SUCESSO
  // ============================================================
  Widget _buildSucesso() {
    return Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AppColors.borderLight,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 28),
          Container(
            width: 72,
            height: 72,
            decoration: BoxDecoration(
              color: AppColors.success.withOpacity(0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.check_circle_rounded,
              color: AppColors.success,
              size: 40,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'Solicitação enviada',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w800,
              color: AppColors.textDark,
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Nossa equipe vai analisar e responder no e-mail informado em até 24h úteis.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13.5,
              color: AppColors.textGray,
              height: 1.5,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Fechar'),
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // FORMULÁRIO
  // ============================================================
  Widget _buildFormulario() {
    final atual = _descricaoCtrl.text.length;
    final restantes = _maxDescricao - atual;
    final quaseLimite = restantes <= 50;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        autovalidateMode: AutovalidateMode.onUserInteraction,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),

            Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: const Color(0xFF16A34A).withOpacity(0.12),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(Icons.support_agent_rounded,
                      color: Color(0xFF16A34A), size: 22),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Falar com o suporte',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          letterSpacing: -0.3,
                        ),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Resposta em até 24h úteis',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.textGray,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            // ============ E-MAIL ============
            const Text(
              'E-mail para retorno',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _emailCtrl,
              keyboardType: TextInputType.emailAddress,
              validator: _validarEmail,
              style: const TextStyle(fontSize: 14),
              decoration: _decoracao('seunome@exemplo.com'),
            ),

            const SizedBox(height: 16),

            // ============ ASSUNTO ============
            const Text(
              'Assunto',
              style: TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 6),
            DropdownButtonFormField<String>(
              value: _assunto,
              items: _assuntos
                  .map((a) => DropdownMenuItem(value: a, child: Text(a)))
                  .toList(),
              onChanged: _carregando
                  ? null
                  : (v) => setState(() => _assunto = v ?? _assunto),
              style: const TextStyle(fontSize: 14, color: AppColors.textDark),
              decoration: _decoracao('Selecione o assunto'),
              icon: const Icon(Icons.keyboard_arrow_down_rounded),
            ),

            const SizedBox(height: 16),

            // ============ DESCRIÇÃO ============
            Row(
              children: [
                const Text(
                  'Descrição do problema',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const Text(
                  ' *',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.error,
                  ),
                ),
                const Spacer(),
                Text(
                  restantes >= 0 ? '$restantes restantes' : 'Excedeu',
                  style: TextStyle(
                    fontSize: 10.5,
                    fontWeight: FontWeight.w600,
                    color: quaseLimite ? AppColors.error : AppColors.textLight,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            TextFormField(
              controller: _descricaoCtrl,
              maxLines: 6,
              maxLength: _maxDescricao,
              validator: _validarDescricao,
              style: const TextStyle(fontSize: 14, height: 1.5),
              decoration: _decoracao(
                'Descreva com detalhes o que está acontecendo. Inclua telas, mensagens de erro ou passos para reproduzir.',
              ).copyWith(counterText: ''),
            ),

            const SizedBox(height: 12),

            // ============ INFO ============
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.electricBlue.withOpacity(0.06),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: AppColors.electricBlue.withOpacity(0.2),
                ),
              ),
              child: const Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline_rounded,
                      color: AppColors.electricBlue, size: 16),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Quanto mais detalhes, mais rápido conseguimos resolver.',
                      style: TextStyle(
                        fontSize: 11.5,
                        color: AppColors.textGray,
                        height: 1.4,
                      ),
                    ),
                  ),
                ],
              ),
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
                child: Text(
                  _erro!,
                  style: const TextStyle(color: AppColors.error, fontSize: 13),
                ),
              ),
            ],

            const SizedBox(height: 22),

            SizedBox(
              height: 52,
              child: ElevatedButton(
                onPressed: _carregando ? null : _enviar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF16A34A),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: _carregando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text(
                        'Enviar solicitação',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  InputDecoration _decoracao(String hint) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.textLight, fontSize: 13),
      filled: true,
      fillColor: const Color(0xFFF8FAFC),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.borderLight),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF16A34A), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
    );
  }
}

// ============================================================
// MODAL — DELETAR CONTA
// ============================================================
class _DeleteContaSheet extends StatefulWidget {
  const _DeleteContaSheet();

  @override
  State<_DeleteContaSheet> createState() => _DeleteContaSheetState();
}

class _DeleteContaSheetState extends State<_DeleteContaSheet> {
  final _formKey = GlobalKey<FormState>();
  final _senhaCtrl = TextEditingController();

  bool _carregando = false;
  String? _erro;

  @override
  void dispose() {
    _senhaCtrl.dispose();
    super.dispose();
  }

  Future<void> _deletar() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      await AuthService.deletarConta(senhaAtual: _senhaCtrl.text);
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRoutes.home,
        (route) => false,
      );
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Sua conta foi excluída.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      setState(() => _erro = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _carregando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: AppColors.background,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.borderLight,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Center(
                child: Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning_amber_rounded,
                    color: AppColors.error,
                    size: 40,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Excluir minha conta?',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Esta ação é permanente. Todos os seus dados, solicitações e histórico serão removidos. Não é possível desfazer.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.textGray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              CampoSenha(
                label: 'Confirme sua senha',
                controller: _senhaCtrl,
                validator: (v) =>
                    (v == null || v.isEmpty) ? 'Campo obrigatório' : null,
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
                  child: Text(
                    _erro!,
                    style:
                        const TextStyle(color: AppColors.error, fontSize: 13),
                  ),
                ),
              ],
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _carregando ? null : _deletar,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.error,
                  foregroundColor: Colors.white,
                ),
                child: _carregando
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                            color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('Sim, excluir minha conta'),
              ),
              const SizedBox(height: 10),
              TextButton(
                onPressed: _carregando ? null : () => Navigator.pop(context),
                child: const Text(
                  'Cancelar',
                  style: TextStyle(
                    color: AppColors.textGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
