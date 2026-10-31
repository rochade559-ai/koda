import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/utils/validators.dart';

class CampoEmail extends StatefulWidget {
  final TextEditingController controller;
  final String label;

  const CampoEmail({
    super.key,
    required this.controller,
    this.label = 'E-mail',
  });

  @override
  State<CampoEmail> createState() => _CampoEmailState();
}

class _CampoEmailState extends State<CampoEmail> {
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

  void _onChange() {
    if (mounted) setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final texto = widget.controller.text.trim();
    final erro = texto.isEmpty ? null : Validators.emailProfissional(texto);
    final valido = texto.isNotEmpty && erro == null;
    final invalido = texto.isNotEmpty && erro != null;

    IconData? sufixoIcone;
    Color? sufixoCor;
    if (valido) {
      sufixoIcone = Icons.check_circle_rounded;
      sufixoCor = AppColors.success;
    } else if (invalido) {
      sufixoIcone = Icons.error_rounded;
      sufixoCor = AppColors.error;
    }

    return TextFormField(
      controller: widget.controller,
      keyboardType: TextInputType.emailAddress,
      autovalidateMode: AutovalidateMode.onUserInteraction,
      validator: Validators.emailProfissional,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.textDark,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        labelText: widget.label,
        suffixIcon: sufixoIcone == null
            ? null
            : Icon(sufixoIcone, color: sufixoCor, size: 20),
      ),
    );
  }
}
