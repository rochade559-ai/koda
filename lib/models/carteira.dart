class Carteira {
  final String uid;
  final String email;
  final int saldoCryptons;
  final int totalComprado;
  final int totalGasto;

  Carteira({
    required this.uid,
    required this.email,
    required this.saldoCryptons,
    required this.totalComprado,
    required this.totalGasto,
  });

  factory Carteira.fromMap(Map<String, dynamic> map) {
    return Carteira(
      uid: map['uid'] ?? '',
      email: map['email'] ?? '',
      saldoCryptons: (map['saldo_cryptons'] ?? 0).toInt(),
      totalComprado: (map['total_comprado'] ?? 0).toInt(),
      totalGasto: (map['total_gasto'] ?? 0).toInt(),
    );
  }

  int get desbloqueiosDisponiveis => saldoCryptons ~/ 25;
}

class CompraToken {
  final String id;
  final String pacote;
  final int cryptons;
  final double valor;
  final String status;
  final DateTime? criadoEm;

  CompraToken({
    required this.id,
    required this.pacote,
    required this.cryptons,
    required this.valor,
    required this.status,
    this.criadoEm,
  });

  factory CompraToken.fromMap(Map<String, dynamic> map, String id) {
    return CompraToken(
      id: id,
      pacote: map['pacote'] ?? '',
      cryptons: (map['cryptons'] ?? 0).toInt(),
      valor: (map['valor'] as num?)?.toDouble() ?? 0,
      status: map['status'] ?? 'pendente',
      criadoEm: _parseData(map['criado_em']),
    );
  }
}

class UsoToken {
  final String id;
  final String anuncioTitulo;
  final int cryptons;
  final DateTime? criadoEm;

  UsoToken({
    required this.id,
    required this.anuncioTitulo,
    required this.cryptons,
    this.criadoEm,
  });

  factory UsoToken.fromMap(Map<String, dynamic> map, String id) {
    return UsoToken(
      id: id,
      anuncioTitulo: map['anuncio_titulo'] ?? 'Anúncio',
      cryptons: (map['cryptons'] ?? 0).toInt(),
      criadoEm: _parseData(map['criado_em']),
    );
  }
}

class PacoteCrypton {
  final String id;
  final String nome;
  final int cryptons;
  final int precoCentavos;
  final String descricao;

  PacoteCrypton({
    required this.id,
    required this.nome,
    required this.cryptons,
    required this.precoCentavos,
    required this.descricao,
  });

  double get preco => precoCentavos / 100;

  int get desbloqueios => cryptons ~/ 25;

  double get precoPorDesbloqueio => desbloqueios > 0 ? preco / desbloqueios : 0;

  factory PacoteCrypton.fromMap(Map<String, dynamic> map) {
    return PacoteCrypton(
      id: map['id'] ?? '',
      nome: map['nome'] ?? '',
      cryptons: (map['cryptons'] ?? 0).toInt(),
      precoCentavos: (map['precoCentavos'] ?? 0).toInt(),
      descricao: map['descricao'] ?? '',
    );
  }
}

/// Helper para converter string ISO em DateTime
DateTime? _parseData(dynamic valor) {
  if (valor == null) return null;
  if (valor is DateTime) return valor;
  try {
    return DateTime.parse(valor.toString());
  } catch (_) {
    return null;
  }
}
