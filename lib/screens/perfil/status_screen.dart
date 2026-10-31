import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/admin_service.dart';
import '../../routes/app_routes.dart';

class StatusScreen extends StatelessWidget {
  const StatusScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Scaffold(
        body: Center(child: Text('Faça login para ver o status.')),
      );
    }

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Minha Solicitação'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (route) => false,
              );
            },
            icon: const Icon(Icons.home_outlined),
            tooltip: 'Início',
          ),
        ],
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('leads_empresas')
            .where('uid', isEqualTo: user.uid)
            .orderBy('criado_em', descending: true)
            .limit(1)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(
                color: AppColors.electricBlue,
              ),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text('Erro: ${snapshot.error}'),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];
          if (docs.isEmpty) {
            return const _EstadoVazio();
          }

          final data = docs.first.data() as Map<String, dynamic>;
          return _DetalhesStatus(data: data);
        },
      ),
    );
  }
}

// ============================================================
// ESTADO VAZIO
// ============================================================
class _EstadoVazio extends StatelessWidget {
  const _EstadoVazio();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.inbox_outlined,
                size: 64, color: AppColors.textGray),
            const SizedBox(height: 16),
            const Text(
              'Você ainda não enviou\nnenhuma solicitação',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textGray,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.home,
                (r) => false,
              ),
              child: const Text('Voltar ao início'),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DETALHES DO STATUS
// ============================================================
class _DetalhesStatus extends StatelessWidget {
  final Map<String, dynamic> data;
  const _DetalhesStatus({required this.data});

  @override
  Widget build(BuildContext context) {
    final criadoEm = data['criado_em'] as Timestamp?;
    final status = (data['status'] ?? 'em_analise') as String;

    DateTime? dataCriacao;
    if (criadoEm != null) dataCriacao = criadoEm.toDate();

    final agora = DateTime.now();
    final diasPassados = dataCriacao == null
        ? 0
        : agora.difference(dataCriacao).inDays.clamp(0, 30);
    final diasRestantes = (30 - diasPassados).clamp(0, 30);
    final progresso = diasPassados / 30.0;

    Color corStatus;
    String labelStatus;
    IconData iconeStatus;
    String mensagemStatus;
    switch (status) {
      case 'aprovado':
        corStatus = AppColors.success;
        labelStatus = 'Aprovado';
        iconeStatus = Icons.check_circle_rounded;
        mensagemStatus =
            'Parabéns! Sua solicitação foi aprovada. Nossa equipe entrará em contato em breve.';
        break;
      case 'recusado':
        corStatus = AppColors.error;
        labelStatus = 'Recusado';
        iconeStatus = Icons.cancel_rounded;
        mensagemStatus =
            'Sua solicitação não foi aprovada neste momento. Você pode tentar novamente em outra rodada.';
        break;
      default:
        corStatus = AppColors.warning;
        labelStatus = 'Em análise';
        iconeStatus = Icons.hourglass_top_rounded;
        mensagemStatus =
            'Nossa equipe está analisando cuidadosamente o seu perfil.';
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // ============ HEADER COM STATUS ============
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
              boxShadow: [
                BoxShadow(
                  color: corStatus.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: corStatus.withOpacity(0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(iconeStatus, size: 44, color: corStatus),
                ),
                const SizedBox(height: 16),
                Text(
                  labelStatus,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    color: corStatus,
                    letterSpacing: -0.4,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  mensagemStatus,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 14,
                    color: AppColors.textGray,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ============ CONTADOR DE 30 DIAS ============
          if (status == 'em_analise')
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.borderLight),
              ),
              child: Column(
                children: [
                  // Números grandes
                  Row(
                    children: [
                      Expanded(
                        child: _ContadorBox(
                          label: 'Enviado há',
                          valor: '$diasPassados',
                          unidade: diasPassados == 1 ? 'dia' : 'dias',
                          cor: AppColors.textGray,
                        ),
                      ),
                      Container(
                        width: 1,
                        height: 50,
                        color: AppColors.borderLight,
                      ),
                      Expanded(
                        child: _ContadorBox(
                          label: 'Restam',
                          valor: '$diasRestantes',
                          unidade: diasRestantes == 1 ? 'dia' : 'dias',
                          cor: AppColors.electricBlue,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Barra de progresso
                  ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      value: progresso.clamp(0.0, 1.0),
                      minHeight: 10,
                      backgroundColor: AppColors.borderLight,
                      valueColor: const AlwaysStoppedAnimation(
                        AppColors.electricBlue,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Legenda
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Início',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        '${(progresso * 100).toInt()}% concluído',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.electricBlue,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        'Resposta',
                        style: TextStyle(
                          fontSize: 11,
                          color: AppColors.textGray,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

          const SizedBox(height: 20),

          // ============ DADOS DA SOLICITAÇÃO ============
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Dados da solicitação',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 14),
                _linha('Responsável', data['nome_responsavel']),
                _linha('Cargo', data['cargo']),
                _linha('E-mail', data['email']),
                _linha('WhatsApp', data['whatsapp']),
                _linha('CNPJ', data['cnpj']),
                _linha('Faixa', data['faixa_label']),
                _linha(
                  'Equity oferecido',
                  data['equity_oferecido'] != null
                      ? '${(data['equity_oferecido'] as num).toInt()}%'
                      : null,
                ),
                _linha('Valuation', data['valuation_faixa']),
                _linha('Prazo', data['prazo_retorno']),
                _linha('Pitch deck', data['pitch_nome']),
              ],
            ),
          ),

          const SizedBox(height: 20),

          // ============ SUPORTE ============
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Row(
              children: [
                Icon(Icons.support_agent_outlined,
                    color: AppColors.electricBlue, size: 22),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Dúvidas? Fale com a gente pelo WhatsApp ou e-mail de suporte.',
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

          const SizedBox(height: 24),

          // ============ BOTÃO HOME ============
          OutlinedButton.icon(
            onPressed: () => Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.home,
              (r) => false,
            ),
            icon: const Icon(Icons.home_rounded, size: 18),
            label: const Text('Voltar ao início'),
            style: OutlinedButton.styleFrom(
              minimumSize: const Size(double.infinity, 52),
              side: const BorderSide(color: AppColors.borderLight, width: 1.5),
              foregroundColor: AppColors.textDark,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _linha(String label, dynamic valor) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 5),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 130,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textGray,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              (valor ?? '-').toString(),
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textDark,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// BOX DE CONTADOR
// ============================================================
class _ContadorBox extends StatelessWidget {
  final String label;
  final String valor;
  final String unidade;
  final Color cor;

  const _ContadorBox({
    required this.label,
    required this.valor,
    required this.unidade,
    required this.cor,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: AppColors.textGray,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(
              valor,
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: cor,
                height: 1,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              unidade,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: cor,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
