import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/quiz_guard.dart';
import '../../core/services/session.dart';
import '../../routes/app_routes.dart';

class _Pergunta {
  final String texto;
  final List<String> opcoes;
  final int correta;
  const _Pergunta({
    required this.texto,
    required this.opcoes,
    required this.correta,
  });
}

class QuizEmpresaScreen extends StatefulWidget {
  const QuizEmpresaScreen({super.key});

  @override
  State<QuizEmpresaScreen> createState() => _QuizEmpresaScreenState();
}

class _QuizEmpresaScreenState extends State<QuizEmpresaScreen> {
  // ============================================================
  // BANCO DE PERGUNTAS
  // ============================================================
  static const List<_Pergunta> _perguntas = [
    _Pergunta(
      texto: 'O que é a Nota Fiscal Eletrônica (NF-e) para uma empresa?',
      opcoes: [
        'Um documento digital que registra vendas e prestação de serviços',
        'Um e-mail de cobrança que a empresa envia ao cliente',
        'Um comprovante de pagamento gerado pelo banco',
        'Uma música que a Receita Federal toca quando você deve imposto',
      ],
      correta: 0,
    ),
    _Pergunta(
      texto: 'O que significa a sigla CNPJ?',
      opcoes: [
        'Cadastro Nacional da Pessoa Jurídica',
        'Certificado Nacional de Pagamento de Impostos',
        'Código Numérico de Pessoa Jurídica',
        'Cartão Nacional de Pobreza Jurídica',
      ],
      correta: 0,
    ),
    _Pergunta(
      texto: 'Para que serve o capital de giro em uma empresa?',
      opcoes: [
        'Cobrir despesas do dia a dia e manter a operação funcionando',
        'Comprar ações na bolsa de valores com o dinheiro da empresa',
        'Pagar exclusivamente o salário do dono',
        'Girar um capital no ar como um pião colorido',
      ],
      correta: 0,
    ),
    _Pergunta(
      texto: 'Como se calcula, de forma básica, o lucro de uma empresa?',
      opcoes: [
        'Receitas menos despesas e custos',
        'Somando tudo que entrou no caixa, sem descontar nada',
        'Multiplicando o faturamento por dois',
        'Perguntando ao contador quanto "sobrou no bolso"',
      ],
      correta: 0,
    ),
    _Pergunta(
      texto: 'Qual dessas opções NÃO é um regime tributário brasileiro?',
      opcoes: [
        'Simples Nacional',
        'Lucro Presumido',
        'Lucro Real',
        'Lucro Imaginário',
      ],
      correta: 3,
    ),
    _Pergunta(
      texto: 'No mundo dos negócios, o que significa CAC?',
      opcoes: [
        'Custo de Aquisição de Cliente',
        'Comissão de Ajuste Comercial',
        'Cadastro de Atendimento ao Cliente',
        'Café, Água e Chinelo para a equipe',
      ],
      correta: 0,
    ),
    _Pergunta(
      texto: 'O que é o Contrato Social de uma empresa?',
      opcoes: [
        'Documento que define sócios, capital e regras da sociedade',
        'Um contrato assinado individualmente com cada cliente',
        'Um acordo verbal entre amigos sócios',
        'Um pacto de sangue entre os fundadores',
      ],
      correta: 0,
    ),
    _Pergunta(
      texto: 'O que significa a sigla MEI?',
      opcoes: [
        'Microempreendedor Individual',
        'Ministério Empresarial de Investimentos',
        'Modelo Empresarial Inovador',
        'Meu Emprego Ideal',
      ],
      correta: 0,
    ),
  ];

  static const int _maxErros = 2;

  int _index = 0;
  int _erros = 0;
  int? _selecionada;
  bool _verificando = true;

  @override
  void initState() {
    super.initState();
    _checarBloqueio();
  }

  // ============================================================
  // BLOQUEIO POR EMAIL + CNPJ
  // ============================================================
  Future<void> _checarBloqueio() async {
    final email = Session.email ?? '';
    final cnpj = Session.cnpj ?? '';

    final bloqueado = await QuizGuard.isBlocked(email, cnpj);
    if (!mounted) return;

    if (bloqueado) {
      final dias = await QuizGuard.diasRestantes(email, cnpj);
      if (!mounted) return;
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.quizBloqueado,
        arguments: dias,
      );
      return;
    }

