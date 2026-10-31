import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  AdminService._();

  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  /// Verifica se o usuário atual é admin (doc existe em /admins/{uid}).
  static Future<bool> isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return false;
    try {
      final doc = await _db.collection('admins').doc(user.uid).get();
      return doc.exists;
    } catch (_) {
      return false;
    }
  }

  static Stream<QuerySnapshot> leadsEmpresas() {
    return _db
        .collection('leads_empresas')
        .orderBy('criado_em', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> leadsInvestidores() {
    return _db
        .collection('leads_investidores')
        .orderBy('criado_em', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> leadsConstrucao() {
    return _db
        .collection('leads_construcao')
        .orderBy('criado_em', descending: true)
        .snapshots();
  }

  static Stream<QuerySnapshot> ajudaEspecializada() {
    return _db
        .collection('ajuda_especializada')
        .orderBy('criado_em', descending: true)
        .snapshots();
  }

  // ============================================================
  // 👇 NOVO MÉTODO ADICIONADO AQUI 👇
  // ============================================================
  static Stream<QuerySnapshot> usuarios() {
    return _db
        .collection('usuarios')
        .orderBy('ultimo_login', descending: true)
        .snapshots();
  }

  static Future<void> atualizarStatus({
    required String colecao,
    required String leadId,
    required String novoStatus,
  }) async {
    await _db.collection(colecao).doc(leadId).update({
      'status': novoStatus,
      'atualizado_em': FieldValue.serverTimestamp(),
    });
  }
}
