import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/firestore_service.dart';
import '../../core/utils/validators.dart';
import '../../routes/app_routes.dart';

class CaptacaoConstrucaoScreen extends StatefulWidget {
  const CaptacaoConstrucaoScreen({super.key});

  @override
  State<CaptacaoConstrucaoScreen> createState() =>
      _CaptacaoConstrucaoScreenState();
}

class _CaptacaoConstrucaoScreenState extends State<CaptacaoConstrucaoScreen> {
  final _formKey = GlobalKey<FormState>();

  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _whatsappCtrl = TextEditingController();
  final _localizacaoCtrl = TextEditingController();
  final _areaCtrl = TextEditingController();
  final _iptuCtrl = TextEditingController();

  final _whatsMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  static const int maxFotos = 5;
  static const int maxFotoBytes = 5 * 1024 * 1024;
  final List<PlatformFile> _fotos = [];

  String _tipoImovel = 'Terreno vazio';
  bool _enviando = false;
  bool _aceiteTermos = false;
  String _statusUpload = '';

  static const Color _verde = Color(0xFF16A34A);

  @override
  void dispose() {
    _nomeCtrl.dispose();
    _emailCtrl.dispose();
    _whatsappCtrl.dispose();
    _localizacaoCtrl.dispose();
    _areaCtrl.dispose();
    _iptuCtrl.dispose();
    super.dispose();
  }

