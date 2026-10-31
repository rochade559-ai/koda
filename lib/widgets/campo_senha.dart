import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/validators.dart';

class CampoSenha extends StatefulWidget {
  final String label;
  final TextEditingController controller;
  final String? Function(String?)? validator;
  final bool mostrarForca;

  const CampoSenha({
    super.key,
    required this.label,
    required this.controller,
    this.validator,
    this.mostrarForca = false,
  });

  @override
  State<CampoSenha> createState() => _CampoSenhaState();
}

class _CampoSenhaState extends State<CampoSenha> {
  bool _oculta = true;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onChange);
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onChange);
    super.dispose();
  }

  void _onChange() => setState(() {});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        TextFormField(
          controller: widget.controller,
          obscureText: _oculta,
          validator: widget.validator,
          autovalidateMode: AutovalidateMode.onUserInteraction,
          style: const TextStyle(
            fontSize: 15,
            color: AppColors.textDark,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            labelText: widget.label,
            suffixIcon: IconButton(
              icon: Icon(
                _oculta
                    ? Icons.visibility_outlined
                    : Icons.visibility_off_outlined,
                size: 20,
                color: AppColors.textGray,
              ),
              onPressed: () => setState(() => _oculta = !_oculta),
            ),
          ),
        ),
        if (widget.mostrarForca) ...[
          const SizedBox(height: 8),
          _MedidorForca(senha: widget.controller.text),
        ],
      ],
    );
  }
}

class _MedidorForca extends StatelessWidget {
  final String senha;
  const _MedidorForca({required this.senha});

  @override
  Widget build(BuildContext context) {
    if (senha.isEmpty) return const SizedBox.shrink();

    final forca = Validators.forcaSenha(senha);

    final cores = [
      AppColors.error,
      AppColors.warning,
      AppColors.gold,
      const Color(0xFF22C55E),
      AppColors.success,
    ];
    final labels = [
      'Muito fraca',
      'Fraca',
      'Média',
      'Forte',
      'Excelente',
    ];

    final cor = cores[forca];
    final label = labels[forca];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: List.generate(5, (i) {
            final ativo = i <= forca;
            return Expanded(
              child: Container(
                margin: EdgeInsets.only(right: i < 4 ? 4 : 0),
                height: 4,
                decoration: BoxDecoration(
                  color: ativo ? cor : AppColors.borderLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        ),
        const SizedBox(height: 6),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: cor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
