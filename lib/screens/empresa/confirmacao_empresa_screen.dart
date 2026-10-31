import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/session.dart';
import '../../routes/app_routes.dart';

class ConfirmacaoEmpresaScreen extends StatelessWidget {
  const ConfirmacaoEmpresaScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.check_circle_outline,
                    size: 60,
                    color: AppColors.success,
                  ),
                ),
              ),
              const SizedBox(height: 28),
              const Text(
                'Solicitação enviada!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Nossa equipe vai analisar seu perfil com atenção. Você receberá uma resposta em até 30 dias.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textGray,
                  height: 1.55,
                ),
              ),
              const SizedBox(height: 32),
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
                      'Resumo da solicitação',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(height: 14),
                    _linha('Responsável', Session.nomeResponsavel),
                    _linha('E-mail', Session.email),
                    _linha('CNPJ', Session.cnpj),
                    _linha('Faixa', Session.faixaInvestimentoLabel),
                    _linha(
                      'Equity oferecido',
                      Session.equityOferecido != null
                          ? '${Session.equityOferecido!.toInt()}%'
                          : '-',
                    ),
                    _linha('Valuation', Session.valuationFaixa),
                    _linha('Prazo de retorno', Session.prazoRetorno),
                    _linha(
                      'Pitch deck',
                      Session.pitchNomeArquivo ?? 'Não enviado',
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.electricBlue.withOpacity(0.2),
                  ),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.electricBlue, size: 22),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Acompanhe o status da sua solicitação em tempo real na tela de perfil.',
                        style: TextStyle(
                          fontSize: 13,
                          color: AppColors.textDark,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 28),
              ElevatedButton.icon(
                onPressed: () {
                  Session.limpar();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.status,
                    (route) => false,
                  );
                },
                icon: const Icon(Icons.receipt_long_rounded, size: 20),
                label: const Text('Acompanhar minha solicitação'),
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 56),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Session.limpar();
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                },
                child: const Text(
                  'Voltar ao início',
                  style: TextStyle(
                    color: AppColors.textGray,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
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
