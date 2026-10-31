import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/crypton_service.dart';
import '../../models/carteira.dart';
import '../../routes/app_routes.dart';

class ComprarCryptonsScreen extends StatefulWidget {
  const ComprarCryptonsScreen({super.key});

  @override
  State<ComprarCryptonsScreen> createState() => _ComprarCryptonsScreenState();
}

class _ComprarCryptonsScreenState extends State<ComprarCryptonsScreen> {
  bool _carregando = true;
  bool _processando = false;
  String? _erro;
  List<PacoteCrypton> _pacotes = [];

  @override
  void initState() {
    super.initState();
    _carregarPacotes();
  }

  Future<void> _carregarPacotes() async {
    try {
      final lista = await CryptonService.listarPacotes();
      if (!mounted) return;
      setState(() {
        _pacotes = lista;
        _carregando = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _erro = e.toString().replaceFirst('Exception: ', '');
        _carregando = false;
      });
    }
  }

  Future<void> _comprar(PacoteCrypton pacote) async {
    final user = AuthService.usuarioAtual;
    if (user == null) {
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }

    setState(() => _processando = true);

    try {
      final resultado = await CryptonService.criarLinkPagamento(
        pacoteId: pacote.id,
      );

      if (!mounted) return;

      final url = resultado['checkoutUrl'] as String;
      final uri = Uri.parse(url);

      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        throw Exception('Não foi possível abrir o checkout.');
      }

      if (!mounted) return;
      Navigator.pushNamed(
        context,
        AppRoutes.carteira,
        arguments: {'atualizar': true},
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Erro: ${e.toString().replaceFirst('Exception: ', '')}'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _processando = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Comprar Cryptons')),
      body: SafeArea(
        child: _carregando
            ? const Center(
                child: CircularProgressIndicator(color: AppColors.electricBlue),
              )
            : _erro != null
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(_erro!, textAlign: TextAlign.center),
                    ),
                  )
                : SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // Header
                        Container(
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: const Column(
                            children: [
                              Icon(Icons.monetization_on_rounded,
                                  color: Colors.white, size: 44),
                              SizedBox(height: 8),
                              Text(
                                'Token Crypton Koda Vip',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: -0.3,
                                ),
                              ),
                              SizedBox(height: 6),
                              Text(
                                'Use Cryptons para desbloquear contatos e acelerar seus negocios.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 13,
                                  height: 1.4,
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 16),

                        // Info
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
                                  'Cada desbloqueio de contato custa 25 Cryptons.',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: AppColors.textDark,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(height: 20),

                        // Pacotes
                        ..._pacotes.map((p) => _CardPacote(
                              pacote: p,
                              onTap: _processando ? null : () => _comprar(p),
                            )),

                        const SizedBox(height: 24),

                        const Center(
                          child: Text(
                            'Pagamento processado pelo Stripe',
                            style: TextStyle(
                              fontSize: 11,
                              color: AppColors.textLight,
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

class _CardPacote extends StatelessWidget {
  final PacoteCrypton pacote;
  final VoidCallback? onTap;

  const _CardPacote({required this.pacote, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isPopular = pacote.id == 'popular';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Stack(
        children: [
          Material(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: onTap,
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: isPopular ? AppColors.gold : AppColors.borderLight,
                    width: isPopular ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 60,
                      height: 60,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${pacote.cryptons}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                height: 1,
                              ),
                            ),
                            const Text(
                              'CRYPT',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 8,
                                fontWeight: FontWeight.w800,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            pacote.nome,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            pacote.descricao,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.textGray,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'R\$ ${pacote.preco.toStringAsFixed(2).replaceAll('.', ',')}',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w900,
                              color: AppColors.gold,
                              letterSpacing: -0.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios_rounded,
                        size: 14, color: AppColors.textLight),
                  ],
                ),
              ),
            ),
          ),
          if (isPopular)
            Positioned(
              top: -6,
              right: 16,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.gold,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'MAIS POPULAR',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
