class Validators {
  Validators._();

  // ============================================================
  // LISTA DE PALAVRÕES / CONTEÚDO INAPROPRIADO
  // ============================================================
  static const List<String> _palavroes = [
    // Sexuais / explícitos
    'sexo', 'sexual', 'porn', 'porno', 'pornografia',
    'puta', 'putaria', 'puto', 'prostitut', 'prostitu',
    'pinto', 'pica', 'pênis', 'penis', 'buceta', 'boceta',
    'xoxota', 'vagina', 'peito', 'peitos', 'seios',
    'cu', 'cú', 'anus', 'ânus', 'orgia', 'orgias',
    'chupa', 'chupar', 'chupeta', 'mamar', 'mamada',
    'gozar', 'gozo', 'ejacul', 'tesao', 'tesão',
    'ninfoman', 'ninfeta', 'safada', 'safado', 'piranha',
    'boquete', 'punheta', 'siririca', 'masturb',
    'tarado', 'tarada', 'pedofil', 'pedofilia',
    'estupr', 'estupro', 'transar', 'transa', 'trepar',
    'corno', 'corna', 'vadia', 'vadio',
    'rapariga', 'rameira', 'meretriz',
    'cacete', 'caralho', 'caraio', 'porra', 'poha',
    'foder', 'fuder', 'foda', 'fodas', 'fodão',
    'viado', 'viada', 'veado', 'bicha', 'boiola',
    'traveco', 'travesti',
    'nudes', 'nude', 'pelada', 'pelado',

    // Ofensas
    'idiota', 'imbecil', 'otario', 'otária', 'otário',
    'babaca', 'escroto', 'escrota', 'bosta', 'merda',
    'arrombado', 'arrombada', 'desgraçad',
    'vagabund', 'canalha', 'pilantra', 'safad',
    'retardad', 'mongol', 'mongoloide',
    'aleijado', 'aleijada',
    'analfabet',

    // Drogas / crimes
    'maconha', 'cocaina', 'cocaína', 'crack', 'heroina', 'heroína',
    'ecstasy', 'traficante', 'trafico', 'tráfico',
    'assassino', 'assassina', 'matador',
    'ladrao', 'ladrão', 'furto', 'roubo', 'roubar',
    'estelionato', 'estelionatario', 'estelionatário',
    'pedofilo', 'pedófilo', 'pedofila',

    // Golpes / fraude
    'golpe', 'golpista', 'fraude', 'fraudulento',
    'pirata', 'pirataria', 'contrabando', 'contrabandista',
    'corrupcao', 'corrupção', 'corrupto', 'corrupta',
    'suborno', 'propina',

    // Extremos
    'nazist', 'nazismo', 'hitler',
    'suicidio', 'suicídio', 'suicida',
  ];

  // ============================================================
  // DOMÍNIOS DE EMAIL CONHECIDOS
  // ============================================================
  static const List<String> _dominiosValidos = [
    'gmail.com',
    'googlemail.com',
    'hotmail.com',
    'outlook.com',
    'outlook.com.br',
    'live.com',
    'msn.com',
    'yahoo.com',
    'yahoo.com.br',
    'icloud.com',
    'me.com',
    'mac.com',
    'protonmail.com',
    'proton.me',
    'aol.com',
    'zoho.com',
    'uol.com.br',
    'bol.com.br',
    'terra.com.br',
    'ig.com.br',
    'globo.com',
    'globomail.com',
    'r7.com',
    'oi.com.br',
    'sapo.pt',
    'tutanota.com',
    'gmx.com',
    'gmx.net',
    'yandex.com',
    'fastmail.com',
  ];

