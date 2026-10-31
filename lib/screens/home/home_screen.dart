import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_strings.dart';
import '../../core/services/admin_service.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/crypton_service.dart';
import '../../routes/app_routes.dart';
import '../../widgets/loading_kodaff.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              // ==================== TOPO: LOGO + BOTÕES ====================
              Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.primary,
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.electricBlue.withOpacity(0.3),
                          blurRadius: 14,
                          spreadRadius: 1,
                          offset: const Offset(0, 3),
                        ),
                      ],
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                        width: 1.2,
                      ),
                    ),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/icons/app_icon.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Kodaff',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                      color: AppColors.primary,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const Spacer(),
                  StreamBuilder(
                    stream: AuthService.authState,
                    builder: (context, snapshot) {
                      final logado = snapshot.data != null;

                      if (!logado) {
                        return TextButton(
                          onPressed: () {
                            Navigator.pushNamed(context, AppRoutes.login);
                          },
                          style: TextButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 4),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            foregroundColor: AppColors.electricBlue,
                          ),
                          child: const Text(
                            'Entrar',
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w700,
                              letterSpacing: -0.2,
                            ),
                          ),
                        );
                      }

                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          FutureBuilder<bool>(
                            future: AdminService.isAdmin(),
                            builder: (context, snap) {
                              if (snap.data != true) {
                                return const SizedBox.shrink();
                              }
                              return Padding(
                                padding: const EdgeInsets.only(right: 4),
                                child: Tooltip(
                                  message: 'Painel Admin',
                                  child: InkWell(
                                    borderRadius: BorderRadius.circular(20),
                                    onTap: () {
                                      Navigator.pushNamed(
                                          context, AppRoutes.admin);
                                    },
                                    child: Container(
                                      width: 32,
                                      height: 32,
                                      decoration: BoxDecoration(
                                        color: AppColors.gold.withOpacity(0.12),
                                        shape: BoxShape.circle,
                                        border: Border.all(
                                          color:
                                              AppColors.gold.withOpacity(0.4),
                                          width: 1,
                                        ),
                                      ),
                                      child: const Icon(
                                        Icons.admin_panel_settings_outlined,
                                        size: 15,
                                        color: AppColors.gold,
                                      ),
                                    ),
                                  ),
                                ),
                              );
                            },
                          ),
                          const _BotaoCarteira(),
                          Padding(
                            padding: const EdgeInsets.only(right: 4),
                            child: Tooltip(
                              message: 'Configurações',
                              child: InkWell(
                                borderRadius: BorderRadius.circular(20),
                                onTap: () {
                                  Navigator.pushNamed(
                                      context, AppRoutes.configuracoes);
                                },
                                child: Container(
                                  width: 32,
                                  height: 32,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: AppColors.borderLight,
                                      width: 1,
                                    ),
                                  ),
                                  child: const Icon(
                                    Icons.settings_outlined,
                                    size: 15,
                                    color: AppColors.textGray,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          Tooltip(
                            message: 'Sair',
                            child: InkWell(
                              borderRadius: BorderRadius.circular(20),
                              onTap: () async {
                                await AuthService.logout();
                                if (context.mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                      content: Text('Você saiu da conta.'),
                                      behavior: SnackBarBehavior.floating,
                                    ),
                                  );
                                }
                              },
                              child: Container(
                                width: 32,
                                height: 32,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.borderLight,
                                    width: 1,
                                  ),
                                ),
                                child: const Icon(
                                  Icons.logout_rounded,
                                  size: 15,
                                  color: AppColors.textGray,
                                ),
                              ),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ],
              ),

              const SizedBox(height: 28),

              RichText(
                textAlign: TextAlign.center,
                text: const TextSpan(
                  style: TextStyle(
                    fontSize: 23,
                    fontWeight: FontWeight.w800,
                    color: AppColors.textDark,
                    height: 1.2,
                    letterSpacing: -0.4,
                  ),
                  children: [
                    TextSpan(text: "Conecte-se ao "),
                    TextSpan(
                      text: "Futuro do Capital",
                      style: TextStyle(color: AppColors.electricBlue),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                AppStrings.homeSubtitle,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textGray,
                  height: 1.5,
                  fontWeight: FontWeight.w400,
                ),
              ),

              const SizedBox(height: 28),

              // ==================== CARD 1 — QUERO CAPTAR ====================
              _CardOpcaoTech(
                titulo: 'Quero captar recursos',
                descricao:
                    'Sua empresa precisa de investimento? Cadastre seu projeto e receba propostas de investidores qualificados.',
                primaryColor: AppColors.electricBlue,
                iconWidget: const _IconeGrafico3D(),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.cadastroEmpresa);
                },
              ),

              const SizedBox(height: 16),

              // ==================== CARD 2 — QUERO INVESTIR ====================
              _CardOpcaoTech(
                titulo: 'Quero investir',
                descricao:
                    'Encontre oportunidades em terras, empresas, tecnologia e mais. Negocie direto com quem precisa de capital.',
                primaryColor: AppColors.gold,
                iconWidget: const _IconeCarteira3D(),
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.cadastroInvestidor);
                },
              ),

              const SizedBox(height: 16),

              // ==================== CARD — PERMUTA ====================
              _CardOpcaoTech(
                titulo: 'Tenho um terreno ou casa',
                descricao:
                    'Pagamos seu terreno ou casa antiga, ou oferecemos apartamentos '
                    'prontos em permuta. Construímos conforme o zoneamento da sua '
                    'cidade — de pequenos lotes a grandes empreendimentos.',
                primaryColor: const Color(0xFF16A34A),
                iconWidget: const _IconeConstrucao3D(),
                onTap: () {
                  if (FirebaseAuth.instance.currentUser == null) {
                    Navigator.pushNamed(context, AppRoutes.login);
                  } else {
                    Navigator.pushNamed(context, AppRoutes.captacaoConstrucao);
                  }
                },
              ),

              const SizedBox(height: 16),

              // ==================== CARD 3 — ANUNCIE AQUI (MARKET) ====================
              _MarketCard(
                onTap: () {
                  Navigator.pushNamed(context, AppRoutes.market);
                },
              ),

              const SizedBox(height: 16),

              // ==================== CARD — AJUDA ESPECIALIZADA ====================
              _CardOpcaoTech(
                titulo: 'Ajuda Especializada',
                descricao:
                    'Advogados para causas acima de R\$ 500 mil e engenheiros '
                    'para projetos técnicos. Time Kodaff pronto para resolver.',
                primaryColor: const Color(0xFF1E3A8A),
                iconWidget: const _IconeAjuda3D(),
                onTap: () {
                  if (FirebaseAuth.instance.currentUser == null) {
                    Navigator.pushNamed(context, AppRoutes.login);
                  } else {
                    Navigator.pushNamed(context, AppRoutes.ajudaEspecializada);
                  }
                },
              ),

              const SizedBox(height: 20),

              // ==================== BOTÕES DE SOLICITAÇÕES (LOGADO) ====================
              StreamBuilder(
                stream: AuthService.authState,
                builder: (context, snapshot) {
                  if (snapshot.data == null) {
                    return const SizedBox.shrink();
                  }
                  return Column(
                    children: [
                      _BotaoTodasSolicitacoes(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.status);
                        },
                      ),
                      const SizedBox(height: 12),
                      _CardMinhaSolicitacao(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.status);
                        },
                      ),
                    ],
                  );
                },
              ),

              // ==================== LINK DE LOGIN ====================
              StreamBuilder(
                stream: AuthService.authState,
                builder: (context, snapshot) {
                  if (snapshot.data != null) {
                    return const SizedBox.shrink();
                  }
                  return Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Center(
                      child: TextButton(
                        onPressed: () {
                          Navigator.pushNamed(context, AppRoutes.login);
                        },
                        style: TextButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 10, vertical: 6),
                          foregroundColor: AppColors.textGray,
                        ),
                        child: RichText(
                          text: const TextSpan(
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textGray,
                            ),
                            children: [
                              TextSpan(text: 'Já tem cadastro? '),
                              TextSpan(
                                text: 'Faça o login aqui',
                                style: TextStyle(
                                  color: AppColors.electricBlue,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 24),

              // ==================== CARD — POR QUE CONFIAR ====================
              const _CardConfianca(),

              const SizedBox(height: 20),

              // ==================== RODAPÉ COM LINKS ====================
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _LinkRodape(
                        texto: 'Termos de Uso',
                        url: 'https://www.kodaff.com/termos',
                      ),
                      Container(
                        width: 1,
                        height: 12,
                        color: AppColors.borderLight,
                      ),
                      _LinkRodape(
                        texto: 'Política de Privacidade',
                        url: 'https://www.kodaff.com/privacidade',
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    AppStrings.footer,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.textGray,
                      letterSpacing: 0.2,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// BOTÃO CARTEIRA
// ============================================================
class _BotaoCarteira extends StatefulWidget {
  const _BotaoCarteira();

  @override
  State<_BotaoCarteira> createState() => _BotaoCarteiraState();
}

class _BotaoCarteiraState extends State<_BotaoCarteira> {
  int _saldo = 0;
  bool _carregando = true;

  @override
  void initState() {
    super.initState();
    _carregarSaldo();
  }

  Future<void> _carregarSaldo() async {
    try {
      final data = await CryptonService.consultarCarteira();
      if (!mounted) return;
      setState(() {
        _saldo = (data['saldo'] as num?)?.toInt() ?? 0;
        _carregando = false;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _carregando = false);
    }
  }

  Future<void> _abrir() async {
    await Navigator.pushNamed(context, AppRoutes.carteira);
    if (mounted) {
      setState(() => _carregando = true);
      _carregarSaldo();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 4),
      child: Tooltip(
        message: 'Minha Carteira',
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: _abrir,
          child: Container(
            height: 32,
            padding: const EdgeInsets.symmetric(horizontal: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF7C3AED).withOpacity(0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: const Color(0xFF7C3AED).withOpacity(0.35),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(
                  Icons.monetization_on_rounded,
                  size: 14,
                  color: Color(0xFF7C3AED),
                ),
                const SizedBox(width: 4),
                _carregando
                    ? const LoadingKodaff(
                        size: 16,
                        corPrimaria: Color(0xFF7C3AED),
                        corSecundaria: Color(0xFFA78BFA),
                        corDestaque: Colors.white,
                      )
                    : Text(
                        '$_saldo',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF7C3AED),
                          letterSpacing: -0.2,
                        ),
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
// NOVO BOTÃO — VER TODAS AS SOLICITAÇÕES
// ============================================================
class _BotaoTodasSolicitacoes extends StatelessWidget {
  final VoidCallback onTap;
  const _BotaoTodasSolicitacoes({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
          decoration: BoxDecoration(
            color: AppColors.primary,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppColors.electricBlue.withOpacity(0.4),
              width: 1.2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppColors.electricBlue.withOpacity(0.15),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.format_list_bulleted_rounded,
                color: AppColors.electricBlue,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Ver todas as minhas solicitações',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.2,
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
// CARD DO MARKET
// ============================================================
class _MarketCard extends StatefulWidget {
  final VoidCallback onTap;
  const _MarketCard({required this.onTap});

  @override
  State<_MarketCard> createState() => _MarketCardState();
}

class _MarketCardState extends State<_MarketCard> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _isPressed ? 0.97 : 1.0,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          splashColor: Colors.white.withOpacity(0.15),
          highlightColor: Colors.white.withOpacity(0.08),
          onTapDown: (_) => setState(() => _isPressed = true),
          onTapUp: (_) => setState(() => _isPressed = false),
          onTapCancel: () => setState(() => _isPressed = false),
          onTap: widget.onTap,
          child: Container(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFFA78BFA)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(20),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF7C3AED).withOpacity(0.3),
                  blurRadius: 16,
                  offset: const Offset(0, 6),
                ),
              ],
            ),
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.3),
                          Colors.white.withOpacity(0.1),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.4),
                        width: 1,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 6,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: const Center(
                      child: Icon(
                        Icons.shopping_bag_rounded,
                        color: Colors.white,
                        size: 24,
                      ),
                    ),
                  ),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // 👇 TÍTULO NOVO 👇
                        Text(
                          'ANUNCIE AQUI -',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 3),
                        // 👇 SUBTÍTULO NOVO 👇
                        Text(
                          'Comprador e vendedor, Veja Aqui Oportunidades.',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.white70,
                            height: 1.3,
                          ),
                        ),
                        SizedBox(height: 3),
                        // 👇 TEXTO ORIGINAL MANTIDO AQUI 👇
                        Text(
                          'Terras, ouro, empresas, tecnologia e mais',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: Colors.white70,
                            height: 1.3,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LINK DO RODAPÉ
// ============================================================
class _LinkRodape extends StatelessWidget {
  final String texto;
  final String url;

  const _LinkRodape({required this.texto, required this.url});

  @override
  Widget build(BuildContext context) {
    return TextButton(
      onPressed: () async {
        try {
          await launchUrl(
            Uri.parse(url),
            mode: LaunchMode.externalApplication,
          );
        } catch (_) {}
      },
      style: TextButton.styleFrom(
        padding: const EdgeInsets.symmetric(horizontal: 10),
        minimumSize: Size.zero,
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        texto,
        style: const TextStyle(
          fontSize: 11,
          color: AppColors.textGray,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }
}

// ============================================================
// CARD MINHA SOLICITAÇÃO (EXISTENTE)
// ============================================================
class _CardMinhaSolicitacao extends StatefulWidget {
  final VoidCallback onTap;
  const _CardMinhaSolicitacao({required this.onTap});

  @override
  State<_CardMinhaSolicitacao> createState() => _CardMinhaSolicitacaoState();
}

class _CardMinhaSolicitacaoState extends State<_CardMinhaSolicitacao> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _isPressed ? 0.97 : 1.0,
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.electricBlue.withOpacity(0.08),
              AppColors.electricBlue.withOpacity(0.02),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: AppColors.electricBlue.withOpacity(0.3),
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.electricBlue.withOpacity(0.08),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(18),
          child: InkWell(
            borderRadius: BorderRadius.circular(18),
            splashColor: AppColors.electricBlue.withOpacity(0.15),
            highlightColor: AppColors.electricBlue.withOpacity(0.08),
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppColors.electricBlue.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.receipt_long_rounded,
                      color: AppColors.electricBlue,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Minha solicitação',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            color: AppColors.textDark,
                            letterSpacing: -0.2,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Acompanhe o andamento em tempo real',
                          style: TextStyle(
                            fontSize: 11,
                            color: AppColors.textGray,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 30,
                    height: 30,
                    decoration: BoxDecoration(
                      color: AppColors.electricBlue.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.arrow_forward_rounded,
                      size: 16,
                      color: AppColors.electricBlue,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CARD INTERATIVO HIGH-TECH
// ============================================================
class _CardOpcaoTech extends StatefulWidget {
  final String titulo;
  final String descricao;
  final Color primaryColor;
  final Widget iconWidget;
  final VoidCallback onTap;

  const _CardOpcaoTech({
    required this.titulo,
    required this.descricao,
    required this.primaryColor,
    required this.iconWidget,
    required this.onTap,
  });

  @override
  State<_CardOpcaoTech> createState() => _CardOpcaoTechState();
}

class _CardOpcaoTechState extends State<_CardOpcaoTech> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      duration: const Duration(milliseconds: 120),
      scale: _isPressed ? 0.97 : 1.0,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 180),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: _isPressed
                ? widget.primaryColor.withOpacity(0.5)
                : AppColors.borderLight,
            width: 1.3,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.primaryColor.withOpacity(_isPressed ? 0.15 : 0.05),
              blurRadius: _isPressed ? 20 : 14,
              spreadRadius: 0,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          child: InkWell(
            borderRadius: BorderRadius.circular(20),
            splashColor: widget.primaryColor.withOpacity(0.12),
            highlightColor: widget.primaryColor.withOpacity(0.06),
            onTapDown: (_) => setState(() => _isPressed = true),
            onTapUp: (_) => setState(() => _isPressed = false),
            onTapCancel: () => setState(() => _isPressed = false),
            onTap: widget.onTap,
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Center(
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      child: widget.iconWidget,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          widget.titulo,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: widget.primaryColor,
                            letterSpacing: -0.2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: widget.primaryColor.withOpacity(0.08),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          Icons.arrow_forward_rounded,
                          size: 18,
                          color: widget.primaryColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    widget.descricao,
                    style: const TextStyle(
                      fontSize: 12.5,
                      color: AppColors.textGray,
                      height: 1.5,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ÍCONE 3D: GRÁFICO
// ============================================================
class _IconeGrafico3D extends StatelessWidget {
  const _IconeGrafico3D();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85,
      height: 75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            AppColors.electricBlue.withOpacity(0.12),
            AppColors.electricBlue.withOpacity(0.03),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 8,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.electricBlue.withOpacity(0.4),
                    blurRadius: 25,
                    spreadRadius: 8,
                  ),
                ],
              ),
            ),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildBar(24, const [Color(0xFF93C5FD), Color(0xFF3B82F6)]),
              const SizedBox(width: 6),
              _buildBar(38, const [Color(0xFF60A5FA), Color(0xFF2563EB)]),
              const SizedBox(width: 6),
              _buildBar(52, const [Color(0xFF3B82F6), Color(0xFF1D4ED8)]),
            ],
          ),
          Positioned(
            top: 10,
            right: 15,
            child: Icon(
              Icons.trending_up_rounded,
              color: AppColors.electricBlueLight,
              size: 22,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBar(double height, List<Color> colors) {
    return Container(
      width: 15,
      height: height,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(5),
        gradient: LinearGradient(
          colors: colors,
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        boxShadow: [
          BoxShadow(
            color: colors.last.withOpacity(0.3),
            blurRadius: 5,
            offset: const Offset(0, 2),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ÍCONE 3D: CARTEIRA
// ============================================================
class _IconeCarteira3D extends StatelessWidget {
  const _IconeCarteira3D();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 85,
      height: 75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            AppColors.gold.withOpacity(0.12),
            AppColors.gold.withOpacity(0.03),
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 12,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gold.withOpacity(0.35),
                    blurRadius: 24,
                    spreadRadius: 6,
                  ),
                ],
              ),
            ),
          ),
          Container(
            width: 54,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              gradient: const LinearGradient(
                colors: [Color(0xFFFBBF24), Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.gold.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Center(
              child: Container(
                width: 14,
                height: 14,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.lock_rounded,
                  size: 8,
                  color: AppColors.gold,
                ),
              ),
            ),
          ),
          Positioned(
            top: 8,
            right: 18,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFEF3C7),
                border: Border.all(color: AppColors.gold, width: 1.3),
                boxShadow: const [
                  BoxShadow(color: Colors.black12, blurRadius: 3),
                ],
              ),
              child: const Icon(
                Icons.attach_money_rounded,
                size: 12,
                color: AppColors.gold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ÍCONE 3D: CONSTRUÇÃO
// ============================================================
class _IconeConstrucao3D extends StatelessWidget {
  const _IconeConstrucao3D();

  @override
  Widget build(BuildContext context) {
    const verde = Color(0xFF16A34A);
    return Container(
      width: 85,
      height: 75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [verde.withOpacity(0.12), verde.withOpacity(0.03)],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 10,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: verde.withOpacity(0.35),
                    blurRadius: 24,
                    spreadRadius: 6,
                  ),
                ],
              ),
            ),
          ),
          const Icon(Icons.apartment_rounded, color: verde, size: 40),
          Positioned(
            top: 10,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: verde, width: 1.3),
              ),
              child: const Icon(
                Icons.swap_horiz_rounded,
                size: 12,
                color: verde,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ÍCONE 3D: AJUDA ESPECIALIZADA
// ============================================================
class _IconeAjuda3D extends StatelessWidget {
  const _IconeAjuda3D();

  @override
  Widget build(BuildContext context) {
    const azul = Color(0xFF1E3A8A);
    const laranja = Color(0xFFEA580C);
    return Container(
      width: 85,
      height: 75,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(18),
        gradient: LinearGradient(
          colors: [
            azul.withOpacity(0.12),
            laranja.withOpacity(0.06),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Positioned(
            top: 10,
            child: Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: azul.withOpacity(0.3),
                    blurRadius: 22,
                    spreadRadius: 5,
                  ),
                ],
              ),
            ),
          ),
          const Icon(Icons.balance_rounded, color: azul, size: 36),
          Positioned(
            top: 8,
            right: 14,
            child: Container(
              padding: const EdgeInsets.all(3),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                border: Border.all(color: laranja, width: 1.3),
              ),
              child: const Icon(
                Icons.settings_suggest_rounded,
                size: 12,
                color: laranja,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CARD — POR QUE CONFIAR NA KODAFF (compacto)
// ============================================================
class _CardConfianca extends StatefulWidget {
  const _CardConfianca();

  @override
  State<_CardConfianca> createState() => _CardConfiancaState();
}

class _CardConfiancaState extends State<_CardConfianca> {
  bool _aberto = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          borderRadius: BorderRadius.circular(14),
          onTap: () => setState(() => _aberto = !_aberto),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Por que confiar na Kodaff',
                        style: TextStyle(
                          fontSize: 13.5,
                          fontWeight: FontWeight.w700,
                          color: AppColors.textDark,
                          letterSpacing: -0.2,
                        ),
                      ),
                    ),
                    AnimatedRotation(
                      turns: _aberto ? 0.5 : 0,
                      duration: const Duration(milliseconds: 200),
                      child: const Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: AppColors.textGray,
                        size: 20,
                      ),
                    ),
                  ],
                ),
                AnimatedCrossFade(
                  firstChild: const SizedBox(width: double.infinity),
                  secondChild: Padding(
                    padding: const EdgeInsets.only(top: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'A Kodaff Comércio e Marketing LTDA atua há mais de '
                          '8 anos nos setores de construção civil, mineração e '
                          'investimentos. Já ajudamos a realizar o sonho da casa '
                          'própria e de empreendimentos reais, sempre com '
                          'transparência e resultado.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray,
                            height: 1.55,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Trabalhamos com fundos de investimento nacionais e '
                          'internacionais, oferecendo um serviço justo, seguro '
                          'e alinhado às melhores práticas do mercado. Nosso '
                          'compromisso é dar cobertura ao que você realmente '
                          'precisa.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray,
                            height: 1.55,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Ao longo da nossa trajetória, tivemos a oportunidade '
                          'de representar empresas internacionais no Brasil, '
                          'consolidando parcerias e elevando o padrão técnico '
                          'dos nossos projetos.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray,
                            height: 1.55,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Dados oficiais',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textLight,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Kodaff Comércio e Marketing LTDA',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'CNPJ 61.771.229/0001-14',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textGray,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Construção civil, mineração e investimentos',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textGray,
                          ),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'Case de sucesso',
                          style: TextStyle(
                            fontSize: 10.5,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textLight,
                            letterSpacing: 0.8,
                          ),
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Mineradora Dafema Ltda',
                          style: TextStyle(
                            fontSize: 12.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textDark,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'CNPJ 29.202.953/0001-14',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textGray,
                          ),
                        ),
                        const SizedBox(height: 3),
                        const Text(
                          'Mineração e recursos naturais',
                          style: TextStyle(
                            fontSize: 11.5,
                            color: AppColors.textGray,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Contamos com você e com a sua confiança. Estamos '
                          'à disposição para construir juntos resultados que '
                          'transformam.',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.textGray,
                            height: 1.55,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                  crossFadeState: _aberto
                      ? CrossFadeState.showSecond
                      : CrossFadeState.showFirst,
                  duration: const Duration(milliseconds: 250),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
