import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AjudaService {
  AjudaService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Salva solicitação de ajuda especializada (advogado / engenheiro).
  static Future<void> salvarSolicitacao({
    required String tipoAjuda,
    required String especialidade,
    required String nome,
    required String email,
    required String whatsapp,
    required String descricao,
    int? valorCausa,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    await _db.collection('ajuda_especializada').add({
      'uid': user.uid,
      'email_conta': user.email ?? '',
      'tipo_ajuda': tipoAjuda,
      'especialidade': especialidade,
      'nome': nome.trim(),
      'email': email.trim(),
      'whatsapp': whatsapp.trim(),
      'valor_causa': valorCausa,
      'descricao': descricao.trim(),
      'status': 'em_analise',
      'criado_em': FieldValue.serverTimestamp(),
    });
  }

  /// Admin — Lista todas as solicitações
  static Stream<QuerySnapshot> listar() {
    return _db
        .collection('ajuda_especializada')
        .orderBy('criado_em', descending: true)
        .limit(100)
        .snapshots();
  }

  /// Admin — Atualiza status
  static Future<void> atualizarStatus(String docId, String status) async {
    await _db.collection('ajuda_especializada').doc(docId).update({
      'status': status,
      'atualizado_em': FieldValue.serverTimestamp(),
    });
  }
}
