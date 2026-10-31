import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/session.dart';
import '../../routes/app_routes.dart';

class QuizOfertaScreen extends StatefulWidget {
  const QuizOfertaScreen({super.key});

  @override
  State<QuizOfertaScreen> createState() => _QuizOfertaScreenState();
}

class _QuizOfertaScreenState extends State<QuizOfertaScreen> {
  final _formKey = GlobalKey<FormState>();

  double _equity = 10; // valor inicial do slider
  bool _participacaoLucros = false;
  bool _royalties = false;
  bool _assentoConselho = false;
  bool _preferenciaCompra = false;
  String? _valuationFaixa;
  String? _prazoRetorno;

  void _continuar() {
    if (!_formKey.currentState!.validate()) return;

    // Salva na sessão
    Session.equityOferecido = _equity;
    Session.participacaoLucros = _participacaoLucros;
    Session.royalties = _royalties;
    Session.assentoConselho = _assentoConselho;
    Session.preferenciaCompra = _preferenciaCompra;
    Session.valuationFaixa = _valuationFaixa;
    Session.prazoRetorno = _prazoRetorno;

    // Vai para próxima tela (Pitch PDF)
    Navigator.pushNamed(context, AppRoutes.pitchEmpresa);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Oferta ao Investidor')),
      body: SafeArea(
        child: Form(
          key: _formKey,
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
                        'O que você oferece?',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textDark,
                          letterSpacing: -0.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Defina os termos da sua oferta para atrair o investidor certo.',
                        style: TextStyle(
                          fontSize: 15,
                          color: AppColors.textGray,
                          height: 1.5,
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ============================================================
                      // 1. EQUITY — Slider
                      // ============================================================
                      _CardSecao(
                        icone: Icons.pie_chart_rounded,
                        cor: AppColors.electricBlue,
                        titulo: 'Participação acionária (equity)',
                        subtitulo:
                            'Quanto da sua empresa você oferece ao investidor?',
                        child: Column(
                          children: [
                            // Valor grande no centro
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  vertical: 16, horizontal: 24),
                              decoration: BoxDecoration(
                                color: AppColors.electricBlue.withOpacity(0.08),
                                borderRadius: BorderRadius.circular(14),
                              ),
                              child: Column(
                                children: [
                                  Text(
                                    '${_equity.toInt()}%',
                                    style: const TextStyle(
                                      fontSize: 42,
                                      fontWeight: FontWeight.w900,
                                      color: AppColors.electricBlue,
                                      letterSpacing: -1.5,
                                      height: 1,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  const Text(
                                    'da empresa',
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: AppColors.textGray,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Slider
                            SliderTheme(
                              data: SliderTheme.of(context).copyWith(
                                activeTrackColor: AppColors.electricBlue,
                                inactiveTrackColor: AppColors.borderLight,
                                thumbColor: AppColors.electricBlue,
                                overlayColor:
                                    AppColors.electricBlue.withOpacity(0.15),
                                trackHeight: 6,
                                thumbShape: const RoundSliderThumbShape(
                                    enabledThumbRadius: 12),
                              ),
                              child: Slider(
                                value: _equity,
                                min: 1,
                                max: 49,
                                divisions: 48,
                                onChanged: (v) => setState(() => _equity = v),
                              ),
                            ),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 8),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: const [
                                  Text('1%',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textGray)),
                                  Text('25%',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textGray)),
                                  Text('49%',
                                      style: TextStyle(
                                          fontSize: 11,
                                          color: AppColors.textGray)),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'A Kodaff recomenda manter controle majoritário (acima de 51%).',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.textGray,
                                fontStyle: FontStyle.italic,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ============================================================
                      // 2. BENEFÍCIOS ADICIONAIS
                      // ============================================================
                      _CardSecao(
                        icone: Icons.card_giftcard_rounded,
                        cor: AppColors.gold,
                        titulo: 'Benefícios adicionais',
                        subtitulo:
                            'Ofereça algo além do equity para valorizar a proposta.',
                        child: Column(
                          children: [
                            _SwitchBeneficio(
                              titulo: 'Participação nos lucros',
                              descricao:
                                  'O investidor recebe parte dos lucros distribuídos.',
                              icone: Icons.attach_money_rounded,
                              valor: _participacaoLucros,
                              onChanged: (v) =>
                                  setState(() => _participacaoLucros = v),
                            ),
                            const SizedBox(height: 4),
                            _SwitchBeneficio(
                              titulo: 'Royalties',
                              descricao:
                                  '% sobre o faturamento por um período.',
                              icone: Icons.percent_rounded,
                              valor: _royalties,
                              onChanged: (v) => setState(() => _royalties = v),
                            ),
                            const SizedBox(height: 4),
                            _SwitchBeneficio(
                              titulo: 'Assento no conselho',
                              descricao:
                                  'Participação nas decisões estratégicas.',
                              icone: Icons.groups_rounded,
                              valor: _assentoConselho,
                              onChanged: (v) =>
                                  setState(() => _assentoConselho = v),
                            ),
                            const SizedBox(height: 4),
                            _SwitchBeneficio(
                              titulo: 'Preferência de compra futura',
                              descricao:
                                  'Direito de adquirir mais participação em rodadas futuras.',
                              icone: Icons.shopping_cart_checkout_rounded,
                              valor: _preferenciaCompra,
                              onChanged: (v) =>
                                  setState(() => _preferenciaCompra = v),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ============================================================
                      // 3. VALUATION
                      // ============================================================
                      _CardSecao(
                        icone: Icons.assessment_rounded,
                        cor: const Color(0xFF7C3AED),
                        titulo: 'Valuation da empresa',
                        subtitulo:
                            'Quanto vale sua empresa hoje (pré-investimento)?',
                        child: _DropdownOpcao(
                          valor: _valuationFaixa,
                          itens: const [
                            'Até R\$ 500 mil',
                            'R\$ 500 mil – R\$ 2 milhões',
                            'R\$ 2 milhões – R\$ 10 milhões',
                            'R\$ 10 milhões – R\$ 50 milhões',
                            'Acima de R\$ 50 milhões',
                          ],
                          onChanged: (v) => setState(() => _valuationFaixa = v),
                          hint: 'Selecione uma faixa',
                        ),
                      ),

                      const SizedBox(height: 16),

                      // ============================================================
                      // 4. PRAZO DE RETORNO
                      // ============================================================
                      _CardSecao(
                        icone: Icons.schedule_rounded,
                        cor: AppColors.success,
                        titulo: 'Prazo de retorno esperado',
                        subtitulo:
                            'Em quanto tempo o investidor pode esperar retorno?',
                        child: _DropdownOpcao(
                          valor: _prazoRetorno,
                          itens: const [
                            '12 meses',
                            '24 meses',
                            '36 meses',
                            '48 meses',
                            'Acima de 60 meses',
                          ],
                          onChanged: (v) => setState(() => _prazoRetorno = v),
                          hint: 'Selecione um prazo',
                        ),
                      ),

                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // Botão fixo
              Padding(
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _continuar,
                    child: const Text('Continuar'),
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
// CARD DE SEÇÃO
// ============================================================
class _CardSecao extends StatelessWidget {
  final IconData icone;
  final Color cor;
  final String titulo;
  final String subtitulo;
  final Widget child;

  const _CardSecao({
    required this.icone,
    required this.cor,
    required this.titulo,
    required this.subtitulo,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 10,
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
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(icone, color: cor, size: 22),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Text(
                  titulo,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    letterSpacing: -0.2,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Padding(
            padding: const EdgeInsets.only(left: 56),
            child: Text(
              subtitulo,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textGray,
                height: 1.4,
              ),
            ),
          ),
          const SizedBox(height: 18),
          child,
        ],
      ),
    );
  }
}

// ============================================================
// SWITCH DE BENEFÍCIO
// ============================================================
class _SwitchBeneficio extends StatelessWidget {
  final String titulo;
  final String descricao;
  final IconData icone;
  final bool valor;
  final ValueChanged<bool> onChanged;

  const _SwitchBeneficio({
    required this.titulo,
    required this.descricao,
    required this.icone,
    required this.valor,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: valor
            ? AppColors.electricBlue.withOpacity(0.06)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: valor
              ? AppColors.electricBlue.withOpacity(0.3)
              : AppColors.borderLight,
          width: valor ? 1.5 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onChanged(!valor),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            child: Row(
              children: [
                Icon(icone,
                    size: 20,
                    color: valor ? AppColors.electricBlue : AppColors.textGray),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        titulo,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                          color: valor
                              ? AppColors.electricBlue
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
                Switch(
                  value: valor,
                  onChanged: onChanged,
                  activeColor: AppColors.electricBlue,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DROPDOWN CUSTOMIZADO
// ============================================================
class _DropdownOpcao extends StatelessWidget {
  final String? valor;
  final List<String> itens;
  final ValueChanged<String?> onChanged;
  final String hint;

  const _DropdownOpcao({
    required this.valor,
    required this.itens,
    required this.onChanged,
    required this.hint,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String>(
      value: valor,
      isExpanded: true,
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          fontSize: 14,
          color: AppColors.textGray,
        ),
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      ),
      items: itens
          .map((e) => DropdownMenuItem(
              value: e, child: Text(e, style: const TextStyle(fontSize: 14))))
          .toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Selecione uma opção' : null,
    );
  }
}