  // ============================================================
  // VERIFICA SE UM TEXTO CONTÉM PALAVRÃO
  // ============================================================
  static bool contemPalavrao(String texto) {
    if (texto.trim().isEmpty) return false;

    final normalizado = _normalizar(texto);
    final palavras = normalizado.split(RegExp(r'[^a-z0-9]+'));

    for (final palavra in palavras) {
      if (palavra.isEmpty) continue;

      for (final bloqueada in _palavroes) {
        final bloqueadaNorm = _normalizar(bloqueada).trim();
        if (bloqueadaNorm.isEmpty) continue;

        // Regra:
        // - Palavras CURTAS (<= 5 letras): match EXATO
        // - Palavras LONGAS (> 5 letras): match por substring
        if (bloqueadaNorm.length <= 5) {
          if (palavra == bloqueadaNorm) return true;
        } else {
          if (palavra == bloqueadaNorm) return true;
          if (palavra.contains(bloqueadaNorm)) return true;
        }
      }
    }

    return false;
  }

  // ============================================================
  // REMOVE ACENTOS E CAIXA
  // ============================================================
  static String _normalizar(String s) {
    const comAcento = 'áàãâäéèêëíìîïóòõôöúùûüçÁÀÃÂÄÉÈÊËÍÌÎÏÓÒÕÔÖÚÙÛÜÇ';
    const semAcento = 'aaaaaeeeeiiiiooooouuuucAAAAAEEEEIIIIOOOOOUUUUC';

    var resultado = s.toLowerCase();
    for (int i = 0; i < comAcento.length; i++) {
      resultado = resultado.replaceAll(comAcento[i], semAcento[i]);
    }
    return resultado;
  }

  // ============================================================
  // VALIDAÇÃO DE NOME COMPLETO
  // ============================================================
  static String? nome(String? value, {int minPalavras = 2}) {
    final nome = value?.trim() ?? '';
    if (nome.isEmpty) return 'Campo obrigatório';

    if (contemPalavrao(nome)) {
      return 'O texto contém termos não permitidos.';
    }

    if (!RegExp(r"^[a-zA-ZÀ-ÿ\s'\-]+$").hasMatch(nome)) {
      return 'Use apenas letras.';
    }

    final partes =
        nome.split(RegExp(r'\s+')).where((p) => p.isNotEmpty).toList();
    if (partes.length < minPalavras) {
      return 'Insira seu nome completo (nome e sobrenome).';
    }

    for (final p in partes) {
      if (p.length < 2) return 'Nome inválido.';
    }

    return null;
  }

  // ============================================================
  // VALIDAÇÃO DE TEXTO GENÉRICO (cargo, empresa, etc)
  // ============================================================
  static String? textoGenerico(String? value, {int min = 2}) {
    final t = value?.trim() ?? '';
    if (t.isEmpty) return 'Campo obrigatório';
    if (t.length < min) return 'Muito curto.';
    if (contemPalavrao(t)) {
      return 'O texto contém termos não permitidos.';
    }
    return null;
  }

  // ============================================================
  // VALIDAÇÃO DE E-MAIL BÁSICA (legado)
  // ============================================================
  static String? email(String? value) {
    final email = value?.trim() ?? '';
    if (email.isEmpty) return 'Campo obrigatório';

    if (contemPalavrao(email)) {
      return 'O e-mail contém termos não permitidos.';
    }

    final regex = RegExp(
      r"^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$",
    );
    if (!regex.hasMatch(email)) {
      return 'E-mail inválido.';
    }

    return null;
  }

