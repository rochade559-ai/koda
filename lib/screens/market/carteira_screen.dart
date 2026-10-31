import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/crypton_service.dart';
import '../../models/carteira.dart';
import '../../routes/app_routes.dart';
import '../../widgets/loading_kodaff.dart';

class CarteiraScreen extends StatefulWidget {
  const CarteiraScreen({super.key});

  @override
  State<CarteiraScreen> createState() => _CarteiraScreenState();
}

class _CarteiraScreenState extends State<CarteiraScreen> {
  bool _carregando = true;
  String? _erro;
  int _saldo = 0;
  List<CompraToken> _compras = [];
  List<UsoToken> _usos = [];

  static const int _limiteInicial = 3;
  bool _expandirCompras = false;
  bool _expandirUsos = false;

  @override
  void initState() {
    super.initState();
    _carregar();
  }

  Future<void> _carregar() async {
    setState(() {
      _carregando = true;
      _erro = null;
    });

    try {
      final data = await CryptonService.consultarCarteira();
      if (!mounted) return;
      setState(() {
        _saldo = (data['saldo'] as num?)?.toInt() ?? 0;
        _compras = (data['compras'] as List).cast<CompraToken>();
        _usos = (data['usos'] as List).cast<UsoToken>();
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

  Future<void> _irComprar() async {
    await Navigator.pushNamed(context, AppRoutes.comprarCryptons);
    if (mounted) _carregar();
  }

  String _formatarData(DateTime? data) {
    if (data == null) return '';
    return DateFormat('dd/MM/yyyy • HH:mm', 'pt_BR').format(data);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Minha Carteira'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh_rounded),
            onPressed: _carregando ? null : _carregar,
          ),
        ],
      ),
      body: SafeArea(
        child: _carregando
            ? const Center(
                child: LoadingKodaff(
                  size: 90,
                  texto: 'Carregando carteira...',
                ),
              )
            : _erro != null
                ? _buildErro()
                : RefreshIndicator(
                    color: AppColors.electricBlue,
                    onRefresh: _carregar,
                    child: ListView(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
                      children: [
                        _buildSaldoCard(),
                        const SizedBox(height: 14),
                        _buildBotaoComprar(),
                        const SizedBox(height: 26),
                        _buildSecaoCompras(),
                        const SizedBox(height: 24),
                        _buildSecaoUsos(),
                      ],
                    ),
                  ),
      ),
    );
  }

