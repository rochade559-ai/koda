import 'dart:io';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/anuncios_service.dart';
import '../../core/utils/validators.dart';

class CriarAnuncioScreen extends StatefulWidget {
  const CriarAnuncioScreen({super.key});

  @override
  State<CriarAnuncioScreen> createState() => _CriarAnuncioScreenState();
}

class _CriarAnuncioScreenState extends State<CriarAnuncioScreen> {
  final _formKey = GlobalKey<FormState>();
  final _tituloCtrl = TextEditingController();
  final _descricaoCtrl = TextEditingController();
  final _precoCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _whatsCtrl = TextEditingController();

  final _whatsMask = MaskTextInputFormatter(
    mask: '(##) #####-####',
    filter: {'#': RegExp(r'[0-9]')},
  );

  static const int maxFotos = 7;
  final List<PlatformFile> _fotos = [];

  String _categoria = 'outros';
  bool _carregando = false;
  String? _erro;
  String _statusUpload = '';

  @override
  void dispose() {
    _tituloCtrl.dispose();
    _descricaoCtrl.dispose();
    _precoCtrl.dispose();
    _emailCtrl.dispose();
    _whatsCtrl.dispose();
    super.dispose();
  }

  String _getContentType(String nome) {
    final lower = nome.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.jpg') || lower.endsWith('.jpeg')) return 'image/jpeg';
    if (lower.endsWith('.gif')) return 'image/gif';
    if (lower.endsWith('.webp')) return 'image/webp';
    return 'image/jpeg';
  }

  IconData _iconeCategoria(String id) {
    switch (id) {
      case 'terras':
        return Icons.landscape_rounded;
      case 'ouro':
        return Icons.diamond_rounded;
      case 'empresas':
        return Icons.business_rounded;
      case 'maquinario':
        return Icons.precision_manufacturing_rounded;
      case 'tecnologia':
        return Icons.memory_rounded;
      default:
        return Icons.category_rounded;
    }
  }

  String? _validarDescricao(String? value) {
    final texto = value?.trim() ?? '';
    if (texto.isEmpty) return 'Campo obrigatório';
    if (texto.length < 30) {
      return 'Descrição muito curta (mínimo 30 caracteres)';
    }
    if (RegExp(r'[\w\.-]+@[\w\.-]+\.\w+').hasMatch(texto)) {
      return 'Não é permitido colocar e-mail na descrição';
    }
    if (RegExp(r'\(?\d{2}\)?\s?\d{4,5}[\s-]?\d{4}').hasMatch(texto)) {
      return 'Não é permitido colocar telefone na descrição';
    }
    if (RegExp(r'@[\w\.]+').hasMatch(texto)) {
      return 'Não é permitido colocar @ de redes sociais';
    }
    if (Validators.contemPalavrao(texto)) {
      return 'O texto contém termos não permitidos';
    }
    return null;
  }

