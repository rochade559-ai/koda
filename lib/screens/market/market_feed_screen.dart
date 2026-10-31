import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/constants/app_colors.dart';
import '../../core/services/anuncios_service.dart';
import '../../core/services/auth_service.dart';
import '../../models/anuncio.dart';
import '../../routes/app_routes.dart';

// ============================================================
// PALETA GLOBAL DO DESIGN MATRIX
// ============================================================
const Color kBgDark = Color(0xFF07090E);
const Color kSurfaceDark = Color(0xFF101622);
const Color kNeonCyan = Color(0xFF00E5FF);

class MarketFeedScreen extends StatefulWidget {
  const MarketFeedScreen({super.key});

  @override
  State<MarketFeedScreen> createState() => _MarketFeedScreenState();
}

class _MarketFeedScreenState extends State<MarketFeedScreen> {
  String? _categoriaSelecionada;

  // Mapeamento de ícones das categorias reais do Kodaff
  IconData _getIconForCategory(String? categoryId) {
    switch (categoryId) {
      case 'terras':
        return Icons.landscape_rounded;
      case 'ouro':
        return Icons.diamond_rounded;
      case 'empresas':
        return Icons.business_rounded;
      case 'maquinario':
        return Icons.precision_manufacturing_rounded;
      case 'tecnologia':
        return Icons.memory_rounded;
      case 'outros':
        return Icons.category_rounded;
      default:
        return Icons.hub_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: kBgDark,
      // 👇 BOTÃO FLUTUANTE NO RODAPÉ ADICIONADO AQUI 👇
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          final user = AuthService.usuarioAtual;
          if (user == null) {
            Navigator.pushNamed(context, AppRoutes.login);
            return;
          }
          Navigator.pushNamed(context, AppRoutes.criarAnuncio);
        },
        backgroundColor: kNeonCyan,
        icon: const Icon(Icons.add_rounded, color: kBgDark, size: 22),
        label: const Text(
          'ANUNCIAR',
          style: TextStyle(
            color: kBgDark,
            fontWeight: FontWeight.w900,
            fontSize: 13,
            letterSpacing: 1.0,
          ),
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ============ APPBAR FUTURISTA (SEM O BOTÃO) ============
          SliverAppBar(
            backgroundColor: kBgDark.withOpacity(0.9),
            elevation: 0,
            pinned: true,
            floating: true,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: kNeonCyan.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: kNeonCyan.withOpacity(0.3)),
                  ),
                  child: const Icon(Icons.grid_view_rounded,
                      color: kNeonCyan, size: 20),
                ),
                const SizedBox(width: 12),
                const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'KODAFF // MATRIX',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.5,
                      ),
                    ),
                    Text(
                      'SECURE FEED V1.0',
                      style: TextStyle(
                        color: Colors.white38,
                        fontSize: 9,
                        letterSpacing: 1.0,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // O `actions` foi removido daqui!
          ),

          // ============ FILTROS DE CATEGORIA ============
          SliverToBoxAdapter(
            child: Container(
              margin: const EdgeInsets.symmetric(vertical: 16),
              height: 42,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                children: [
                  _ChipFiltroTech(
                    label: 'TODOS',
                    icon: Icons.all_inclusive_rounded,
                    selecionado: _categoriaSelecionada == null,
                    onTap: () => setState(() => _categoriaSelecionada = null),
                  ),
                  const SizedBox(width: 8),
                  ...AnunciosService.categorias.map((cat) {
                    final id = cat['id']!;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: _ChipFiltroTech(
                        label: cat['label']!.toUpperCase(),
                        icon: _getIconForCategory(id),
                        selecionado: _categoriaSelecionada == id,
                        onTap: () => setState(() => _categoriaSelecionada = id),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // ============ FEED DE ANÚNCIOS ============
          StreamBuilder<QuerySnapshot>(
            stream:
                AnunciosService.listarAtivos(categoria: _categoriaSelecionada),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const SliverFillRemaining(
                  child: Center(
                    child: CircularProgressIndicator(
                      color: kNeonCyan,
                      strokeWidth: 2.5,
                    ),
                  ),
                );
              }

              if (snapshot.hasError) {
                return const SliverFillRemaining(
                  child: _EstadoVazioTech(
                    icone: Icons.warning_amber_rounded,
                    titulo: 'FALHA NA CONEXÃO',
                    descricao: 'Verifique o enlace de dados e tente novamente.',
                  ),
                );
              }

              final docs = snapshot.data?.docs ?? [];
              if (docs.isEmpty) {
                return const SliverFillRemaining(
                  child: _EstadoVazioTech(
                    icone: Icons.radar_rounded,
                    titulo: 'NENHUM ANÚNCIO DETECTADO',
                    descricao:
                        'Seja o primeiro a anunciar no Kodaff Market.\nToque em "ANUNCIAR" abaixo.',
                  ),
                );
              }

              return SliverPadding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                sliver: SliverGrid(
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 0.72,
                  ),
                  delegate: SliverChildBuilderDelegate(
                    (context, i) {
                      final doc = docs[i];
                      final anuncio = Anuncio.fromMap(
                        doc.data() as Map<String, dynamic>,
                        doc.id,
                      );
                      return _CardAnuncioTech(
                        anuncio: anuncio,
                        categoriaIcon: _getIconForCategory(anuncio.categoria),
                      );
                    },
                    childCount: docs.length,
                  ),
                ),
              );
            },
          ),

          // 👇 ESPAÇO EXTRA NO FINAL PARA O BOTÃO FLUTUANTE NÃO COBRIR OS CARDS 👇
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}

// ============================================================
// CHIP DE FILTRO TECNOLÓGICO
// ============================================================
class _ChipFiltroTech extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool selecionado;
  final VoidCallback onTap;

  const _ChipFiltroTech({
    required this.label,
    required this.icon,
    required this.selecionado,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(10),
        onTap: onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          decoration: BoxDecoration(
            color: selecionado ? kNeonCyan : kSurfaceDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: selecionado ? kNeonCyan : kNeonCyan.withOpacity(0.15),
              width: 1.2,
            ),
            boxShadow: selecionado
                ? [
                    BoxShadow(
                        color: kNeonCyan.withOpacity(0.4),
                        blurRadius: 10,
                        spreadRadius: 0)
                  ]
                : [],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 14,
                color: selecionado ? kBgDark : kNeonCyan,
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.8,
                  color: selecionado ? kBgDark : Colors.white70,
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
// CARD DE ANÚNCIO MATRIX
// ============================================================
class _CardAnuncioTech extends StatelessWidget {
  final Anuncio anuncio;
  final IconData categoriaIcon;

  const _CardAnuncioTech({
    required this.anuncio,
    required this.categoriaIcon,
  });

  @override
  Widget build(BuildContext context) {
    final temFoto = anuncio.fotos.isNotEmpty;

    return Material(
      color: kSurfaceDark,
      borderRadius: BorderRadius.circular(16),
      elevation: 4,
      shadowColor: Colors.black.withOpacity(0.5),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () {
          AnunciosService.registrarVisualizacao(anuncio.id);
          Navigator.pushNamed(
            context,
            AppRoutes.anuncioDetalhe,
            arguments: anuncio,
          );
        },
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.white.withOpacity(0.06), width: 1),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // ============ IMAGEM ============
              Expanded(
                flex: 5,
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    ClipRRect(
                      borderRadius:
                          const BorderRadius.vertical(top: Radius.circular(15)),
                      child: temFoto
                          ? Image.network(
                              anuncio.fotos.first,
                              fit: BoxFit.cover,
                              errorBuilder: (_, __, ___) =>
                                  _placeholderImagem(),
                            )
                          : _placeholderImagem(),
                    ),
                    DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.transparent,
                            kSurfaceDark.withOpacity(0.8),
                          ],
                        ),
                      ),
                    ),
                    Positioned(
                      top: 8,
                      left: 8,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: kBgDark.withOpacity(0.85),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(color: kNeonCyan.withOpacity(0.3)),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(categoriaIcon, size: 10, color: kNeonCyan),
                            const SizedBox(width: 4),
                            Text(
                              anuncio.categoria.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 9,
                                fontWeight: FontWeight.w800,
                                color: kNeonCyan,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // ============ DADOS ============
              Expanded(
                flex: 5,
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            anuncio.titulo,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 13,
                              fontWeight: FontWeight.w800,
                              color: Colors.white,
                              height: 1.2,
                              letterSpacing: -0.2,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.visibility_outlined,
                                  size: 11, color: Colors.white38),
                              const SizedBox(width: 4),
                              Text(
                                '${anuncio.visualizacoes} views',
                                style: const TextStyle(
                                    fontSize: 10, color: Colors.white38),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (anuncio.preco != null) ...[
                            Text(
                              'R\$ ${_formatarPreco(anuncio.preco!)}',
                              style: const TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w900,
                                color: kNeonCyan,
                                letterSpacing: -0.5,
                              ),
                            ),
                            const SizedBox(height: 6),
                          ],
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                                vertical: 6, horizontal: 8),
                            decoration: BoxDecoration(
                              color: kNeonCyan.withOpacity(0.05),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: kNeonCyan.withOpacity(0.15)),
                            ),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.lock_outline_rounded,
                                    size: 10, color: kNeonCyan),
                                SizedBox(width: 4),
                                Text(
                                  'CONTATO BLOQUEADO',
                                  style: TextStyle(
                                    fontSize: 9,
                                    fontWeight: FontWeight.w800,
                                    color: kNeonCyan,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholderImagem() {
    return Container(
      color: const Color(0xFF1A2338),
      child: const Center(
        child: Icon(
          Icons.radar_rounded,
          size: 28,
          color: Colors.white24,
        ),
      ),
    );
  }

  String _formatarPreco(double preco) {
    final partes = preco.toStringAsFixed(2).split('.');
    final inteiro = partes[0];
    final decimal = partes[1];

    final buffer = StringBuffer();
    for (int i = 0; i < inteiro.length; i++) {
      if (i > 0 && (inteiro.length - i) % 3 == 0) buffer.write('.');
      buffer.write(inteiro[i]);
    }
    return '$buffer,$decimal';
  }
}

// ============================================================
// ESTADO VAZIO TECNOLÓGICO
// ============================================================
class _EstadoVazioTech extends StatelessWidget {
  final IconData icone;
  final String titulo;
  final String descricao;

  const _EstadoVazioTech({
    required this.icone,
    required this.titulo,
    required this.descricao,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: kNeonCyan.withOpacity(0.05),
                shape: BoxShape.circle,
                border: Border.all(color: kNeonCyan.withOpacity(0.2)),
              ),
              child: Icon(icone, size: 36, color: kNeonCyan),
            ),
            const SizedBox(height: 20),
            Text(
              titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: Colors.white,
                letterSpacing: 1.0,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              descricao,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 12.5,
                color: Colors.white54,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
