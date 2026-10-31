import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/session.dart';
import '../../routes/app_routes.dart';

class _FaixaOpcao {
  final String id;
  final String titulo;
  final String valor;
  final String descricao;
  final IconData icone;
  final Color cor;
  final List<Color> gradiente;

  const _FaixaOpcao({
    required this.id,
    required this.titulo,
    required this.valor,
    required this.descricao,
    required this.icone,
    required this.cor,
    required this.gradiente,
  });
}

class FaixaInvestimentoScreen extends StatefulWidget {
  const FaixaInvestimentoScreen({super.key});

  @override
  State<FaixaInvestimentoScreen> createState() =>
      _FaixaInvestimentoScreenState();
}

class _FaixaInvestimentoScreenState extends State<FaixaInvestimentoScreen> {
  // ============================================================
  // AS 4 FAIXAS
  // ============================================================
  static const List<_FaixaOpcao> _faixas = [
    _FaixaOpcao(
      id: 'pequeno',
      titulo: 'Pequeno Porte',
      valor: 'R\$ 50 mil – R\$ 100 mil',
      descricao:
          'Ideal para primeiras rodadas, validação de produto e capital de giro.',
      icone: Icons.rocket_launch_rounded,
      cor: Color(0xFF10B981),
      gradiente: [Color(0xFF10B981), Color(0xFF34D399)],
    ),
    _FaixaOpcao(
      id: 'medio',
      titulo: 'Médio Porte',
      valor: 'R\$ 100 mil – R\$ 500 mil',
      descricao:
          'Para expansão de operação, contratação de time e crescimento acelerado.',
      icone: Icons.trending_up_rounded,
      cor: Color(0xFF2563EB),
      gradiente: [Color(0xFF2563EB), Color(0xFF60A5FA)],
    ),
    _FaixaOpcao(
      id: 'grande',
      titulo: 'Grande Porte',
      valor: 'R\$ 1 milhão – R\$ 20 milhões',
      descricao:
          'Rodadas de crescimento, aquisições e entrada em novos mercados.',
      icone: Icons.account_balance_rounded,
      cor: Color(0xFFD97706),
      gradiente: [Color(0xFFD97706), Color(0xFFFBBF24)],
    ),
    _FaixaOpcao(
      id: 'ouro',
      titulo: 'Nível Ouro',
      valor: 'Acima de R\$ 100 milhões',
      descricao: 'Operações de alto impacto, M&A, IPO e projetos estratégicos.',
      icone: Icons.diamond_rounded,
      cor: Color(0xFF7C3AED),
      gradiente: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
    ),
  ];

  String? _selecionada;

  void _continuar() {
    if (_selecionada == null) return;

    final faixa = _faixas.firstWhere((f) => f.id == _selecionada);

    // Salva na sessão
    Session.faixaInvestimento = faixa.id;
    Session.faixaInvestimentoLabel = '${faixa.titulo} — ${faixa.valor}';

    // Vai para próxima tela (Quiz de Oferta)
    Navigator.pushNamed(context, AppRoutes.quizOferta);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Faixa de Investimento')),
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
                      'Quanto você busca captar?',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Escolha a faixa que melhor representa sua necessidade de capital.',
                      style: TextStyle(
                        fontSize: 15,
                        color: AppColors.textGray,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    ..._faixas.map((f) => Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _CardFaixa(
                            faixa: f,
                            selecionada: _selecionada == f.id,
                            onTap: () => setState(() => _selecionada = f.id),
                          ),
                        )),
                  ],
                ),
              ),
            ),

            // Botão fixo no rodapé
            Padding(
              padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _selecionada == null ? null : _continuar,
                  child: const Text('Continuar'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CARD DE FAIXA
// ============================================================
class _CardFaixa extends StatelessWidget {
  final _FaixaOpcao faixa;
  final bool selecionada;
  final VoidCallback onTap;

  const _CardFaixa({
    required this.faixa,
    required this.selecionada,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: selecionada ? faixa.cor : AppColors.borderLight,
          width: selecionada ? 2 : 1.2,
        ),
        boxShadow: [
          BoxShadow(
            color: selecionada
                ? faixa.cor.withOpacity(0.15)
                : Colors.black.withOpacity(0.03),
            blurRadius: selecionada ? 20 : 10,
            spreadRadius: selecionada ? 2 : 0,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    // Ícone circular colorido
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: faixa.gradiente,
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: faixa.cor.withOpacity(0.3),
                            blurRadius: 12,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Icon(
                        faixa.icone,
                        color: Colors.white,
                        size: 26,
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Título + valor
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            faixa.titulo,
                            style: TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.w800,
                              color:
                                  selecionada ? faixa.cor : AppColors.textDark,
                              letterSpacing: -0.3,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            faixa.valor,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: faixa.cor,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Check
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: 26,
                      height: 26,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: selecionada ? faixa.cor : Colors.transparent,
                        border: Border.all(
                          color: selecionada
                              ? faixa.cor
                              : AppColors.textGray.withOpacity(0.4),
                          width: 1.8,
                        ),
                      ),
                      child: selecionada
                          ? const Icon(Icons.check,
                              size: 16, color: Colors.white)
                          : null,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                Text(
                  faixa.descricao,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppColors.textGray,
                    height: 1.45,
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