    setState(() => _verificando = false);
  }

  void _confirmar() {
    if (_selecionada == null) return;

    final pergunta = _perguntas[_index];
    final acertou = _selecionada == pergunta.correta;

    if (!acertou) _erros++;

    // Reprovacao automatica
    if (_erros >= _maxErros) {
      _reprovar();
      return;
    }

    // Próxima pergunta ou finalizar (SEM feedback visual)
    if (_index < _perguntas.length - 1) {
      setState(() {
        _index++;
        _selecionada = null;
      });
    } else {
      _aprovar();
    }
  }

  Future<void> _reprovar() async {
    await QuizGuard.bloquear(
      Session.email ?? '',
      Session.cnpj ?? '',
    );
    if (!mounted) return;
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.quizBloqueado,
      arguments: 3,
    );
  }

  // ============================================================
  // APROVADO → Vai para tela de Salvar Lead (criar conta)
  // ============================================================
  void _aprovar() {
    Navigator.pushReplacementNamed(
      context,
      AppRoutes.salvarLead,
      arguments: {'tipo': 'empresa'},
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_verificando) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppColors.electricBlue),
        ),
      );
    }

    final pergunta = _perguntas[_index];
    final progresso = (_index + 1) / _perguntas.length;

    // ============================================================
    // PopScope BLOQUEIA o botão de voltar (Android/iOS)
    // ============================================================
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        // Ignora tentativas de voltar
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        // AppBar SEM botão de voltar
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: Text('Verificação — ${_index + 1}/${_perguntas.length}'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              // Barra de progresso + contador de erros
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 0),
                child: Column(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: progresso,
                        minHeight: 6,
                        backgroundColor: AppColors.borderLight,
                        valueColor: const AlwaysStoppedAnimation(
                          AppColors.electricBlue,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        const Icon(Icons.shield_outlined,
                            size: 16, color: AppColors.textGray),
                        const SizedBox(width: 6),
                        Text(
                          'Erros: $_erros / $_maxErros',
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: _erros == 0
                                ? AppColors.textGray
                                : AppColors.error,
                          ),
                        ),
                        const Spacer(),
                        const Text(
                          'Anti-curioso',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              // Corpo
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: 12),
                      Text(
                        pergunta.texto,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 24),
                      ...List.generate(pergunta.opcoes.length, (i) {
                        final sel = _selecionada == i;
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 12),
                          child: _Opcao(
                            texto: pergunta.opcoes[i],
                            selecionada: sel,
                            onTap: () => setState(() => _selecionada = i),
                          ),
                        );
                      }),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: _selecionada == null ? null : _confirmar,
                        child: Text(
                          _index == _perguntas.length - 1
                              ? 'Finalizar verificação'
                              : 'Confirmar resposta',
                        ),
                      ),
                    ],
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

// ============================================================
// CARD DE OPÇÃO (sem feedback verde/vermelho)
// ============================================================
class _Opcao extends StatelessWidget {
  final String texto;
  final bool selecionada;
  final VoidCallback onTap;

  const _Opcao({
    required this.texto,
    required this.selecionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      decoration: BoxDecoration(
        color: selecionada
            ? AppColors.electricBlue.withOpacity(0.08)
            : Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: selecionada ? AppColors.electricBlue : AppColors.borderLight,
          width: selecionada ? 2 : 1.2,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            child: Row(
              children: [
                Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: selecionada
                        ? AppColors.electricBlue
                        : Colors.transparent,
                    border: Border.all(
                      color: selecionada
                          ? AppColors.electricBlue
                          : AppColors.textGray.withOpacity(0.5),
                      width: 1.6,
                    ),
                  ),
                  child: selecionada
                      ? const Icon(Icons.check, size: 14, color: Colors.white)
                      : null,
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    texto,
                    style: TextStyle(
                      fontSize: 14.5,
                      color: AppColors.textDark,
                      height: 1.35,
                      fontWeight:
                          selecionada ? FontWeight.w600 : FontWeight.w400,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