  Widget _buildErro() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: AppColors.error, size: 48),
            const SizedBox(height: 14),
            Text(
              _erro!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textGray),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: _carregar,
              icon: const Icon(Icons.refresh_rounded, size: 18),
              label: const Text('Tentar novamente'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSaldoCard() {
    final desbloqueios = _saldo ~/ CryptonService.cryptonPorDesbloqueio;

    return Container(
      padding: const EdgeInsets.all(24),
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
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.monetization_on_rounded,
                  color: Colors.white, size: 22),
              const SizedBox(width: 8),
              const Text(
                'Saldo Crypton',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            '$_saldo',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 52,
              fontWeight: FontWeight.w900,
              height: 1,
              letterSpacing: -2,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _saldo == 0
                ? 'Compre Cryptons para desbloquear contatos'
                : 'Suficiente para $desbloqueios ${desbloqueios == 1 ? "desbloqueio" : "desbloqueios"}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotaoComprar() {
    return SizedBox(
      height: 50,
      child: ElevatedButton.icon(
        onPressed: _irComprar,
        icon: const Icon(Icons.add_rounded, size: 20),
        label: const Text('Comprar mais Cryptons'),
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.electricBlue,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          textStyle: const TextStyle(
            fontSize: 14.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
          ),
        ),
      ),
    );
  }

  Widget _buildSecaoCompras() {
    final total = _compras.length;
    final visiveis =
        _expandirCompras ? _compras : _compras.take(_limiteInicial).toList();
    final temMais = total > _limiteInicial;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.shopping_bag_outlined,
                size: 18, color: AppColors.textDark),
            const SizedBox(width: 8),
            const Text(
              'Histórico de Compras',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                letterSpacing: -0.2,
              ),
            ),
            const Spacer(),
            if (total > 0)
              Text(
                '$total ${total == 1 ? "item" : "itens"}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_compras.isEmpty)
          _buildVazio('Nenhuma compra ainda.')
        else ...[
          ...visiveis.map(_buildItemCompra),
          if (temMais)
            _buildBotaoVerMais(
              expandido: _expandirCompras,
              restantes: total - _limiteInicial,
              onTap: () => setState(() => _expandirCompras = !_expandirCompras),
            ),
        ],
      ],
    );
  }

  Widget _buildItemCompra(CompraToken c) {
    final pago = c.status == 'pago';
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: pago
                  ? AppColors.success.withOpacity(0.12)
                  : AppColors.gold.withOpacity(0.15),
              borderRadius: BorderRadius.circular(11),
            ),
            child: Icon(
              pago ? Icons.check_circle_rounded : Icons.hourglass_top_rounded,
              color: pago ? AppColors.success : AppColors.gold,
              size: 22,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      '+${c.cryptons} Cryptons',
                      style: const TextStyle(
                        fontSize: 14.5,
                        fontWeight: FontWeight.w800,
                        color: AppColors.textDark,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: pago
                            ? AppColors.success.withOpacity(0.12)
                            : AppColors.gold.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        pago ? 'PAGO' : 'PENDENTE',
                        style: TextStyle(
                          fontSize: 9,
                          fontWeight: FontWeight.w900,
                          letterSpacing: 0.4,
                          color: pago ? AppColors.success : AppColors.gold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  'R\$ ${c.valor.toStringAsFixed(2).replaceAll('.', ',')} • ${_formatarData(c.criadoEm)}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSecaoUsos() {
    final total = _usos.length;
    final visiveis =
        _expandirUsos ? _usos : _usos.take(_limiteInicial).toList();
    final temMais = total > _limiteInicial;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            const Icon(Icons.lock_open_rounded,
                size: 18, color: AppColors.textDark),
            const SizedBox(width: 8),
            const Text(
              'Histórico de Usos',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w800,
                color: AppColors.textDark,
                letterSpacing: -0.2,
              ),
            ),
            const Spacer(),
            if (total > 0)
              Text(
                '$total ${total == 1 ? "item" : "itens"}',
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textLight,
                  fontWeight: FontWeight.w600,
                ),
              ),
          ],
        ),
        const SizedBox(height: 12),
        if (_usos.isEmpty)
          _buildVazio('Nenhum contato desbloqueado ainda.')
        else ...[
          ...visiveis.map(_buildItemUso),
          if (temMais)
            _buildBotaoVerMais(
              expandido: _expandirUsos,
              restantes: total - _limiteInicial,
              onTap: () => setState(() => _expandirUsos = !_expandirUsos),
            ),
        ],
      ],
    );
  }

  Widget _buildItemUso(UsoToken u) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withOpacity(0.1),
              borderRadius: BorderRadius.circular(11),
            ),
            child: const Icon(Icons.person_pin_circle_outlined,
                color: AppColors.electricBlue, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  u.anuncioTitulo,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  '${_formatarData(u.criadoEm)}',
                  style: const TextStyle(
                    fontSize: 11.5,
                    color: AppColors.textGray,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '-${u.cryptons}',
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w900,
              color: AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBotaoVerMais({
    required bool expandido,
    required int restantes,
    required VoidCallback onTap,
  }) {
    return Padding(
      padding: const EdgeInsets.only(top: 2),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
            decoration: BoxDecoration(
              color: AppColors.electricBlue.withOpacity(0.06),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AppColors.electricBlue.withOpacity(0.2),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  expandido
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  size: 18,
                  color: AppColors.electricBlue,
                ),
                const SizedBox(width: 6),
                Text(
                  expandido
                      ? 'Ver menos'
                      : 'Ver mais ($restantes ${restantes == 1 ? "item" : "itens"})',
                  style: const TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w700,
                    color: AppColors.electricBlue,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildVazio(String texto) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          const Icon(Icons.inbox_outlined,
              color: AppColors.textLight, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              texto,
              style: const TextStyle(
                fontSize: 13,
                color: AppColors.textGray,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
