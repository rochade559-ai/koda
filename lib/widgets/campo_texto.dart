import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../core/constants/app_colors.dart';

class CampoTexto extends StatelessWidget {
  final String label;
  final TextEditingController controller;
  final TextInputType? keyboard;
  final List<TextInputFormatter>? inputFormatters;
  final String? Function(String?)? validator;
  final int maxLines;

  const CampoTexto({
    super.key,
    required this.label,
    required this.controller,
    this.keyboard,
    this.inputFormatters,
    this.validator,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboard,
      inputFormatters: inputFormatters,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(
        fontSize: 15,
        color: AppColors.textDark,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(labelText: label),
    );
  }
}
