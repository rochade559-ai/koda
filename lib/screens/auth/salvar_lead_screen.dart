import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/firestore_service.dart';
import '../../routes/app_routes.dart';

class SalvarLeadScreen extends StatefulWidget {
  final String tipo;
  final Map<String, dynamic>? respostas;
  const SalvarLeadScreen({
    super.key,
    this.tipo = 'empresa',
    this.respostas,
  });

  @override
  State<SalvarLeadScreen> createState() => _SalvarLeadScreenState();
}

class _SalvarLeadScreenState extends State<SalvarLeadScreen> {
  bool _salvando = false;
  bool _salvo = false;
  String? _erro;

  // ============================================================
  // SALVAR O LEAD
  // ============================================================
  Future<void> _salvarLead() async {
    if (_salvando || _salvo) return;

    setState(() {
      _salvando = true;
      _erro = null;
    });

    try {
      if (widget.tipo == 'empresa') {
        await FirestoreService.salvarLeadEmpresa()
            .timeout(const Duration(seconds: 15));
      } else {
        await FirestoreService.salvarLeadInvestidor(
          respostas: widget.respostas ?? {},
        ).timeout(const Duration(seconds: 15));
      }

      if (!mounted) return;
      setState(() {
        _salvando = false;
        _salvo = true;
      });

      // Vai para a confirmação
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.confirmacaoEmpresa,
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _salvando = false;
        _erro = e.toString().replaceFirst('Exception: ', '');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        final user = snapshot.data;
        final logado = user != null;

        // Se logou agora → salva automaticamente
        if (logado && !_salvo && !_salvando && _erro == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            _salvarLead();
          });
        }

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
                      width: 88,
                      height: 88,
                      decoration: BoxDecoration(
                        color: AppColors.success.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle_outline,
                        size: 48,
                        color: AppColors.success,
                      ),
                    ),
                  ),
                  const SizedBox(height: 28),

                  const Text(
                    'Verificação concluída!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      height: 1.25,
                    ),
                  ),
                  const SizedBox(height: 12),

                  Text(
                    logado
                        ? 'Estamos salvando sua solicitação...'
                        : 'Para salvar sua solicitação e acompanhar o status em tempo real, crie sua conta Kodaff.',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 15,
                      color: AppColors.textGray,
                      height: 1.55,
                    ),
                  ),

                  // ============ ERRO ============
                  if (_erro != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.error.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(
                          color: AppColors.error.withOpacity(0.3),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline,
                              color: AppColors.error, size: 20),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              _erro!,
                              style: const TextStyle(
                                  color: AppColors.error, fontSize: 13),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: _salvarLead,
                      icon: const Icon(Icons.refresh_rounded, size: 18),
                      label: const Text('Tentar novamente'),
                      style: TextButton.styleFrom(
                        foregroundColor: AppColors.electricBlue,
                      ),
                    ),
                  ],

                  const Spacer(),

                  // ============ AÇÕES ============
                  if (_salvando)
                    // Salvando
                    Center(
                      child: Column(
                        children: [
                          const SizedBox(
                            height: 32,
                            width: 32,
                            child: CircularProgressIndicator(
                              color: AppColors.electricBlue,
                              strokeWidth: 3,
                            ),
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Salvando sua solicitação...',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.textGray,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    )
                  else if (!logado) ...[
                    // Não logado → mostra botões
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.cadastroConta,
                          arguments: widget.tipo,
                        );
                      },
                      child: const Text('Criar conta e salvar'),
                    ),
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        Navigator.pushNamed(
                          context,
                          AppRoutes.login,
                        );
                      },
                      child: const Text(
                        'Já tenho conta — Entrar',
                        style: TextStyle(color: AppColors.textGray),
                      ),
                    ),
                  ],

                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
