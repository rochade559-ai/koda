import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../routes/app_routes.dart';

class ConfirmacaoInvestidorScreen extends StatelessWidget {
  const ConfirmacaoInvestidorScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  color: AppColors.success.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.check_circle_outline,
                  size: 64,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 32),
              const Text(
                'Perfil enviado com sucesso!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Você entrou na lista de investidores Kodaff.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textGray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.electricBlue.withOpacity(0.2),
                  ),
                ),
                child: const Column(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: AppColors.electricBlue,
                      size: 28,
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Nossa equipe vai analisar seu perfil e entrar em contato via WhatsApp ou E-mail com as oportunidades mais aderentes ao seu apetite.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: AppColors.textDark,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (route) => false,
                  );
                },
                child: const Text('Voltar ao início'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
