import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Loading do Kodaff — idêntico ao web/index.html
class LoadingKodaff extends StatefulWidget {
  final double size;
  final Color corPrimaria;
  final Color? corSecundaria;
  final Color? corDestaque;
  final Color? corTexto;
  final String? texto;

  const LoadingKodaff({
    super.key,
    this.size = 220,
    this.corPrimaria = const Color(0xFF00E5FF),
    this.corSecundaria,
    this.corDestaque,
    this.corTexto,
    this.texto,
  });

  @override
  State<LoadingKodaff> createState() => _LoadingKodaffState();
}

class _LoadingKodaffState extends State<LoadingKodaff>
    with TickerProviderStateMixin {
  late AnimationController _ringCtrl;
  late AnimationController _ring2Ctrl;
  late AnimationController _glowCtrl;
  late AnimationController _scanCtrl;

  final Color dourado = const Color(0xFFFBBF24);

  @override
  void initState() {
    super.initState();
    _ringCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
    )..repeat();

    _ring2Ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 6000),
    )..repeat();

    _glowCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    )..repeat(reverse: true);

    _scanCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    )..repeat();
  }

  @override
  void dispose() {
    _ringCtrl.dispose();
    _ring2Ctrl.dispose();
    _glowCtrl.dispose();
    _scanCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = widget.size;
    final cor = widget.corPrimaria;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // ============ ANEL + IMPRESSÃO DIGITAL ============
        SizedBox(
          width: size,
          height: size,
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Anel 1 (girando) — usando CustomPaint em vez de Border
              AnimatedBuilder(
                animation: _ringCtrl,
                builder: (_, __) {
                  return Transform.rotate(
                    angle: _ringCtrl.value * 2 * math.pi,
                    child: CustomPaint(
                      size: Size(size, size),
                      painter: _RingPainter(cor: cor),
                    ),
                  );
                },
              ),
              // Anel 2 (tracejado, girando ao contrário)
              Padding(
                padding: EdgeInsets.all(size * 0.07),
                child: AnimatedBuilder(
                  animation: _ring2Ctrl,
                  builder: (_, __) {
                    return Transform.rotate(
                      angle: -_ring2Ctrl.value * 2 * math.pi,
                      child: CustomPaint(
                        size: Size(size, size),
                        painter: _DashedRingPainter(cor: dourado),
                      ),
                    );
                  },
                ),
              ),
              // Glow interno
              AnimatedBuilder(
                animation: _glowCtrl,
                builder: (_, __) {
                  return Container(
                    margin: EdgeInsets.all(size * 0.18),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: RadialGradient(
                        colors: [
                          cor.withOpacity(0.15 + 0.15 * _glowCtrl.value),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  );
                },
              ),
              // Impressão digital + scan
              SizedBox(
                width: size * 0.58,
                height: size * 0.58,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    AnimatedBuilder(
                      animation: _glowCtrl,
                      builder: (_, __) {
                        return Opacity(
                          opacity: 0.65 + 0.35 * _glowCtrl.value,
                          child: CustomPaint(
                            size: Size(size * 0.58, size * 0.58),
                            painter: _FingerprintPainter(cor: cor),
                          ),
                        );
                      },
                    ),
                    // Linha de scan
                    AnimatedBuilder(
                      animation: _scanCtrl,
                      builder: (_, __) {
                        final t = _scanCtrl.value;
                        final top = size * 0.58 * (0.10 + t * 0.78);
                        final opacity = t < 0.5 ? 0.3 + t * 1.4 : 1.7 - t * 1.4;
                        return Positioned(
                          top: top,
                          left: size * 0.58 * 0.05,
                          right: size * 0.58 * 0.05,
                          child: Opacity(
                            opacity: opacity.clamp(0.3, 1.0),
                            child: Container(
                              height: 2,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(2),
                                gradient: LinearGradient(
                                  colors: [
                                    Colors.transparent,
                                    dourado,
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: dourado.withOpacity(0.5),
                                    blurRadius: 14,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        SizedBox(height: size * 0.18),

        // ============ TEXTOS + BARRA ============
        SizedBox(
          width: size * 1.16,
          child: Column(
            children: [
              Text(
                'KODAFF',
                style: TextStyle(
                  color: const Color(0xFFF1F5F9),
                  fontSize: size * 0.11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: size * 0.045,
                  shadows: [
                    Shadow(
                      color: cor.withOpacity(0.6),
                      blurRadius: 12,
                    ),
                  ],
                ),
              ),
              SizedBox(height: size * 0.05),
              Text(
                widget.texto ?? 'INICIALIZANDO…',
                style: TextStyle(
                  color: const Color(0xFF94A3B8),
                  fontSize: size * 0.055,
                  fontWeight: FontWeight.w500,
                  letterSpacing: size * 0.022,
                ),
              ),
              SizedBox(height: size * 0.05),
              ClipRRect(
                borderRadius: BorderRadius.circular(999),
                child: Container(
                  height: 4,
                  color: Colors.white.withOpacity(0.08),
                  child: AnimatedBuilder(
                    animation: _scanCtrl,
                    builder: (_, __) {
                      final p = _scanCtrl.value * 90;
                      return FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: (p / 100).clamp(0.05, 0.95),
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [cor, dourado],
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: cor.withOpacity(0.6),
                                blurRadius: 10,
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),
              SizedBox(height: size * 0.03),
              Text(
                'CARREGANDO',
                style: TextStyle(
                  color: const Color(0xFF94A3B8),
                  fontSize: size * 0.05,
                  fontFamily: 'monospace',
                  letterSpacing: 2,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// Anel sólido girando (arco de ~270°)
// ============================================================
class _RingPainter extends CustomPainter {
  final Color cor;
  _RingPainter({required this.cor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..strokeCap = StrokeCap.round;

    final glow = Paint()
      ..color = cor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final rect = Rect.fromCircle(
      center: Offset(size.width / 2, size.height / 2),
      radius: size.width / 2 - 2,
    );

    // Arco de 270° (deixa um "vão" — efeito girando)
    canvas.drawArc(rect, 0, math.pi * 1.5, false, glow);
    canvas.drawArc(rect, 0, math.pi * 1.5, false, paint);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) => old.cor != cor;
}

// ============================================================
// Anel tracejado
// ============================================================
class _DashedRingPainter extends CustomPainter {
  final Color cor;
  _DashedRingPainter({required this.cor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - 2;
    final dashCount = 24;

    for (int i = 0; i < dashCount; i++) {
      final startAngle = (i * 2 * math.pi) / dashCount;
      final sweepAngle = (2 * math.pi) / dashCount / 2;
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _DashedRingPainter old) => old.cor != cor;
}

// ============================================================
// Impressão digital
// ============================================================
class _FingerprintPainter extends CustomPainter {
  final Color cor;
  _FingerprintPainter({required this.cor});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = cor
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.05
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final glow = Paint()
      ..color = cor.withOpacity(0.4)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.10
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4);

    final s = size.width / 24.0;
    final path = Path();

    void move(double x, double y) => path.moveTo(x * s, y * s);

    // P1
    move(12, 10);
    path.relativeQuadraticBezierTo(-1.1, 0.3, -1.9, 2);
    path.relativeCubicTo(-0.05, 0.7, -0.1, 1.5, -0.16, 2.5);
    path.relativeLineTo(-0.1, 1.5);

    // P2
    move(14, 13.12);
    path.relativeCubicTo(0, 2.38, 0, 6.38, -1, 8.88);

    // P3
    move(17.29, 21.02);
    path.relativeCubicTo(0.12, -0.6, 0.43, -2.3, 0.5, -3.02);

    // P4
    move(2, 12);
    path.arcToPoint(Offset(20 * s, 6 * s),
        radius: Radius.circular(10 * s), clockwise: true);

    // P5
    move(2, 16);
    path.lineTo(2.01 * s, 16 * s);

    // P6
    move(21.8, 16);
    path.relativeCubicTo(0.2, -2, 0.131, -5.354, 0, -6);

    // P7
    move(5, 19.5);
    path.relativeCubicTo(0.5, -1.5, 1, -4.5, 1, -7.5);
    path.arcToPoint(Offset(6.34 * s, 10 * s),
        radius: Radius.circular(6 * s), clockwise: true);

    // P8
    move(8.65, 22);
    path.relativeCubicTo(0.21, -0.66, 0.45, -1.32, 0.57, -2);

    // P9
    move(9, 6.8);
    path.arcToPoint(Offset(18 * s, 12 * s),
        radius: Radius.circular(6 * s), clockwise: true);
    path.relativeLineTo(0, 2);

    canvas.drawPath(path, glow);
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _FingerprintPainter old) => old.cor != cor;
}
