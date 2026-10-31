import 'package:cloud_functions/cloud_functions.dart';

import '../../models/carteira.dart';

class CryptonService {
  CryptonService._();

  static final FirebaseFunctions _functions = FirebaseFunctions.instanceFor(
    region: 'southamerica-east1',
  );

  static const int cryptonPorDesbloqueio = 25;

  // ============================================================
  // LISTAR PACOTES
  // ============================================================
  static Future<List<PacoteCrypton>> listarPacotes() async {
    try {
      final callable = _functions.httpsCallable('listarPacotesCrypton');
      final result = await callable.call();
      final data = Map<String, dynamic>.from(result.data);
      final lista = (data['pacotes'] as List?) ?? [];
      return lista
          .map((p) => PacoteCrypton.fromMap(Map<String, dynamic>.from(p)))
          .toList();
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro ao listar pacotes');
    }
  }

  // ============================================================
  // CONSULTAR CARTEIRA (saldo + histórico)
  // ============================================================
  static Future<Map<String, dynamic>> consultarCarteira() async {
    try {
      final callable = _functions.httpsCallable('consultarCarteira');
      final result = await callable.call();
      final data = Map<String, dynamic>.from(result.data);

      final comprasList = (data['compras'] as List?) ?? [];
      final usosList = (data['usos'] as List?) ?? [];

      return {
        'saldo': data['saldo'] ?? 0,
        'compras': comprasList
            .map((c) => CompraToken.fromMap(
                  Map<String, dynamic>.from(c),
                  c['id'] ?? '',
                ))
            .toList(),
        'usos': usosList
            .map((u) => UsoToken.fromMap(
                  Map<String, dynamic>.from(u),
                  u['id'] ?? '',
                ))
            .toList(),
      };
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro ao consultar carteira');
    }
  }

  // ============================================================
  // CRIAR SESSÃO DE CHECKOUT STRIPE
  // Retorna a URL do checkout da Stripe.
  // ============================================================
  static Future<Map<String, dynamic>> criarLinkPagamento({
    required String pacoteId,
  }) async {
    try {
      final callable = _functions.httpsCallable('criarSessaoCheckoutStripe');

      final result = await callable.call({
        'pacoteId': pacoteId,
      });

      final data = Map<String, dynamic>.from(result.data);
      return {
        'checkoutUrl': data['checkoutUrl'] ?? '',
        'sessionId': data['sessionId'] ?? '',
      };
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro ao criar checkout');
    }
  }

  // ============================================================
  // DESBLOQUEAR CONTATO COM CRYPTONS
  // ============================================================
  static Future<int> desbloquearComCrypton(String anuncioId) async {
    try {
      final callable = _functions.httpsCallable('desbloquearComCrypton');
      final result = await callable.call({'anuncioId': anuncioId});
      final data = Map<String, dynamic>.from(result.data);
      return data['saldo_restante'] ?? 0;
    } on FirebaseFunctionsException catch (e) {
      throw Exception(e.message ?? 'Erro ao desbloquear');
    }
  }
}
