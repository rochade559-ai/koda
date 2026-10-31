import 'package:shared_preferences/shared_preferences.dart';

class QuizGuard {
  QuizGuard._();

  static const String _prefix = 'quiz_block_';
  static const int _blockDays = 3;

  /// Chave do bloqueio: EMAIL + CNPJ (normalizados).
  /// Ex: "matheus@gmail.com|00000000000191"
  static String _key(String email, String cnpj) {
    final e = email.toLowerCase().trim().replaceAll(RegExp(r'\s+'), '');
    final c = cnpj.replaceAll(RegExp(r'[^0-9]'), '');
    return '$_prefix$e|$c';
  }

  /// Retorna true se o usuário está bloqueado (email + CNPJ).
  static Future<bool> isBlocked(String email, String cnpj) async {
    if (email.isEmpty || cnpj.isEmpty) return false;
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_key(email, cnpj));
    if (ts == null) return false;

    final diff = DateTime.now().millisecondsSinceEpoch - ts;
    final blockMs = _blockDays * 24 * 60 * 60 * 1000;
    return diff < blockMs;
  }

  /// Retorna quantos dias faltam para liberar (0 se não bloqueado).
  static Future<int> diasRestantes(String email, String cnpj) async {
    if (email.isEmpty || cnpj.isEmpty) return 0;
    final prefs = await SharedPreferences.getInstance();
    final ts = prefs.getInt(_key(email, cnpj));
    if (ts == null) return 0;

    final diff = DateTime.now().millisecondsSinceEpoch - ts;
    final blockMs = _blockDays * 24 * 60 * 60 * 1000;
    if (diff >= blockMs) return 0;

    final restante = blockMs - diff;
    return (restante / (24 * 60 * 60 * 1000)).ceil();
  }

  /// Bloqueia o usuário por 3 dias (email + CNPJ).
  static Future<void> bloquear(String email, String cnpj) async {
    if (email.isEmpty || cnpj.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      _key(email, cnpj),
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  /// Limpa o bloqueio (uso admin/teste).
  static Future<void> limparBloqueio(String email, String cnpj) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key(email, cnpj));
  }
}
