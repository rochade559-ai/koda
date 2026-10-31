class Session {
  Session._();

  // Dados de contato (cadastro)
  static String? nomeResponsavel;
  static String? cargo;
  static String? email;
  static String? whatsapp;

  // Dados da empresa
  static String? cnpj;
  static Map<String, dynamic>? dadosCnpj;

  // Faixa de investimento
  static String? faixaInvestimento;
  static String? faixaInvestimentoLabel;

  // Quiz de Oferta
  static double? equityOferecido;
  static bool participacaoLucros = false;
  static bool royalties = false;
  static bool assentoConselho = false;
  static bool preferenciaCompra = false;
  static String? valuationFaixa;
  static String? prazoRetorno;

  // Pitch PDF
  static String? pitchNomeArquivo;
  static String? pitchUrl;

  static void limpar() {
    nomeResponsavel = null;
    cargo = null;
    email = null;
    whatsapp = null;
    cnpj = null;
    dadosCnpj = null;
    faixaInvestimento = null;
    faixaInvestimentoLabel = null;
    equityOferecido = null;
    participacaoLucros = false;
    royalties = false;
    assentoConselho = false;
    preferenciaCompra = false;
    valuationFaixa = null;
    prazoRetorno = null;
    pitchNomeArquivo = null;
    pitchUrl = null;
  }
}