  // ==================== VALIDAÇÕES ====================

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
    if (digits.length < 10 || digits.length > 11) {
      return 'WhatsApp inválido';
    }
    if (RegExp(r'^(\d)\1+$').hasMatch(digits)) return 'Número inválido';
    return null;
  }

  String? _validarLocalizacao(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return 'Informe a localização';
    if (t.length < 10) return 'Detalhe melhor (mínimo 10 caracteres)';
    if (t.length > 300) return 'Máximo 300 caracteres';
    if (Validators.contemPalavrao(t)) return 'Termos não permitidos';
    if (RegExp(r'^[\d\s\.\-\,]+$').hasMatch(t)) {
      return 'Inclua bairro e cidade';
    }
    return null;
  }

  String? _validarArea(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return null;
    final n = int.tryParse(t.replaceAll(RegExp(r'\D'), ''));
    if (n == null) return 'Valor inválido';
    if (n < 20) return 'Área mínima: 20 m²';
    if (n > 10000000) return 'Área máxima: 10.000.000 m²';
    return null;
  }

  String? _validarIptu(String? v) {
    final t = (v ?? '').trim();
    if (t.isEmpty) return null;
    if (t.length > 30) return 'Máximo 30 caracteres';
    if (!RegExp(r'^[\d\.\-\/\s]+$').hasMatch(t)) {
      return 'Apenas números e hífen';
    }
    return null;
  }

  // ==================== FOTOS ====================

  String _getContentType(String nome) {
    final lower = nome.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  Future<void> _escolherFotos() async {
    if (_fotos.length >= maxFotos) {
      _snack('Máximo de $maxFotos fotos.');
      return;
    }

    final restantes = maxFotos - _fotos.length;

    try {
      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: true,
        withData: true,
      );

      if (resultado == null || resultado.files.isEmpty) return;

      final novas = resultado.files.take(restantes).toList();

      for (final arq in novas) {
        if (arq.size > maxFotoBytes) {
          if (!mounted) return;
          _snack('"${arq.name}" passa de 5 MB.');
          return;
        }
      }

      setState(() => _fotos.addAll(novas));
    } catch (e) {
      _snack('Erro ao escolher fotos.');
    }
  }

  void _removerFoto(int index) {
    setState(() => _fotos.removeAt(index));
  }

  Future<List<String>> _fazerUploadFotos(String leadId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final urls = <String>[];

    for (int i = 0; i < _fotos.length; i++) {
      final foto = _fotos[i];

      if (!mounted) return urls;
      setState(() =>
          _statusUpload = 'Enviando foto ${i + 1} de ${_fotos.length}...');

      final nomeLimpo = foto.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final path =
          'leads_construcao/${user.uid}/$leadId/${DateTime.now().millisecondsSinceEpoch}_$nomeLimpo';

      final ref = FirebaseStorage.instance.ref(path);
      final metadata = SettableMetadata(
        contentType: _getContentType(foto.name),
      );

      final task = kIsWeb
          ? ref.putData(foto.bytes!, metadata)
          : ref.putFile(File(foto.path!), metadata);

      final snap = await task;
      final url = await snap.ref.getDownloadURL();
      urls.add(url);
    }

    return urls;
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

  // ==================== ENVIO ====================

  Future<void> _enviar() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      _snack('Verifique os campos destacados.');
      return;
    }

    if (!_aceiteTermos) {
      _snack('Aceite os termos para continuar.');
      return;
    }

    setState(() {
      _enviando = true;
      _statusUpload = '';
    });

    try {
      final leadId = await FirestoreService.salvarLeadConstrucao(
        nome: _nomeCtrl.text,
        email: _emailCtrl.text,
        whatsapp: _whatsappCtrl.text,
        tipoImovel: _tipoImovel,
        localizacao: _localizacaoCtrl.text,
        areaAproximada: _areaCtrl.text,
        iptu: _iptuCtrl.text,
      );

      if (_fotos.isNotEmpty) {
        final urls = await _fazerUploadFotos(leadId);
        await FirestoreService.atualizarFotosLeadConstrucao(leadId, urls);
      }

      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.leadSalvo);
    } catch (e) {
      _snack('Erro: ${e.toString().replaceFirst("Exception: ", "")}');
    } finally {
      if (mounted) {
        setState(() {
          _enviando = false;
          _statusUpload = '';
        });
      }
    }
  }

  // ==================== BUILD ====================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        foregroundColor: AppColors.textDark,
        title: const Text(
          'Permuta & Construção',
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
                _buildSecao(
                  titulo: 'Sobre o imóvel',
                  subtitulo: 'Nos conte o que você tem',
                  icon: Icons.home_work_outlined,
                  children: [
                    const Text(
                      'Tipo de imóvel',
                      style: TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: _ChipTipo(
                            label: 'Terreno vazio',
                            icon: Icons.landscape_rounded,
                            selecionado: _tipoImovel == 'Terreno vazio',
                            onTap: () =>
                                setState(() => _tipoImovel = 'Terreno vazio'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _ChipTipo(
                            label: 'Casa / imóvel antigo',
                            icon: Icons.house_siding_rounded,
                            selecionado: _tipoImovel == 'Casa / imóvel antigo',
                            onTap: () => setState(
                                () => _tipoImovel = 'Casa / imóvel antigo'),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _Campo(
                      label: 'Localização',
                      obrigatorio: true,
                      controller: _localizacaoCtrl,
                      hint: 'Ex: Rua das Flores, 123 — Vila Mariana, SP',
                      maxLines: 2,
                      maxLength: 300,
                      textCapitalization: TextCapitalization.sentences,
                      validator: _validarLocalizacao,
                    ),
                    const SizedBox(height: 14),
                    _Campo(
                      label: 'Área aproximada (m²)',
                      controller: _areaCtrl,
                      hint: 'Ex: 250',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        LengthLimitingTextInputFormatter(8),
                      ],
                      validator: _validarArea,
                    ),
                    const SizedBox(height: 14),
                    _Campo(
                      label: 'Número do IPTU',
                      controller: _iptuCtrl,
                      hint: 'Opcional — agiliza a análise',
                      maxLength: 30,
                      inputFormatters: [LengthLimitingTextInputFormatter(30)],
                      validator: _validarIptu,
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                _buildSecao(
                  titulo: 'Fotos do imóvel',
                  subtitulo: 'Opcional — até $maxFotos fotos, 5 MB cada',
                  icon: Icons.photo_library_outlined,
                  children: [_buildGridFotos()],
                ),
                const SizedBox(height: 20),
                _buildSecao(
                  titulo: 'Seus dados',
                  subtitulo: 'Para retornarmos em até 48h',
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
                              activeColor: _verde,
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
                              'Autorizo a Kodaff a entrar em contato e usar '
                              'meus dados para análise da proposta.',
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
                      backgroundColor: _verde,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                    child: _enviando
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2.2,
                                  color: Colors.white,
                                ),
                              ),
                              if (_statusUpload.isNotEmpty) ...[
                                const SizedBox(width: 12),
                                Flexible(
                                  child: Text(
                                    _statusUpload,
                                    style: const TextStyle(
                                      fontSize: 13,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ],
                            ],
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
                      'Análise gratuita e sem compromisso',
                      style:
                          TextStyle(fontSize: 10.5, color: AppColors.textLight),
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

  Widget _buildGridFotos() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 8,
            mainAxisSpacing: 8,
            childAspectRatio: 1,
          ),
          itemCount: _fotos.length + (_fotos.length < maxFotos ? 1 : 0),
          itemBuilder: (context, i) {
            if (i == _fotos.length) {
              return Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(12),
                  onTap: _enviando ? null : _escolherFotos,
                  child: Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF8FAFC),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: _verde.withOpacity(0.4),
                        width: 1.5,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            size: 26, color: _verde.withOpacity(0.8)),
                        const SizedBox(height: 4),
                        Text(
                          '${_fotos.length}/$maxFotos',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: _verde.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }

            final foto = _fotos[i];
            final isCapa = i == 0;

            return Stack(
              children: [
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: _previewFoto(foto),
                  ),
                ),
                if (isCapa)
                  Positioned(
                    top: 4,
                    left: 4,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: _verde,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'CAPA',
                        style: TextStyle(
                          fontSize: 8,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(20),
                      onTap: _enviando ? null : () => _removerFoto(i),
                      child: Container(
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: Colors.black.withOpacity(0.7),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.close_rounded,
                            size: 13, color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: 10),
        const Row(
          children: [
            Icon(Icons.info_outline_rounded,
                size: 12, color: AppColors.textLight),
            SizedBox(width: 6),
            Expanded(
              child: Text(
                'Fotos ajudam na análise. Envie terreno, fachada, planta ou escritura.',
                style: TextStyle(
                  fontSize: 10.5,
                  color: AppColors.textLight,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _previewFoto(PlatformFile foto) {
    if (kIsWeb) {
      if (foto.bytes != null) {
        return Image.memory(foto.bytes!, fit: BoxFit.cover);
      }
    } else {
      if (foto.path != null) {
        return Image.file(File(foto.path!), fit: BoxFit.cover);
      }
    }
    return Container(
      color: _verde.withOpacity(0.06),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 26, color: AppColors.textGray),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [_verde.withOpacity(0.12), _verde.withOpacity(0.03)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        border: Border.all(color: _verde.withOpacity(0.25)),
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
                  color: _verde.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.apartment_rounded,
                    color: _verde, size: 24),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Transforme seu terreno em um prédio novo',
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
            'A Kodaff compra seu terreno ou casa antiga, ou oferece '
            'apartamentos prontos em permuta. Construímos conforme o '
            'zoneamento da sua cidade — de pequenos lotes a grandes glebas.',
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
                  color: _verde.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(9),
                ),
                child: Icon(icon, size: 17, color: _verde),
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
}

// ============================================================
// CAMPO DE FORMULÁRIO
// ============================================================
class _Campo extends StatefulWidget {
  final String label;
  final bool obrigatorio;
  final TextEditingController controller;
  final String hint;
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
                  const BorderSide(color: Color(0xFF16A34A), width: 1.5),
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

// ============================================================
// CHIP TIPO IMÓVEL
// ============================================================
class _ChipTipo extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selecionado;
  final VoidCallback onTap;

  const _ChipTipo({
    required this.label,
    required this.icon,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    const verde = Color(0xFF16A34A);
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
          decoration: BoxDecoration(
            color:
                selecionado ? verde.withOpacity(0.12) : const Color(0xFFF8FAFC),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selecionado ? verde : AppColors.borderLight,
              width: selecionado ? 1.5 : 1,
            ),
          ),
          child: Column(
            children: [
              Icon(icon,
                  size: 22, color: selecionado ? verde : AppColors.textGray),
              const SizedBox(height: 6),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: selecionado ? verde : AppColors.textGray,
                  height: 1.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
