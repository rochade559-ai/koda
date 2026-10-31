import 'package:flutter/material.dart';
import '../models/anuncio.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/empresa/cadastro_empresa_screen.dart';
import '../screens/empresa/cnpj_screen.dart';
import '../screens/empresa/quiz_aviso_screen.dart';
import '../screens/empresa/quiz_empresa_screen.dart';
import '../screens/empresa/quiz_bloqueado_screen.dart';
import '../screens/empresa/faixa_investimento_screen.dart';
import '../screens/empresa/quiz_oferta_screen.dart';
import '../screens/empresa/pitch_screen.dart';
import '../screens/empresa/confirmacao_empresa_screen.dart';
import '../screens/investidor/cadastro_investidor_screen.dart';
import '../screens/investidor/quiz_investidor_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/cadastro_screen.dart';
import '../screens/auth/recuperar_senha_screen.dart';
import '../screens/auth/verificar_email_screen.dart';
import '../screens/auth/salvar_lead_screen.dart';
import '../screens/auth/lead_salvo_screen.dart';
import '../screens/admin/admin_screen.dart';
import '../screens/perfil/status_screen.dart';
import '../screens/perfil/configuracoes_screen.dart';
import '../screens/market/market_feed_screen.dart';
import '../screens/market/anuncio_detalhe_screen.dart';
import '../screens/market/criar_anuncio_screen.dart';
import '../screens/market/comprar_cryptons_screen.dart';
import '../screens/market/carteira_screen.dart';
import '../screens/leads/captacao_construcao_screen.dart';
import '../screens/servicos/ajuda_especializada_screen.dart';

class AppRoutes {
  AppRoutes._();

  static const String splash = '/';
  static const String home = '/home';

  // Empresa
  static const String cadastroEmpresa = '/empresa/cadastro';
  static const String cnpjEmpresa = '/empresa/cnpj';
  static const String quizAviso = '/empresa/quiz-aviso';
  static const String quizEmpresa = '/empresa/quiz';
  static const String quizBloqueado = '/empresa/quiz-bloqueado';
  static const String faixaInvestimento = '/empresa/faixa';
  static const String quizOferta = '/empresa/quiz-oferta';
  static const String pitchEmpresa = '/empresa/pitch';
  static const String confirmacaoEmpresa = '/empresa/confirmacao';

  // Investidor
  static const String cadastroInvestidor = '/investidor/cadastro';
  static const String quizInvestidor = '/investidor/quiz';

  // Auth
  static const String login = '/auth/login';
  static const String cadastroConta = '/auth/cadastro';
  static const String recuperarSenha = '/auth/recuperar-senha';
  static const String verificarEmail = '/auth/verificar-email';
  static const String salvarLead = '/auth/salvar-lead';
  static const String leadSalvo = '/auth/lead-salvo';

  // Admin + Perfil
  static const String admin = '/admin';
  static const String status = '/status';
  static const String configuracoes = '/configuracoes';

  // Market
  static const String market = '/market';
  static const String criarAnuncio = '/market/criar';
  static const String anuncioDetalhe = '/market/detalhe';

  // Cryptons
  static const String comprarCryptons = '/market/comprar-cryptons';
  static const String carteira = '/market/carteira';

  // Leads — Permuta/Construção
  static const String captacaoConstrucao = '/leads/captacao-construcao';

  // Serviços — Ajuda Especializada
  static const String ajudaEspecializada = '/servicos/ajuda-especializada';

  static Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    home: (_) => const HomeScreen(),

    // Empresa
    cadastroEmpresa: (_) => const CadastroEmpresaScreen(),
    cnpjEmpresa: (_) => const CnpjScreen(),
    quizAviso: (_) => const QuizAvisoScreen(),
    quizEmpresa: (_) => const QuizEmpresaScreen(),
    quizBloqueado: (ctx) {
      final args = ModalRoute.of(ctx)?.settings.arguments;
      final dias = args is int ? args : 3;
      return QuizBloqueadoScreen(diasRestantes: dias);
    },
    faixaInvestimento: (_) => const FaixaInvestimentoScreen(),
    quizOferta: (_) => const QuizOfertaScreen(),
    pitchEmpresa: (_) => const PitchScreen(),
    confirmacaoEmpresa: (_) => const ConfirmacaoEmpresaScreen(),

    // Investidor
    cadastroInvestidor: (_) => const CadastroInvestidorScreen(),
    quizInvestidor: (_) => const QuizInvestidorScreen(),

    // Auth
    login: (_) => const LoginScreen(),
    cadastroConta: (ctx) {
      final tipo = ModalRoute.of(ctx)?.settings.arguments as String?;
      return CadastroScreen(tipo: tipo ?? 'empresa');
    },
    recuperarSenha: (_) => const RecuperarSenhaScreen(),
    verificarEmail: (ctx) {
      final email = ModalRoute.of(ctx)?.settings.arguments as String? ?? '';
      return VerificarEmailScreen(email: email);
    },
    salvarLead: (ctx) {
      final args = ModalRoute.of(ctx)?.settings.arguments;
      if (args is Map<String, dynamic>) {
        return SalvarLeadScreen(
          tipo: args['tipo'] ?? 'empresa',
          respostas: args['respostas'],
        );
      }
      return const SalvarLeadScreen(tipo: 'empresa');
    },
    leadSalvo: (_) => const LeadSalvoScreen(),

    // Admin + Perfil
    admin: (_) => const AdminScreen(),
    status: (_) => const StatusScreen(),
    configuracoes: (_) => const ConfiguracoesScreen(),

    // Market
    market: (_) => const MarketFeedScreen(),
    criarAnuncio: (_) => const CriarAnuncioScreen(),
    anuncioDetalhe: (ctx) {
      final args = ModalRoute.of(ctx)?.settings.arguments;
      if (args is Anuncio) {
        return AnuncioDetalheScreen(anuncio: args);
      }
      return const SizedBox.shrink();
    },

    // Cryptons
    comprarCryptons: (_) => const ComprarCryptonsScreen(),
    carteira: (_) => const CarteiraScreen(),

    // Leads — Permuta/Construção
    captacaoConstrucao: (_) => const CaptacaoConstrucaoScreen(),

    // Serviços — Ajuda Especializada
    ajudaEspecializada: (_) => const AjudaEspecializadaScreen(),
  };
}
