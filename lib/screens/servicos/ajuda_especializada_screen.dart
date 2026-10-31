import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/ajuda_service.dart';
import '../../core/utils/validators.dart';
import '../../routes/app_routes.dart';

class AjudaEspecializadaScreen extends StatefulWidget {
  const AjudaEspecializadaScreen({super.key});

  @override
  State<AjudaEspecializadaScreen> createState() =>
      _AjudaEspecializadaScreenState();
}

class _AjudaEspecializadaScreenState extends State<AjudaEspecializadaScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _valorCausaCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();

  final _whatsMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  String _tipoAjuda = 'advogado';
  String _especialidade = '';
  bool _enviando = false;
  bool _aceiteTermos = false;

  static const int _maxDescricao = 1500;
  static const int _minValorCausa = 500000;

  static const Color _azulJuridico = Color(0xFF1E3A8A);
  static const Color _laranjaEng = Color(0xFFEA580C);

  static const List<String> _especialidadesAdv = [
    'Cível / Contratos',
    'Empresarial / Societário',
    'Tributário',
    'Trabalhista',
    'Imobiliário',
    'Recuperação Judicial',
    'Outra',
  ];

  static const List<String> _especialidadesEng = [
    'Engenharia Civil',
    'Engenharia Ambiental',
    'Engenharia Elétrica',
    'Engenharia Mecânica',
    'Arquitetura e Urbanismo',
    'Outra',
  ];

  Color get _corAtual => _tipoAjuda == 'advogado' ? _azulJuridico : _laranjaEng;

  List<String> get _especialidades =>
      _tipoAjuda == 'advogado' ? _especialidadesAdv : _especialidadesEng;

  bool get _isAdvogado => _tipoAjuda == 'advogado';

  @override
  void initState() {
    super.initState();
    _descricaoCtrl.addListener(_atualizar);
  }

  @override
  void dispose() {
    _descricaoCtrl.removeListener(_atualizar);
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _whatsappCtrl.dispose();
    _valorCausaCtrl.dispose();
    _descricaoCtrl.dispose();
    super.dispose();
  }

  void _atualizar() => setState(() {});

  // ============================================================
  // VALIDAÇÕES
  // ============================================================

  String? _validarNome(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Informe seu nome completo';
    if (t.length < 3) return 'Nome muito curto';
    if (t.length > 80) return 'Máximo 80 caracteres';
    if (RegExp(r'\d').hasMatch(t)) return 'Nome não pode ter números';
    if (!t.contains(' ')) return 'Informe nome e sobrenome';
    if (Validators.contemPalavrao(t)) return 'Termos não permitidos';
    return null;
  }

  String? _validarEmail(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Informe seu e-mail';
    return Validators.emailProfissional(t);
  }

  String? _validarWhatsapp(String? v) {
    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return 'Informe seu WhatsApp';
    if (digits.length < 10 || digits.length > 11) return 'WhatsApp inválido';
    if (RegExp(r'^(\d)\1+$').hasMatch(digits)) return 'Número inválido';
    return null;
  }

  String? _validarValorCausa(String? v) {
    if (!_isAdvogado) return null;
    final t = (v ?? '').replaceAll(RegExp(r'\D'), '');
    if (t.isEmpty) return 'Informe o valor estimado';
    final n = int.tryParse(t);
    if (n == null) return 'Valor inválido';
    if (n < _minValorCausa) {
      return 'Atuamos apenas em causas acima de R\$ 500 mil';
    }
    if (n > 999999999999) return 'Valor muito alto';
    return null;
  }

  String? _validarEspecialidade(String? v) {
    if (v == null || v.isEmpty) {
      return _isAdvogado
          ? 'Selecione a área do direito'
          : 'Selecione a especialidade';
    }
    return null;
  }

  String? _validarDescricao(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Descreva sua necessidade';
    if (t.length < 30) return 'Descreva com pelo menos 30 caracteres';
    if (t.length > _maxDescricao) {
      return 'Máximo $_maxDescricao caracteres';
    }
    if (Validators.contemPalavrao(t)) return 'Termos não permitidos';
    return null;
  }

  // ============================================================
  // ENVIO
  // ============================================================

  Future<void> _enviar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      _snack('Verifique os campos destacados.');
      return;
    }

    if (_especialidade.isEmpty) {
      _snack(_isAdvogado
          ? 'Selecione a área do direito.'
          : 'Selecione a especialidade.');
      return;
    }

    if (!_aceiteTermos) {
      _snack('Aceite os termos para continuar.');
      return;
    }

    setState(() => _enviando = true);

    try {
      final valorCausa = _isAdvogado
          ? int.tryParse(_valorCausaCtrl.text.replaceAll(RegExp(r'\D'), ''))
          : null;

      await AjudaService.salvarSolicitacao(
        tipoAjuda: _tipoAjuda,
        especialidade: _especialidade,
        nome: _nomeCtrl.text,
        email: _emailCtrl.text,
        whatsapp: _whatsappCtrl.text,
        valorCausa: valorCausa,
        descricao: _descricaoCtrl.text,
      );

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.leadSalvo);
    } catch (e) {
      _snack('Erro: ${e.toString().replaceFirst("Exception: ", "")}');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _snack(String msg) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.error,
      ),
    );
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: const Text(
          'Ajuda Especializada',
          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUserInteraction,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildHeader(),
                const SizedBox(height: 24),

                // ============ QUIZ RÁPIDO ============
                _buildSecao(
                  titulo: 'Qual ajuda você precisa?',
                  subtitulo: 'Selecione a opção que combina com seu caso',
                  icon: Icons.help_outline_rounded,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: _CardTipo(
                            titulo: 'Advogado',
                            descricao: 'Causas acima\nde R\$ 500 mil',
                            icon: Icons.gavel_rounded,
                            cor: _azulJuridico,
                            selecionado: _isAdvogado,
                            onTap: () => setState(() {
                              _tipoAjuda = 'advogado';
                              _especialidade = '';
                            }),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: _CardTipo(
                            titulo: 'Engenheiro',
                            descricao: 'Civil, Ambiental\ne outros',
                            icon: Icons.engineering_rounded,
                            cor: _laranjaEng,
                            selecionado: !_isAdvogado,
                            onTap: () => setState(() {
                              _tipoAjuda = 'engenheiro';
                              _especialidade = '';
                            }),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ============ SOBRE O CASO ============
                _buildSecao(
                  titulo: _isAdvogado ? 'Sobre o caso' : 'Sobre o projeto',
                  subtitulo: _isAdvogado
                      ? 'Conte os detalhes da sua causa'
                      : 'Conte os detalhes do seu projeto',
                  icon: _isAdvogado
                      ? Icons.description_outlined
                      : Icons.architecture_rounded,
                  children: [
                    const Text(
                      'Área de atuação',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 6),
                    DropdownButtonFormField<String>(
                      value: _especialidade.isEmpty ? null : _especialidade,
                      items: _especialidades
                          .map(
                              (e) => DropdownMenuItem(value: e, child: Text(e)))
                          .toList(),
                      onChanged: (v) =>
                          setState(() => _especialidade = v ?? ''),
                      validator: _validarEspecialidade,
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark,
                      ),
                      decoration: _decoracao(_isAdvogado
                          ? 'Selecione a área do direito'
                          : 'Selecione a especialidade'),
                      icon: const Icon(Icons.keyboard_arrow_down_rounded),
                    ),
                    if (_isAdvogado) ...[
                      const SizedBox(height: 14),
                      _Campo(
                        label: 'Valor estimado da causa',
                        obrigatorio: true,
                        controller: _valorCausaCtrl,
                        hint: 'Mínimo R\$ 500.000,00',
                        keyboardType: TextInputType.number,
                        prefixo: 'R\$ ',
                        inputFormatters: [
                          FilteringTextInputFormatter.digitsOnly,
                          LengthLimitingTextInputFormatter(12),
                        ],
                        validator: _validarValorCausa,
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: _azulJuridico.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: _azulJuridico.withOpacity(0.2),
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.info_outline_rounded,
                                color: Color(0xFF1E3A8A), size: 16),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'O time jurídico da Kodaff atua exclusivamente em causas de alto valor — mínimo R\$ 500 mil.',
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
                    ],
                    const SizedBox(height: 14),
                    Row(
                      children: [
                        const Text(
                          'Descrição',
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
                          '${_descricaoCtrl.text.length}/$_maxDescricao',
                          style: TextStyle(
                            fontSize: 10.5,
                            color: _descricaoCtrl.text.length >
                                    (_maxDescricao * 0.9)
                                ? AppColors.error
                                : AppColors.textLight,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    TextFormField(
                      controller: _descricaoCtrl,
                      maxLines: 7,
                      maxLength: _maxDescricao,
                      validator: _validarDescricao,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(fontSize: 14, height: 1.5),
                      decoration: _decoracao(_isAdvogado
                              ? 'Descreva sua causa com o máximo de detalhes possível.'
                              : 'Descreva seu projeto ou problema técnico.')
                          .copyWith(counterText: ''),
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                // ============ SEUS DADOS ============
                _buildSecao(
                  titulo: 'Seus dados',
                  subtitulo: 'Para nossa equipe retornar',
                  icon: Icons.person_outline_rounded,
                  children: [
                    _Campo(
                      label: 'Nome completo',
                      obrigatorio: true,
                      controller: _nomeCtrl,
                      hint: 'Ex: João Carlos da Silva',
                      maxLength: 80,
                      textCapitalization: TextCapitalization.words,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(80),
                        FilteringTextInputFormatter.deny(RegExp(r'\d')),
                      ],
                      validator: _validarNome,
                    ),
                    const SizedBox(height: 14),
                    _Campo(
                      label: 'E-mail',
                      obrigatorio: true,
                      controller: _emailCtrl,
                      hint: 'seunome@exemplo.com',
                      keyboardType: TextInputType.emailAddress,
                      maxLength: 100,
                      inputFormatters: [
                        LengthLimitingTextInputFormatter(100),
                        FilteringTextInputFormatter.deny(RegExp(r'\s')),
                      ],
                      validator: _validarEmail,
                    ),
                    const SizedBox(height: 14),
                    _Campo(
                      label: 'WhatsApp',
                      obrigatorio: true,
                      controller: _whatsappCtrl,
                      hint: '(11) 91234-5678',
                      keyboardType: TextInputType.phone,
                      inputFormatters: [_whatsMask],
                      validator: _validarWhatsapp,
                    ),
                  ],
                ),

                const SizedBox(height: 24),

                // ============ ACEITE ============
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(12),
                    onTap: () => setState(() => _aceiteTermos = !_aceiteTermos),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 4, vertical: 8),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: 22,
                            height: 22,
                            child: Checkbox(
                              value: _aceiteTermos,
                              onChanged: (v) =>
                                  setState(() => _aceiteTermos = v ?? false),
                              activeColor: _corAtual,
                              materialTapTargetSize:
                                  MaterialTapTargetSize.shrinkWrap,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(5),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Autorizo a Kodaff e seus parceiros a entrar em contato para análise do meu caso.',
                              style: TextStyle(
                                fontSize: 11.5,
                                color: AppColors.textGray,
                                height: 1.45,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: _enviando ? null : _enviar,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _corAtual,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _enviando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.2,
                              color: Colors.white,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.send_rounded, size: 18),
                              SizedBox(width: 8),
                              Text(
                                'Enviar solicitação',
                                style: TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),

                const SizedBox(height: 14),

                const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.lock_outline_rounded,
                        size: 12, color: AppColors.textLight),
                    SizedBox(width: 6),
                    Text(
                      'Análise sigilosa e sem compromisso',
                      style: TextStyle(
                        fontSize: 10.5,
                        color: AppColors.textLight,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ============================================================
  // HEADER
  // ============================================================
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            _corAtual.withOpacity(0.12),
            _corAtual.withOpacity(0.03),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: _corAtual.withOpacity(0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: _corAtual.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.workspace_premium_rounded,
                  color: _corAtual,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Time especializado Kodaff',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    height: 1.25,
                    letterSpacing: -0.3,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          const Text(
            'Contamos com advogados e engenheiros parceiros prontos para '
            'resolver causas jurídicas de alto valor e projetos técnicos. '
            'Faça sua solicitação e nossa equipe entra em contato.',
            style: TextStyle(
              fontSize: 12.5,
              color: AppColors.textGray,
              height: 1.55,
            ),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // SEÇÃO
  // ============================================================
  Widget _buildSecao({
    required String titulo,
    required String subtitulo,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: _corAtual.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 17, color: _corAtual),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      titulo,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: -0.2,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      subtitulo,
                      style: const TextStyle(
                        fontSize: 11,
                        color: AppColors.textGray,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          ...children,
        ],
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
        borderSide: BorderSide(color: _corAtual, width: 1.5),
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
// CARD DE TIPO (advogado / engenheiro)
// ============================================================
class _CardTipo extends StatelessWidget {
  final String titulo;
  final String descricao;
  final IconData icon;
  final Color cor;
  final bool selecionado;
  final VoidCallback onTap;

  const _CardTipo({
    required this.titulo,
    required this.descricao,
    required this.icon,
    required this.cor,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
          decoration: BoxDecoration(
            color: selecionado ? cor.withOpacity(0.1) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selecionado ? cor : AppColors.borderLight,
              width: selecionado ? 1.8 : 1,
            ),
          ),
          child: Column(
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: selecionado ? cor : cor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  size: 24,
                  color: selecionado ? Colors.white : cor,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                titulo,
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w800,
                  color: selecionado ? cor : AppColors.textDark,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                descricao,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textGray,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CAMPO DE FORMULÁRIO
// ============================================================
class _Campo extends StatefulWidget {
  final String label;
  final bool obrigatorio;
  final TextEditingController controller;
  final String hint;
  final String? prefixo;
  final TextInputType? keyboardType;
  final int maxLines;
  final int? maxLength;
  final TextCapitalization? textCapitalization;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;

  const _Campo({
    required this.label,
    required this.controller,
    required this.hint,
    this.obrigatorio = false,
    this.prefixo,
    this.keyboardType,
    this.maxLines = 1,
    this.maxLength,
    this.textCapitalization,
    this.inputFormatters,
    this.validator,
  });

  @override
  State<_Campo> createState() => _CampoState();
}

class _CampoState extends State<_Campo> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_atualizar);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_atualizar);
    super.dispose();
  }

  void _atualizar() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final atual = widget.controller.text.length;
    final max = widget.maxLength;
    final mostrarContador = max != null && atual > (max * 0.5);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              widget.label,
              style: const TextStyle(
                fontSize: 12.5,
                fontWeight: FontWeight.w700,
                color: AppColors.textDark,
              ),
            ),
            if (widget.obrigatorio)
              const Text(
                ' *',
                style: TextStyle(
                  fontSize: 12.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.error,
                ),
              ),
            const Spacer(),
            if (mostrarContador)
              Text(
                '$atual/$max',
                style: TextStyle(
                  fontSize: 10.5,
                  color: atual > (max * 0.9)
                      ? AppColors.gold
                      : AppColors.textLight,
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: widget.controller,
          keyboardType: widget.keyboardType,
          maxLines: widget.maxLines,
          maxLength: widget.maxLength,
          textCapitalization:
              widget.textCapitalization ?? TextCapitalization.none,
          inputFormatters: widget.inputFormatters,
          validator: widget.validator,
          style: const TextStyle(fontSize: 14, color: AppColors.textDark),
          decoration: InputDecoration(
            hintText: widget.hint,
            hintStyle:
                const TextStyle(color: AppColors.textLight, fontSize: 13),
            prefixText: widget.prefixo,
            prefixStyle: const TextStyle(
              fontSize: 14,
              color: AppColors.textDark,
              fontWeight: FontWeight.w600,
            ),
            counterText: '',
            filled: true,
            fillColor: const Color(0xFFF8FAFC),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
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
              borderSide:
                  const BorderSide(color: Color(0xFF1E3A8A), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.error, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