  // ============================================================
  // VALIDAÇÃO DE E-MAIL PROFISSIONAL (anti-fake)
  // ============================================================
  static String? emailProfissional(String? value) {
    final email = value?.trim().toLowerCase() ?? '';
    if (email.isEmpty) return 'Campo obrigatório';
    if (contemPalavrao(email)) {
      return 'O e-mail contém termos não permitidos.';
    }

    // Regex básico
    final regex = RegExp(
      r'^[a-zA-Z0-9._%+\-]+@[a-zA-Z0-9.\-]+\.[a-zA-Z]{2,}$',
    );
    if (!regex.hasMatch(email)) return 'E-mail inválido.';

    final partes = email.split('@');
    if (partes.length != 2) return 'E-mail inválido.';
    final local = partes[0];
    final dominio = partes[1];

    // Mínimo de tamanho local
    if (local.length < 3) return 'E-mail muito curto.';

    // Local não pode ser só números
    if (RegExp(r'^[0-9]+$').hasMatch(local)) {
      return 'E-mail inválido.';
    }

    // Não pode ter 4+ caracteres repetidos seguidos (aaa, 1111)
    if (RegExp(r'(.)\1{3,}').hasMatch(local)) {
      return 'E-mail inválido.';
    }

    // Não pode ter sequência de teclado
    const sequencias = [
      'qwert',
      'asdfg',
      'zxcvb',
      'qazwsx',
      '123456',
      '654321',
      'abcdef',
      'fedcba',
      'aaaaa',
      'bbbbb',
    ];
    for (final s in sequencias) {
      if (local.contains(s)) return 'E-mail inválido.';
    }

    // Domínio precisa ter ponto
    if (!dominio.contains('.')) return 'Domínio de e-mail inválido.';

    // Aviso apenas se for domínio totalmente desconhecido
    // (não bloqueia, pois empresas têm domínios próprios)
    // if (!_dominiosValidos.contains(dominio)) { ... }

    return null;
  }

  // ============================================================
  // VALIDAÇÃO DE SENHA FORTE
  // ============================================================
  static List<String> problemasSenha(String senha) {
    final problemas = <String>[];
    if (senha.length < 8) problemas.add('Mínimo 8 caracteres');
    if (!RegExp(r'[A-Z]').hasMatch(senha)) {
      problemas.add('Pelo menos 1 letra maiúscula');
    }
    if (!RegExp(r'[a-z]').hasMatch(senha)) {
      problemas.add('Pelo menos 1 letra minúscula');
    }
    if (!RegExp(r'[0-9]').hasMatch(senha)) {
      problemas.add('Pelo menos 1 número');
    }
    if (!RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\[\]\/\\+=~`]').hasMatch(senha)) {
      problemas.add('Pelo menos 1 caractere especial (!@#\$%...)');
    }
    return problemas;
  }

  /// Retorna null se a senha for forte, ou mensagem resumida.
  static String? senha(String? value) {
    final s = value ?? '';
    if (s.isEmpty) return 'Campo obrigatório';
    final p = problemasSenha(s);
    if (p.isEmpty) return null;
    return 'Senha fraca: ${p.first}';
  }

  /// Nível de força: 0 a 4 (0 = muito fraca, 4 = excelente)
  static int forcaSenha(String senha) {
    int score = 0;
    if (senha.length >= 8) score++;
    if (senha.length >= 12) score++;
    if (RegExp(r'[A-Z]').hasMatch(senha) && RegExp(r'[a-z]').hasMatch(senha)) {
      score++;
    }
    if (RegExp(r'[0-9]').hasMatch(senha)) score++;
    if (RegExp(r'[!@#\$%^&*(),.?":{}|<>_\-\[\]\/\\+=~`]').hasMatch(senha)) {
      score++;
    }
    return score.clamp(0, 4);
  }

  // ============================================================
  // VALIDAÇÃO DE WHATSAPP (DDD + 8 ou 9 dígitos)
  // ============================================================
  static String? whatsapp(String? value) {
    final raw = value ?? '';
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.isEmpty) return 'Campo obrigatório';
    if (digits.length < 10 || digits.length > 11) {
      return 'Número incompleto. Use DDD + número.';
    }

    final ddd = int.tryParse(digits.substring(0, 2));
    if (ddd == null || ddd < 11 || ddd > 99) {
      return 'DDD inválido.';
    }

    if (digits.length == 11 && digits[2] != '9') {
      return 'Celular deve começar com 9 após o DDD.';
    }

    return null;
  }

  // ============================================================
  // VALIDAÇÃO DE CNPJ (formato)
  // ============================================================
  static String? cnpj(String? value) {
    final raw = value ?? '';
    final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.isEmpty) return 'Campo obrigatório';
    if (digits.length != 14) return 'CNPJ precisa ter 14 dígitos.';
    return null;
  }
}
