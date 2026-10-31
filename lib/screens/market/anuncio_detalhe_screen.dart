import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/crypton_service.dart';
import '../../models/anuncio.dart';
import '../../routes/app_routes.dart';

class AnuncioDetalheScreen extends StatefulWidget {
  final Anuncio anuncio;

  const AnuncioDetalheScreen({super.key, required this.anuncio});

  @override
  State<AnuncioDetalheScreen> createState() => _AnuncioDetalheScreenState();
}

class _AnuncioDetalheScreenState extends State<AnuncioDetalheScreen> {
  int _fotoAtual = 0;
  bool _desbloqueando = false;
  bool _desbloqueado = false;
  int _saldoCryptons = 0;

  @override
  void initState() {
    super.initState();
    _carregarSaldo();
  }

  Future<void> _carregarSaldo() async {
    if (AuthService.usuarioAtual == null) return;
    try {
      final data = await CryptonService.consultarCarteira();
      if (!mounted) return;
      setState(() {
        _saldoCryptons = (data['saldo'] as num?)?.toInt() ?? 0;
      });
    } catch (_) {}
  }

  Future<void> _desbloquear() async {
    final user = AuthService.usuarioAtual;
    if (user == null) {
      Navigator.pushNamed(context, AppRoutes.login);
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text('Desbloquear contato'),
        content: Text(
          'Você vai gastar ${CryptonService.cryptonPorDesbloqueio} Cryptons '
          'para ver o contato deste anúncio.\n\n'
          'Seu saldo: $_saldoCryptons Cryptons.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancelar'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricBlue,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Desbloquear'),
          ),
        ],
      ),
    );

    if (confirmar != true) return;

    setState(() => _desbloqueando = true);

    try {
      final saldoRestante =
          await CryptonService.desbloquearComCrypton(widget.anuncio.id);

      if (!mounted) return;

      setState(() {
        _saldoCryptons = saldoRestante;
        _desbloqueado = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Contato desbloqueado! Saldo: $saldoRestante Cryptons'),
          backgroundColor: AppColors.success,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (!mounted) return;

      final msg = e.toString().replaceFirst('Exception: ', '');

      if (msg.toLowerCase().contains('insuficiente')) {
        final irComprar = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            title: const Text('Saldo insuficiente'),
            content: const Text(
              'Você não tem Cryptons suficientes. Deseja comprar agora?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx, false),
                child: const Text('Agora não'),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                ),
                onPressed: () => Navigator.pop(ctx, true),
                child: const Text('Comprar Cryptons'),
              ),
            ],
          ),
        );

        if (irComprar == true && mounted) {
          await Navigator.pushNamed(context, AppRoutes.comprarCryptons);
          if (mounted) _carregarSaldo();
        }
        return;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Erro: $msg'),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    } finally {
      if (mounted) setState(() => _desbloqueando = false);
    }
  }

  Future<void> _abrirWhatsApp() async {
    final numero =
        widget.anuncio.whatsappContato.replaceAll(RegExp(r'[^0-9]'), '');
    if (numero.isEmpty) return;

    final uri = Uri.parse('https://wa.me/55$numero');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  Future<void> _abrirEmail() async {
    final email = widget.anuncio.emailContato;
    if (email.isEmpty) return;

    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  String _precoFormatado() {
    if (widget.anuncio.preco == null) return 'A combinar';
    return 'R\$ ${widget.anuncio.preco!.toStringAsFixed(2).replaceAll('.', ',')}';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
              child: Row(
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: const Icon(Icons.arrow_back_rounded,
                        color: AppColors.textDark),
                  ),
                  const Spacer(),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: const Color(0xFF7C3AED).withOpacity(0.1),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: const Color(0xFF7C3AED).withOpacity(0.35),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.monetization_on_rounded,
                            size: 15, color: Color(0xFF7C3AED)),
                        const SizedBox(width: 5),
                        Text(
                          '$_saldoCryptons',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w800,
                            color: Color(0xFF7C3AED),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildFotos(),
                    const SizedBox(height: 20),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 10, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.electricBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              widget.anuncio.categoria.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                                color: AppColors.electricBlue,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            widget.anuncio.titulo,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: AppColors.textDark,
                              height: 1.25,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            _precoFormatado(),
                            style: const TextStyle(
                              fontSize: 26,
                              fontWeight: FontWeight.w900,
                              color: AppColors.gold,
                              letterSpacing: -1,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Descrição',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textDark,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            widget.anuncio.descricao,
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.textGray,
                              height: 1.55,
                            ),
                          ),
                          const SizedBox(height: 28),
                          _buildContato(),
                        ],
                      ),
                    ),
                    const SizedBox(height: 100),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: _buildBotaoInferior(),
    );
  }

  Widget _buildFotos() {
    final fotos = widget.anuncio.fotos;

    if (fotos.isEmpty) {
      return Container(
        height: 260,
        color: AppColors.electricBlue.withOpacity(0.06),
        child: const Center(
          child:
              Icon(Icons.image_outlined, size: 60, color: AppColors.textLight),
        ),
      );
    }

    return Column(
      children: [
        SizedBox(
          height: 280,
          child: PageView.builder(
            itemCount: fotos.length,
            onPageChanged: (i) => setState(() => _fotoAtual = i),
            itemBuilder: (_, i) => Image.network(
              fotos[i],
              fit: BoxFit.cover,
              width: double.infinity,
              errorBuilder: (_, __, ___) => Container(
                color: AppColors.electricBlue.withOpacity(0.06),
                child: const Icon(Icons.broken_image_outlined,
                    size: 60, color: AppColors.textLight),
              ),
            ),
          ),
        ),
        if (fotos.length > 1)
          Padding(
            padding: const EdgeInsets.only(top: 10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                fotos.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _fotoAtual ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _fotoAtual
                        ? AppColors.electricBlue
                        : AppColors.borderLight,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildContato() {
    if (!_desbloqueado) {
      return Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF7C3AED).withOpacity(0.08),
              const Color(0xFF7C3AED).withOpacity(0.02),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFF7C3AED).withOpacity(0.3),
            width: 1.3,
          ),
        ),
        child: Column(
          children: [
            const Icon(Icons.lock_outline_rounded,
                color: Color(0xFF7C3AED), size: 32),
            const SizedBox(height: 10),
            const Text(
              'Contato bloqueado',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Use ${CryptonService.cryptonPorDesbloqueio} Cryptons para '
              'ver o WhatsApp e e-mail do anunciante.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: AppColors.textGray,
                height: 1.45,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle_rounded,
                  color: AppColors.success, size: 22),
              SizedBox(width: 8),
              Text(
                'Contato liberado',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: AppColors.textDark,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (widget.anuncio.whatsappContato.isNotEmpty)
            _botaoContato(
              icone: Icons.chat_bubble_outline_rounded,
              cor: const Color(0xFF25D366),
              label: 'WhatsApp',
              valor: widget.anuncio.whatsappContato,
              onTap: _abrirWhatsApp,
            ),
          if (widget.anuncio.whatsappContato.isNotEmpty &&
              widget.anuncio.emailContato.isNotEmpty)
            const SizedBox(height: 10),
          if (widget.anuncio.emailContato.isNotEmpty)
            _botaoContato(
              icone: Icons.email_outlined,
              cor: AppColors.electricBlue,
              label: 'E-mail',
              valor: widget.anuncio.emailContato,
              onTap: _abrirEmail,
            ),
        ],
      ),
    );
  }

  Widget _botaoContato({
    required IconData icone,
    required Color cor,
    required String label,
    required String valor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: cor.withOpacity(0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: cor.withOpacity(0.25)),
          ),
          child: Row(
            children: [
              Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: cor.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icone, color: cor, size: 20),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textGray,
                        letterSpacing: 0.3,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      valor,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                        color: AppColors.textDark,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios_rounded, size: 14, color: cor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBotaoInferior() {
    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: AppColors.background,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 54,
        child: _desbloqueado
            ? ElevatedButton.icon(
                onPressed: _abrirWhatsApp,
                icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                label: const Text('Falar no WhatsApp'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF25D366),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              )
            : ElevatedButton.icon(
                onPressed: _desbloqueando ? null : _desbloquear,
                icon: _desbloqueando
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.lock_open_rounded, size: 20),
                label: Text(
                  _desbloqueando
                      ? 'Desbloqueando...'
                      : 'Desbloquear por ${CryptonService.cryptonPorDesbloqueio} Cryptons',
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
      ),
    );
  }
}
