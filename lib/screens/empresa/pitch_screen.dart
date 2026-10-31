import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io' show File;
import 'package:flutter/foundation.dart' show kIsWeb;

import '../../core/constants/app_colors.dart';
import '../../core/services/session.dart';
import '../../routes/app_routes.dart';

class PitchScreen extends StatefulWidget {
  const PitchScreen({super.key});

  @override
  State<PitchScreen> createState() => _PitchScreenState();
}

class _PitchScreenState extends State<PitchScreen> {
  PlatformFile? _arquivoSelecionado;
  bool _enviando = false;
  double _progresso = 0;
  String? _erro;

  // ============================================================
  // SELECIONAR PDF
  // ============================================================
  Future<void> _selecionarPdf() async {
    try {
      final resultado = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf'],
        withData: true,
      );

      if (resultado == null || resultado.files.isEmpty) return;

      final arquivo = resultado.files.first;

      if (arquivo.size > 10 * 1024 * 1024) {
        setState(() => _erro = 'O arquivo é muito grande. Limite: 10 MB.');
        return;
      }

      setState(() {
        _arquivoSelecionado = arquivo;
        _erro = null;
      });
    } catch (e) {
      setState(() => _erro = 'Erro ao selecionar o arquivo.');
    }
  }

  // ============================================================
  // IR PARA SALVAR LEAD
  // ============================================================
  void _irParaSalvarLead() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.salvarLead,
      arguments: {'tipo': 'empresa'},
    );
  }

  // ============================================================
  // FAZER UPLOAD NO FIREBASE STORAGE
  // ============================================================
  Future<void> _fazerUpload() async {
    if (_arquivoSelecionado == null) return;

    final user = FirebaseAuth.instance.currentUser;

    // Se NÃO estiver logado, pula o upload e vai direto pro SalvarLead
    if (user == null) {
      Session.pitchNomeArquivo = _arquivoSelecionado!.name;
      _irParaSalvarLead();
      return;
    }

    setState(() {
      _enviando = true;
      _erro = null;
      _progresso = 0;
    });

    try {
      final nomeLimpo =
          _arquivoSelecionado!.name.replaceAll(RegExp(r'[^a-zA-Z0-9._-]'), '_');
      final path =
          'pitch/${user.uid}/${DateTime.now().millisecondsSinceEpoch}_$nomeLimpo';

      final ref = FirebaseStorage.instance.ref(path);

      final uploadTask = kIsWeb
          ? ref.putData(_arquivoSelecionado!.bytes!)
          : ref.putFile(File(_arquivoSelecionado!.path!));

      uploadTask.snapshotEvents.listen((snapshot) {
        if (snapshot.totalBytes > 0) {
          setState(() {
            _progresso = snapshot.bytesTransferred / snapshot.totalBytes;
          });
        }
      });

      final snapshot = await uploadTask;
      final url = await snapshot.ref.getDownloadURL();

      Session.pitchNomeArquivo = _arquivoSelecionado!.name;
      Session.pitchUrl = url;

      if (!mounted) return;
      _irParaSalvarLead();
    } catch (e) {
      setState(() =>
          _erro = 'Erro ao enviar o arquivo. Você pode continuar sem o pitch.');
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  // ============================================================
  // PULAR (opcional)
  // ============================================================
  void _pular() {
    Session.pitchNomeArquivo = null;
    Session.pitchUrl = null;
    _irParaSalvarLead();
  }

  void _removerArquivo() {
    setState(() {
      _arquivoSelecionado = null;
      _erro = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Pitch Deck'),
        actions: [
          TextButton(
            onPressed: _enviando ? null : _pular,
            child: const Text(
              'Pular',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 8),
                    const Text(
                      'Envie seu pitch deck',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Apresente seu negócio em poucas páginas. Aumenta muito suas chances de ser selecionado. (Opcional)',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textGray,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 32),
                    if (_arquivoSelecionado == null)
                      _buildAreaUpload()
                    else
                      _buildArquivoSelecionado(),
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
                    const SizedBox(height: 24),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.electricBlue.withOpacity(0.06),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: AppColors.electricBlue.withOpacity(0.2),
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Row(
                            children: [
                              Icon(Icons.tips_and_updates_outlined,
                                  color: AppColors.electricBlue, size: 20),
                              SizedBox(width: 8),
                              Text(
                                'O que incluir no pitch',
                                style: TextStyle(
                                  fontWeight: FontWeight.w800,
                                  color: AppColors.electricBlue,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12),
                          _Dica(texto: 'Problema e solução'),
                          _Dica(texto: 'Mercado e oportunidade'),
                          _Dica(texto: 'Modelo de negócio'),
                          _Dica(texto: 'Tração e resultados'),
                          _Dica(texto: 'Time e diferenciais'),
                          _Dica(texto: 'Como usará o investimento'),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _enviando
                      ? null
                      : (_arquivoSelecionado == null ? _pular : _fazerUpload),
                  child: _enviando
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
                              'Enviando... ${(_progresso * 100).toInt()}%',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ],
                        )
                      : Text(_arquivoSelecionado == null
                          ? 'Continuar sem pitch'
                          : 'Enviar e continuar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAreaUpload() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 40, horizontal: 24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.electricBlue.withOpacity(0.3),
          width: 1.8,
          style: BorderStyle.solid,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _selecionarPdf,
          child: Column(
            children: [
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.upload_file_rounded,
                  size: 36,
                  color: AppColors.electricBlue,
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Toque para escolher o PDF',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 6),
              const Text(
                'Formato PDF • Máximo 10 MB',
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textGray,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildArquivoSelecionado() {
    final arquivo = _arquivoSelecionado!;
    final tamanhoMB = (arquivo.size / (1024 * 1024)).toStringAsFixed(2);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.success.withOpacity(0.4),
          width: 1.8,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.success.withOpacity(0.08),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.error.withOpacity(0.1),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.picture_as_pdf_rounded,
              color: AppColors.error,
              size: 28,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  arquivo.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '$tamanhoMB MB',
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _enviando ? null : _removerArquivo,
            icon: const Icon(Icons.close_rounded, color: AppColors.textGray),
            tooltip: 'Remover',
          ),
        ],
      ),
    );
  }
}

class _Dica extends StatelessWidget {
  final String texto;
  const _Dica({required this.texto});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 6, right: 8),
            child: Icon(Icons.circle, size: 6, color: AppColors.electricBlue),
          ),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textDark,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
