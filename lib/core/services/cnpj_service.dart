import 'dart:convert';
import 'package:http/http.dart' as http;

class CnpjService {
  CnpjService._();

  // Cache em memória para evitar requisições duplicadas e acelerar o app
  static final Map<String, Map<String, dynamic>> _cache = {};

  static Future<Map<String, dynamic>> consultar(String cnpj) async {
    final cnpjLimpo = cnpj.replaceAll(RegExp(r'[^0-9]'), '');

    if (cnpjLimpo.length != 14) {
      throw Exception('CNPJ precisa ter 14 dígitos');
    }

    // Retorna do cache se já foi consultado nesta sessão
    if (_cache.containsKey(cnpjLimpo)) {
      return _cache[cnpjLimpo]!;
    }

    final tentativas = <Future<Map<String, dynamic>> Function()>[
      () => _consultarBrasilApi(cnpjLimpo),
      () => _consultarCnpjWs(cnpjLimpo),
      () => _consultarReceitaWs(cnpjLimpo),
    ];

    for (final tentar in tentativas) {
      try {
        final resultado = await tentar();
        _cache[cnpjLimpo] = resultado; // Salva no cache
        return resultado;
      } catch (_) {
        // Tenta a próxima API silenciosamente
      }
    }

    throw Exception(
      'Não foi possível consultar o CNPJ agora. '
      'Tente novamente em alguns minutos.',
    );
  }

  static Future<Map<String, dynamic>> _consultarBrasilApi(String cnpj) async {
    final url = Uri.parse('https://brasilapi.com.br/api/cnpj/v1/$cnpj');
    final resp = await http.get(url, headers: {
      'Accept': 'application/json'
    }).timeout(const Duration(seconds: 10));

    if (resp.statusCode == 404) throw Exception('CNPJ não encontrado');
    if (resp.statusCode != 200) throw Exception('Erro BrasilAPI');

    return jsonDecode(resp.body) as Map<String, dynamic>;
  }

  static Future<Map<String, dynamic>> _consultarCnpjWs(String cnpj) async {
    final url = Uri.parse('https://publica.cnpj.ws/cnpj/$cnpj');
    final resp = await http.get(url, headers: {
      'Accept': 'application/json'
    }).timeout(const Duration(seconds: 10));

    if (resp.statusCode == 404) throw Exception('CNPJ não encontrado');
    if (resp.statusCode != 200) throw Exception('Erro CNPJ.ws');

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    final estab = (data['estabelecimento'] as Map?) ?? {};
    final atividade = (estab['atividade_principal'] as Map?) ?? {};
    final cidade = (estab['cidade'] as Map?) ?? {};
    final estado = (estab['estado'] as Map?) ?? {};

    return {
      'cnpj': (estab['cnpj'] ?? '').toString(),
      'razao_social': data['razao_social'] ?? '',
      'nome_fantasia': estab['nome_fantasia'] ?? '',
      'email': estab['email'] ?? '',
      'ddd_telefone_1': estab['telefone1'] ?? '',
      'cep': estab['cep'] ?? '',
      'logradouro': estab['logradouro'] ?? '',
      'numero': estab['numero'] ?? '',
      'bairro': estab['bairro'] ?? '',
      'municipio': cidade['descricao'] ?? '',
      'uf': estado['sigla'] ?? '',
      'descricao_situacao_cadastral':
          _mapearSituacao(estab['situacao_cadastral']?.toString() ?? ''),
      'cnae_fiscal_descricao': atividade['descricao'] ?? '',
    };
  }

  static Future<Map<String, dynamic>> _consultarReceitaWs(String cnpj) async {
    final url = Uri.parse('https://receitaws.com.br/v1/cnpj/$cnpj');
    final resp = await http.get(url, headers: {
      'Accept': 'application/json'
    }).timeout(const Duration(seconds: 10));

    if (resp.statusCode != 200) throw Exception('Erro ReceitaWS');

    final data = jsonDecode(resp.body) as Map<String, dynamic>;
    if (data['status'] == 'ERROR') throw Exception('Erro ReceitaWS');

    final atividadePrincipal = data['atividade_principal'] is List &&
            (data['atividade_principal'] as List).isNotEmpty
        ? (data['atividade_principal'][0]['text'] ?? '')
        : '';

    return {
      'cnpj': data['cnpj'] ?? '',
      'razao_social': data['nome'] ?? '',
      'nome_fantasia': data['fantasia'] ?? '',
      'email': data['email'] ?? '',
      'ddd_telefone_1': data['telefone'] ?? '',
      'cep': data['cep'] ?? '',
      'logradouro': data['logradouro'] ?? '',
      'numero': data['numero'] ?? '',
      'bairro': data['bairro'] ?? '',
      'municipio': data['municipio'] ?? '',
      'uf': data['uf'] ?? '',
      'descricao_situacao_cadastral':
          _mapearSituacao(data['situacao']?.toString() ?? ''),
      'cnae_fiscal_descricao': atividadePrincipal,
    };
  }

  static String _mapearSituacao(String valor) {
    switch (valor) {
      case '1':
      case '2':
        return 'ATIVA';
      case '3':
        return 'SUSPENSA';
      case '4':
        return 'INAPTA';
      case '5':
        return 'BAIXADA';
      default:
        return valor.toUpperCase();
    }
  }
}
