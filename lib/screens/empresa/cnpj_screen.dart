import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/cnpj_service.dart';
import '../../core/services/session.dart';
import '../../routes/app_routes.dart';

class CnpjScreen extends StatefulWidget {
  const CnpjScreen({super.key});

  @override
  State<CnpjScreen> createState() => _CnpjScreenState();
}

class _CnpjScreenState extends State<CnpjScreen> {
  final _cnpjCtrl = TextEditingController();
  final _mask = MaskTextInputFormatter(
    mask: '##.###.###/####-##',
    filter: {'#': RegExp(r'[0-9]')},
  );

  bool _loading = false;
  Map<String, dynamic>? _dados;
  String? _erro;

  @override
  void dispose() {
    _cnpjCtrl.dispose();
    super.dispose();
  }

  Future<void> _validar() async {
    FocusScope.of(context).unfocus();
    final cnpj = _cnpjCtrl.text.replaceAll(RegExp(r'[^0-9]'), '');

    if (cnpj.length != 14) {
      setState(() {
        _erro = 'Digite um CNPJ completo (14 dígitos)';
        _dados = null;
      });
      return;
    }

    setState(() {
      _loading = true;
      _erro = null;
      _dados = null;
    });

    try {
      final dados = await CnpjService.consultar(cnpj);
      final situacao = (dados['descricao_situacao_cadastral'] ?? '')
          .toString()
          .toUpperCase();

      if (situacao != 'ATIVA') {
        setState(() {
          _erro = 'CNPJ não está ATIVO. Situação atual: $situacao';
        });
      } else {
        setState(() => _dados = dados);
        Session.cnpj = cnpj;
        Session.dadosCnpj = dados;
      }
    } catch (e) {
      setState(() => _erro = e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Verificação de CNPJ')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Valide o CNPJ da sua empresa',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Consultamos automaticamente na Receita Federal. Só aceitamos CNPJ ativo.',
                style: TextStyle(color: AppColors.textGray),
              ),
              const SizedBox(height: 24),
              TextField(
                controller: _cnpjCtrl,
                keyboardType: TextInputType.number,
                inputFormatters: [_mask],
                decoration: const InputDecoration(labelText: 'CNPJ'),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: _loading ? null : _validar,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                          strokeWidth: 2,
                        ),
                      )
                    : const Text('Validar CNPJ'),
              ),
              if (_erro != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.error.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.error_outline, color: AppColors.error),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          _erro!,
                          style: const TextStyle(color: AppColors.error),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              if (_dados != null) ...[
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.06),
                    borderRadius: BorderRadius.circular(12),
                    border:
                        Border.all(color: AppColors.success.withOpacity(0.4)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.check_circle, color: AppColors.success),
                          SizedBox(width: 8),
                          Text(
                            'CNPJ ATIVO',
                            style: TextStyle(
                              color: AppColors.success,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      _linha('Razão social', _dados!['razao_social']),
                      _linha('Nome fantasia', _dados!['nome_fantasia']),
                      _linha(
                          'Situação', _dados!['descricao_situacao_cadastral']),
                      _linha('CNAE', _dados!['cnae_fiscal_descricao']),
                      _linha(
                        'Município/UF',
                        '${_dados!['municipio'] ?? ''}/${_dados!['uf'] ?? ''}',
                      ),
                      _linha('Abertura', _dados!['data_inicio_atividade']),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    // ⚠️ MUDANÇA: agora vai para a tela de AVISO
                    Navigator.pushNamed(context, AppRoutes.quizAviso);
                  },
                  child: const Text('Continuar para verificação'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _linha(String label, dynamic valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: RichText(
        text: TextSpan(
          style: const TextStyle(color: AppColors.textDark, fontSize: 14),
          children: [
            TextSpan(
              text: '$label: ',
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            TextSpan(text: (valor ?? '-').toString()),
          ],
        ),
      ),
    );
  }
}
