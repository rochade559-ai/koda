import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../routes/app_routes.dart';

class QuizBloqueadoScreen extends StatelessWidget {
  final int diasRestantes;
  const QuizBloqueadoScreen({super.key, required this.diasRestantes});

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
                  color: AppColors.error.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_clock_rounded,
                  size: 56,
                  color: AppColors.error,
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Acesso temporariamente bloqueado',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Você não passou na verificação de perfil da empresa. '
                'Para preservar a qualidade das oportunidades Kodaff, '
                'novas tentativas com este nome e CNPJ só serão permitidas em:',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14,
                  color: AppColors.textGray,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 24),

              // Contador de dias
              Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 24, horizontal: 20),
                decoration: BoxDecoration(
                  color: AppColors.error.withOpacity(0.05),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.error.withOpacity(0.25),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      '$diasRestantes',
                      style: const TextStyle(
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        color: AppColors.error,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      diasRestantes == 1 ? 'dia restante' : 'dias restantes',
                      style: const TextStyle(
                        fontSize: 14,
                        color: AppColors.textGray,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.electricBlue.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: AppColors.electricBlue, size: 20),
                    SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Se você é um empresário sério e acha que houve um engano, entre em contato pelo nosso canal de suporte.',
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
