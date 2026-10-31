import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../routes/app_routes.dart';

class QuizAvisoScreen extends StatelessWidget {
  const QuizAvisoScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Análise de Perfil')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),

              // Ícone central
              Center(
                child: Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppColors.electricBlue.withOpacity(0.08),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.verified_user_outlined,
                    size: 44,
                    color: AppColors.electricBlue,
                  ),
                ),
              ),

              const SizedBox(height: 28),

              // Título
              const Text(
                'Vamos iniciar a análise\ndo seu perfil',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                  height: 1.25,
                  letterSpacing: -0.4,
                ),
              ),

              const SizedBox(height: 16),

              // Subtítulo
              const Text(
                'Para seguirmos, precisamos confirmar que você é o responsável legal ou representante autorizado da empresa.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: AppColors.textGray,
                  height: 1.55,
                ),
              ),

              const Spacer(),

              // Botão principal
              ElevatedButton(
                onPressed: () {
                  Navigator.pushNamed(context, AppRoutes.quizEmpresa);
                },
                child: const Text('Confirmo e quero continuar'),
              ),
              const SizedBox(height: 12),

              // Botão voltar
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text(
                  'Voltar',
                  style: TextStyle(color: AppColors.textGray),
                ),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}
