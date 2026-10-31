import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AnunciosService {
  AnunciosService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  static const List<Map<String, String>> categorias = [
    {'id': 'terras', 'label': 'Terras e Fazendas', 'emoji': ''},
    {'id': 'ouro', 'label': 'Ouro e Pedras', 'emoji': ''},
    {'id': 'empresas', 'label': 'Venda sua Empresa', 'emoji': ''},
    {'id': 'maquinario', 'label': 'Maquinário', 'emoji': ''},
    {'id': 'tecnologia', 'label': 'Venda sua Tecnologia', 'emoji': ''},
    {'id': 'outros', 'label': 'Outros', 'emoji': ''},
  ];

  // ============================================================
  // CRIAR ANÚNCIO
  // ============================================================
  static Future<String> criarAnuncio({
    required String titulo,
    required String categoria,
    required String descricao,
    required double? preco,
    required List<String> fotos,
    required String emailContato,
    required String whatsappContato,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final agora = DateTime.now();
    final expira = agora.add(const Duration(days: 30));

    final doc = await _db.collection('anuncios').add({
      'uid': user.uid,
      'titulo': titulo.trim(),
      'categoria': categoria,
      'descricao': descricao.trim(),
      'preco': preco,
      'fotos': fotos,
      'email_contato': emailContato.trim(),
      'whatsapp_contato': whatsappContato.trim(),
      'status': 'pendente',
      'criado_em': FieldValue.serverTimestamp(),
      'expira_em': Timestamp.fromDate(expira),
      'visualizacoes': 0,
      'pagamento_status': 'pendente',
    });

    return doc.id;
  }

  // ============================================================
  // ATUALIZAR FOTOS (após upload)
  // ============================================================
  static Future<void> atualizarFotos(
    String anuncioId,
    List<String> fotos,
  ) async {
    await _db.collection('anuncios').doc(anuncioId).update({
      'fotos': fotos,
    });
  }

  // ============================================================
  // LISTAR ANÚNCIOS ATIVOS (feed público)
  // ============================================================
  static Stream<QuerySnapshot> listarAtivos({String? categoria}) {
    Query query = _db
        .collection('anuncios')
        .where('status', isEqualTo: 'ativo')
        .where('pagamento_status', isEqualTo: 'pago');

    if (categoria != null && categoria.isNotEmpty) {
      query = query.where('categoria', isEqualTo: categoria);
    }

    return query.limit(50).snapshots();
  }

  // ============================================================
  // MEUS ANÚNCIOS
  // ============================================================
  static Stream<QuerySnapshot> meusAnuncios() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return const Stream.empty();
    }

    return _db
        .collection('anuncios')
        .where('uid', isEqualTo: user.uid)
        .orderBy('criado_em', descending: true)
        .snapshots();
  }

  // ============================================================
  // REGISTRAR VISUALIZAÇÃO
  // ============================================================
  static Future<void> registrarVisualizacao(String anuncioId) async {
    try {
      await _db.collection('anuncios').doc(anuncioId).update({
        'visualizacoes': FieldValue.increment(1),
      });
    } catch (_) {}
  }

  // ============================================================
  // VERIFICAR SE JÁ DESBLOQUEOU CONTATO
  // ============================================================
  static Future<bool> jaDesbloqueou(String anuncioId) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;

    try {
      final result = await _db
          .collection('desbloqueios')
          .where('anuncio_id', isEqualTo: anuncioId)
          .where('comprador_uid', isEqualTo: user.uid)
          .where('status', isEqualTo: 'aprovado')
          .limit(1)
          .get();

      return result.docs.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  // ============================================================
  // ADMIN — Listar pendentes
  // ============================================================
  static Stream<QuerySnapshot> listarPendentes() {
    return _db
        .collection('anuncios')
        .where('status', isEqualTo: 'pendente')
        .orderBy('criado_em', descending: true)
        .snapshots();
  }

  // ============================================================
  // ADMIN — Listar todos
  // ============================================================
  static Stream<QuerySnapshot> listarTodos() {
    return _db
        .collection('anuncios')
        .orderBy('criado_em', descending: true)
        .limit(100)
        .snapshots();
  }

  // ============================================================
  // ADMIN — Aprovar e publicar
  // ============================================================
  static Future<void> aprovarAnuncio(String anuncioId) async {
    final agora = DateTime.now();
    final expira = agora.add(const Duration(days: 30));

    await _db.collection('anuncios').doc(anuncioId).update({
      'status': 'ativo',
      'pagamento_status': 'pago',
      'aprovado_em': FieldValue.serverTimestamp(),
      'expira_em': Timestamp.fromDate(expira),
    });
  }

  // ============================================================
  // ADMIN — Reprovar
  // ============================================================
  static Future<void> reprovarAnuncio(String anuncioId) async {
    await _db.collection('anuncios').doc(anuncioId).update({
      'status': 'reprovado',
      'reprovado_em': FieldValue.serverTimestamp(),
    });
  }

  // ============================================================
  // ADMIN — Pausar
  // ============================================================
  static Future<void> pausarAnuncio(String anuncioId) async {
    await _db.collection('anuncios').doc(anuncioId).update({
      'status': 'pausado',
      'pausado_em': FieldValue.serverTimestamp(),
    });
  }
}
