import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../routes/app_routes.dart';

class LeadSalvoScreen extends StatelessWidget {
  const LeadSalvoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              Center(
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    color: AppColors.success.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_rounded,
                    size: 56,
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
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'Nossa equipe vai analisar seu perfil e entrar em contato em até 30 dias.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textGray,
                  height: 1.55,
                ),
              ),
              const Spacer(),
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
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
