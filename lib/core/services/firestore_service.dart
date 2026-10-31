import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'session.dart';

class FirestoreService {
  FirestoreService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Salva o lead da EMPRESA vinculado ao usuário logado.
  static Future<void> salvarLeadEmpresa() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    await _db.collection('leads_empresas').add({
      'uid': user.uid,
      'email': user.email,
      'nome_responsavel': Session.nomeResponsavel,
      'cargo': Session.cargo,
      'whatsapp': Session.whatsapp,
      'cnpj': Session.cnpj,
      'dados_cnpj': Session.dadosCnpj,
      'status': 'em_analise',
      'criado_em': FieldValue.serverTimestamp(),
    });
  }

  /// Salva o lead do INVESTIDOR vinculado ao usuário logado.
  static Future<void> salvarLeadInvestidor({
    required Map<String, dynamic> respostas,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    await _db.collection('leads_investidores').add({
      'uid': user.uid,
      'email': user.email,
      'respostas': respostas,
      'status': 'em_analise',
      'criado_em': FieldValue.serverTimestamp(),
    });
  }

  /// Salva o lead de PERMUTA/CONSTRUÇÃO.
  /// Retorna o ID do documento criado (pra fazer upload das fotos depois).
  static Future<String> salvarLeadConstrucao({
    required String nome,
    required String email,
    required String whatsapp,
    required String tipoImovel,
    required String localizacao,
    String? areaAproximada,
    String? iptu,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final doc = await _db.collection('leads_construcao').add({
      'uid': user.uid,
      'nome': nome.trim(),
      'email': email.trim(),
      'whatsapp': whatsapp.trim(),
      'tipo_imovel': tipoImovel,
      'localizacao': localizacao.trim(),
      'area_aproximada':
          (areaAproximada == null || areaAproximada.trim().isEmpty)
              ? null
              : areaAproximada.trim(),
      'iptu': (iptu == null || iptu.trim().isEmpty) ? null : iptu.trim(),
      'fotos': <String>[],
      'status': 'em_analise',
      'criado_em': FieldValue.serverTimestamp(),
    });

    return doc.id;
  }

  /// Atualiza as fotos do lead (após upload).
  static Future<void> atualizarFotosLeadConstrucao(
    String leadId,
    List<String> fotos,
  ) async {
    await _db.collection('leads_construcao').doc(leadId).update({
      'fotos': fotos,
    });
  }
}
