import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../routes/app_routes.dart';

class QuizInvestidorScreen extends StatefulWidget {
  const QuizInvestidorScreen({super.key});

  @override
  State<QuizInvestidorScreen> createState() => _QuizInvestidorScreenState();
}

class _QuizInvestidorScreenState extends State<QuizInvestidorScreen> {
  final _formKey = GlobalKey<FormState>();

  String? _perfil;
  String? _ticket;
  String? _participacao;
  String? _tipoSmartMoney;
  String? _jaInvestiu;
  String? _aportesAno;
  String? _geografia;

  final Set<String> _setoresSelecionados = {};

  final List<String> _setoresDisponiveis = [
    'Tecnologia',
    'Saúde',
    'Varejo',
    'Indústria',
    'Serviços',
    'Alimentos e Bebidas',
    'Educação',
    'Imobiliário',
    'Agronegócio',
    'Energia',
    'Financeiro / Fintech',
    'Logística',
  ];

  // ============================================================
  // FINALIZAR → Salva todas as respostas e vai para tela de conta
  // ============================================================
  void _finalizar() {
    if (!_formKey.currentState!.validate()) return;
    if (_setoresSelecionados.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Selecione pelo menos 1 setor de interesse')),
      );
      return;
    }

    // Passa todas as respostas para a tela de Salvar Lead
    final respostas = {
      'perfil': _perfil,
      'ticket': _ticket,
      'participacao': _participacao,
      'tipo_smart_money': _tipoSmartMoney,
      'setores': _setoresSelecionados.toList(),
      'ja_investiu': _jaInvestiu,
      'aportes_ano': _aportesAno,
      'geografia': _geografia,
    };

    Navigator.pushReplacementNamed(
      context,
      AppRoutes.salvarLead,
      arguments: {'tipo': 'investidor', 'respostas': respostas},
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil do Investidor')),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Text(
                  'Conte-nos sobre o seu perfil',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Queremos entender seu apetite e preferências para conectar você às oportunidades certas.',
                  style: TextStyle(color: AppColors.textGray),
                ),
                const SizedBox(height: 32),
                _dropdown(
                  label: 'Qual o seu perfil de investidor?',
                  value: _perfil,
                  items: const [
                    'Investidor Anjo',
                    'Venture Capital (VC)',
                    'Private Equity (PE)',
                    'Family Office',
                    'Corporate VC (CVC)',
                    'Investidor Individual',
                  ],
                  onChanged: (v) => setState(() => _perfil = v),
                ),
                const SizedBox(height: 20),
                _dropdown(
                  label: 'Qual o ticket que você pretende investir?',
                  value: _ticket,
                  items: const [
                    'R\$ 50 mil – R\$ 100 mil',
                    'R\$ 100 mil – R\$ 500 mil',
                    'R\$ 1 milhão – R\$ 20 milhões',
                    'Acima de R\$ 100 milhões',
                  ],
                  onChanged: (v) => setState(() => _ticket = v),
                ),
                const SizedBox(height: 20),
                _dropdown(
                  label: 'Que tipo de participação você prefere?',
                  value: _participacao,
                  items: const [
                    'Minoritário (até 49%)',
                    'Majoritário (acima de 50%)',
                    'Depende da oportunidade',
                  ],
                  onChanged: (v) => setState(() => _participacao = v),
                ),
                const SizedBox(height: 20),
                _dropdown(
                  label: 'Que tipo de smart money você oferece?',
                  value: _tipoSmartMoney,
                  items: const [
                    'Capital + Mentoria + Networking',
                    'Apenas capital',
                    'Capital + Mentoria',
                    'Capital + Networking',
                  ],
                  onChanged: (v) => setState(() => _tipoSmartMoney = v),
                ),
                const SizedBox(height: 28),
                const Text(
                  'Setores de interesse',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Selecione pelo menos 1',
                  style: TextStyle(fontSize: 13, color: AppColors.textGray),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _setoresDisponiveis.map((setor) {
                    final sel = _setoresSelecionados.contains(setor);
                    return FilterChip(
                      label: Text(setor),
                      selected: sel,
                      selectedColor: AppColors.electricBlue.withOpacity(0.15),
                      checkmarkColor: AppColors.electricBlue,
                      labelStyle: TextStyle(
                        color:
                            sel ? AppColors.electricBlue : AppColors.textDark,
                        fontWeight: sel ? FontWeight.bold : FontWeight.normal,
                      ),
                      onSelected: (v) {
                        setState(() {
                          if (v) {
                            _setoresSelecionados.add(setor);
                          } else {
                            _setoresSelecionados.remove(setor);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 28),
                _dropdown(
                  label: 'Você já investiu em empresas antes?',
                  value: _jaInvestiu,
                  items: const [
                    'Sim, várias vezes',
                    'Sim, algumas vezes',
                    'Não, seria a primeira',
                  ],
                  onChanged: (v) => setState(() => _jaInvestiu = v),
                ),
                const SizedBox(height: 20),
                _dropdown(
                  label: 'Quantos aportes pretende fazer por ano?',
                  value: _aportesAno,
                  items: const ['1 a 2', '3 a 5', '6 a 10', 'Mais de 10'],
                  onChanged: (v) => setState(() => _aportesAno = v),
                ),
                const SizedBox(height: 20),
                _dropdown(
                  label: 'Preferência geográfica',
                  value: _geografia,
                  items: const [
                    'Brasil',
                    'América Latina',
                    'Global',
                    'Sem preferência',
                  ],
                  onChanged: (v) => setState(() => _geografia = v),
                ),
                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _finalizar,
                  child: const Text('Enviar perfil'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _dropdown({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
  }) {
    return DropdownButtonFormField<String>(
      decoration: InputDecoration(labelText: label),
      value: value,
      isExpanded: true,
      items:
          items.map((e) => DropdownMenuItem(value: e, child: Text(e))).toList(),
      onChanged: onChanged,
      validator: (v) => v == null ? 'Selecione uma opção' : null,
    );
  }
}