  Future<void> _escolherFotos() async {
    if (_fotos.length >= maxFotos) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Máximo de 7 fotos por anúncio.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
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
        if (arq.size > 5 * 1024 * 1024) {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('"${arq.name}" é maior que 5 MB.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
          return;
        }
      }

      setState(() {
        _fotos.addAll(novas);
        _erro = null;
      });
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Erro ao escolher fotos.')),
      );
    }
  }

  void _removerFoto(int index) {
    setState(() => _fotos.removeAt(index));
  }

  Future<List<String>> _fazerUploadFotos(String anuncioId) async {
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
          'anuncios/${user.uid}/$anuncioId/${DateTime.now().millisecondsSinceEpoch}_$nomeLimpo';

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

  Future<void> _salvar() async {
    if (!_formKey.currentState!.validate()) return;

    if (_fotos.isEmpty) {
      setState(() => _erro = 'Adicione pelo menos 1 foto do produto/serviço.');
      return;
    }

    setState(() {
      _carregando = true;
      _erro = null;
      _statusUpload = '';
    });

    try {
      double? preco;
      if (_precoCtrl.text.trim().isNotEmpty) {
        preco = double.tryParse(
          _precoCtrl.text.replaceAll('.', '').replaceAll(',', '.').trim(),
        );
      }

      final anuncioId = await AnunciosService.criarAnuncio(
        titulo: _tituloCtrl.text,
        categoria: _categoria,
        descricao: _descricaoCtrl.text,
        preco: preco,
        fotos: [],
        emailContato: _emailCtrl.text,
        whatsappContato: _whatsCtrl.text,
      );

      final urls = await _fazerUploadFotos(anuncioId);

      await AnunciosService.atualizarFotos(anuncioId, urls);

      if (!mounted) return;

      // ============================================================
      // SUCESSO — volta pro Market
      // (Pagamento Pagar.me vem numa próxima etapa)
      // ============================================================
      await showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: const Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 26),
              SizedBox(width: 10),
              Text('Anúncio enviado!'),
            ],
          ),
          content: const Text(
            'Seu anúncio foi criado com sucesso e está disponível no Market.',
            style: TextStyle(fontSize: 14),
          ),
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricBlue,
                foregroundColor: Colors.white,
              ),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      if (!mounted) return;
      Navigator.pop(context); // volta pro feed
    } catch (e) {
      setState(() => _erro = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) {
        setState(() {
          _carregando = false;
          _statusUpload = '';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Criar Anúncio')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          child: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.gold.withOpacity(0.12),
                              AppColors.gold.withOpacity(0.04),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppColors.gold.withOpacity(0.3),
                          ),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.info_outline,
                                color: AppColors.gold, size: 22),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                'Anúncio por R\$ 97,00 — em breve pagamento direto no checkout.',
                                style: TextStyle(
                                  fontSize: 12.5,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.textDark,
                                  height: 1.4,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Fotos do anúncio',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Adicione até $maxFotos fotos. A primeira será a capa.',
                        style: const TextStyle(
                          fontSize: 11.5,
                          color: AppColors.textGray,
                        ),
                      ),
                      const SizedBox(height: 12),
                      _buildGridFotos(),
                      const SizedBox(height: 24),
                      const Text(
                        'Categoria',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: AnunciosService.categorias.map((cat) {
                          final id = cat['id']!;
                          final sel = _categoria == id;
                          return Material(
                            color: Colors.transparent,
                            child: InkWell(
                              borderRadius: BorderRadius.circular(10),
                              onTap: () => setState(() => _categoria = id),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 12, vertical: 8),
                                decoration: BoxDecoration(
                                  color: sel
                                      ? AppColors.electricBlue
                                      : Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(
                                    color: sel
                                        ? AppColors.electricBlue
                                        : AppColors.borderLight,
                                    width: 1.5,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _iconeCategoria(id),
                                      size: 15,
                                      color: sel
                                          ? Colors.white
                                          : AppColors.electricBlue,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      cat['label']!,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.w700,
                                        color: sel
                                            ? Colors.white
                                            : AppColors.textDark,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _tituloCtrl,
                        maxLength: 80,
                        decoration: const InputDecoration(
                          labelText: 'Título do anúncio',
                          hintText: 'Ex: Vendo fazenda 200 hectares em MG',
                        ),
                        validator: (v) {
                          final t = v?.trim() ?? '';
                          if (t.isEmpty) return 'Campo obrigatório';
                          if (t.length < 10) return 'Título muito curto';
                          if (Validators.contemPalavrao(t)) {
                            return 'Termos não permitidos';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _descricaoCtrl,
                        maxLines: 6,
                        maxLength: 1000,
                        decoration: const InputDecoration(
                          labelText: 'Descrição',
                          hintText: 'Descreva o bem, condições, localização...',
                          alignLabelWithHint: true,
                        ),
                        validator: _validarDescricao,
                      ),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.error.withOpacity(0.06),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: AppColors.error.withOpacity(0.2),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.block_rounded,
                                color: AppColors.error, size: 16),
                            SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                'Proibido: telefone, e-mail, @, palavrões',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.error,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        controller: _precoCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(
                          labelText: 'Preço (opcional)',
                          hintText: 'Ex: 2500000',
                          prefixText: 'R\$ ',
                        ),
                      ),
                      const SizedBox(height: 24),
                      const Text(
                        'Dados de contato (não aparecem na descrição)',
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _emailCtrl,
                        keyboardType: TextInputType.emailAddress,
                        decoration: const InputDecoration(
                          labelText: 'E-mail para contato',
                        ),
                        validator: (v) => Validators.emailProfissional(v),
                      ),
                      const SizedBox(height: 12),
                      TextFormField(
                        controller: _whatsCtrl,
                        keyboardType: TextInputType.phone,
                        inputFormatters: [_whatsMask],
                        decoration: const InputDecoration(
                          labelText: 'WhatsApp para contato',
                        ),
                        validator: (v) => Validators.whatsapp(v),
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
                            style: const TextStyle(
                                color: AppColors.error, fontSize: 13),
                          ),
                        ),
                      ],
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _carregando ? null : _salvar,
                    style: ElevatedButton.styleFrom(
                      minimumSize: const Size(double.infinity, 54),
                    ),
                    child: _carregando
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const SizedBox(
                                height: 18,
                                width: 18,
                                child: CircularProgressIndicator(
                                    color: Colors.white, strokeWidth: 2),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                _statusUpload.isEmpty
                                    ? 'Enviando...'
                                    : _statusUpload,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          )
                        : const Text('Publicar anúncio'),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGridFotos() {
    return GridView.builder(
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
              onTap: _escolherFotos,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.electricBlue.withOpacity(0.4),
                    width: 1.5,
                    style: BorderStyle.solid,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.add_photo_alternate_outlined,
                      size: 28,
                      color: AppColors.electricBlue.withOpacity(0.7),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_fotos.length}/$maxFotos',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.electricBlue.withOpacity(0.7),
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
                child: _buildPreview(foto),
              ),
            ),
            if (isCapa)
              Positioned(
                top: 4,
                left: 4,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.gold,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'CAPA',
                    style: TextStyle(
                      fontSize: 9,
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
                  onTap: () => _removerFoto(i),
                  child: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.7),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.close_rounded,
                      size: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildPreview(PlatformFile foto) {
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
      color: AppColors.electricBlue.withOpacity(0.08),
      child: const Center(
        child: Icon(Icons.image_outlined, size: 30, color: AppColors.textGray),
      ),
    );
  }
}
