import 'package:flutter/material.dart';

/// Paleta moderna Business / High-Tech da Kodaff.
///
/// Contém tanto as cores novas do redesign (electricBlue, gold cyber)
/// quanto as cores antigas que ainda são usadas em telas legadas
/// (success, error, warning) para não quebrar nada.
class AppColors {
  AppColors._();

  // ============================================================
  // CORES DO REDESIGN HIGH-TECH
  // ============================================================
  static const Color background = Color(0xFFF8FAFC); // Clean Light
  static const Color primary = Color(0xFF0F172A); // Deep Navy
  static const Color primaryDark = Color(0xFF020617); // Quase preto
  static const Color electricBlue = Color(0xFF2563EB); // Azul elétrico
  static const Color electricBlueLight = Color(0xFF60A5FA);
  static const Color gold = Color(0xFFD97706); // Cyber Gold
  static const Color goldLight = Color(0xFFFBBF24);
  static const Color cardBg = Colors.white;
  static const Color textDark = Color(0xFF0F172A);
  static const Color textGray = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8); // ← ADICIONADO
  static const Color borderLight = Color(0xFFE2E8F0);

  // ============================================================
  // ALIASES (mantém compatibilidade com telas antigas)
  // ============================================================
  static const Color surface = Color(0xFFFFFFFF);
  static const Color border = Color(0xFFE2E8F0);

  // ============================================================
  // FEEDBACK
  // ============================================================
  static const Color success = Color(0xFF10B981);
  static const Color error = Color(0xFFEF4444);
  static const Color warning = Color(0xFFF59E0B);
}
