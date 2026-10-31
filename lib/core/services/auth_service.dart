import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Web Client ID real do projeto koda-ebd27
  static const String _webClientId =
      '595685952877-5gvo1ca823vr8tqjbgs3sjdvp2tlc9if.apps.googleusercontent.com';

  static User? get usuarioAtual => _auth.currentUser;
  static Stream<User?> get authState => _auth.authStateChanges();

  // ============================================================
  // CRIAR CONTA COM EMAIL/SENHA
  // ============================================================
  static Future<User?> criarConta({
    required String email,
    required String senha,
    required String nome,
    required String tipo,
  }) async {
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );

      final user = cred.user;
      if (user == null) return null;

      await user.updateDisplayName(nome);
      await user.sendEmailVerification();

      await _db.collection('usuarios').doc(user.uid).set({
        'uid': user.uid,
        'email': email.trim(),
        'nome': nome,
        'tipo': tipo,
        'email_verificado': false,
        'criado_em': FieldValue.serverTimestamp(),
      });

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_traduzirErro(e));
    }
  }

  // ============================================================
  // LOGIN COM EMAIL/SENHA
  // ============================================================
  static Future<User?> login({
    required String email,
    required String senha,
  }) async {
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: senha,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_traduzirErro(e));
    }
  }

  // ============================================================
  // LOGIN / CADASTRO COM GOOGLE (CORRIGIDO PARA WEB)
  // ============================================================
  static Future<User?> loginComGoogle() async {
    try {
      UserCredential userCred;

      if (kIsWeb) {
        // ✅ SOLUÇÃO WEB: Usa o popup nativo do Firebase
        // Isso resolve o erro de COOP e a demora pra logar na web
        final GoogleAuthProvider googleProvider = GoogleAuthProvider();
        googleProvider.addScope('email');
        googleProvider.addScope('profile');
        userCred = await _auth.signInWithPopup(googleProvider);
      } else {
        // ✅ SOLUÇÃO MOBILE (Android/iOS)
        final GoogleSignIn googleSignIn = GoogleSignIn(
          serverClientId: _webClientId,
        );

        final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
        if (googleUser == null) return null; // usuário cancelou

        final GoogleSignInAuthentication googleAuth =
            await googleUser.authentication;

        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        userCred = await _auth.signInWithCredential(credential);
      }

      final user = userCred.user;

      if (user != null) {
        // Cria/atualiza o perfil no Firestore (serve pra login E cadastro)
        await _db.collection('usuarios').doc(user.uid).set({
          'uid': user.uid,
          'email': user.email,
          'nome': user.displayName ?? '',
          'foto': user.photoURL,
          'email_verificado': user.emailVerified,
          'ultimo_login': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      }

      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_traduzirErro(e));
    } catch (e) {
      throw Exception('Erro no login com Google: $e');
    }
  }

  // ============================================================
  // LOGOUT
  // ============================================================
  static Future<void> logout() async {
    try {
      if (!kIsWeb) {
        await GoogleSignIn().signOut();
      }
    } catch (_) {}
    await _auth.signOut();
  }

  // ============================================================
  // RECUPERAR SENHA
  // ============================================================
  static Future<void> enviarResetSenha(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email.trim());
    } on FirebaseAuthException catch (e) {
      throw Exception(_traduzirErro(e));
    }
  }

  // ============================================================
  // VERIFICAÇÃO DE EMAIL
  // ============================================================
  static Future<void> reenviarVerificacao() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');
    await user.sendEmailVerification();
  }

  static Future<void> recarregarUsuario() async {
    final user = _auth.currentUser;
    if (user == null) return;
    await user.reload();
  }

  // ============================================================
  // TROCAR SENHA (LGPD)
  // ============================================================
  static Future<void> trocarSenha({
    required String senhaAtual,
    required String novaSenha,
  }) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final email = user.email;
    if (email == null) throw Exception('E-mail não encontrado');

    try {
      final cred = EmailAuthProvider.credential(
        email: email,
        password: senhaAtual,
      );
      await user.reauthenticateWithCredential(cred);
      await user.updatePassword(novaSenha);
    } on FirebaseAuthException catch (e) {
      throw Exception(_traduzirErro(e));
    }
  }

  // ============================================================
  // DELETAR CONTA (LGPD)
  // ============================================================
  static Future<void> deletarConta({required String senhaAtual}) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('Usuário não autenticado');

    final email = user.email;
    if (email == null) throw Exception('E-mail não encontrado');

    try {
      final cred = EmailAuthProvider.credential(
        email: email,
        password: senhaAtual,
      );
      await user.reauthenticateWithCredential(cred);

      try {
        final leadsEmpresa = await _db
            .collection('leads_empresas')
            .where('uid', isEqualTo: user.uid)
            .get();
        for (final doc in leadsEmpresa.docs) {
          await doc.reference.delete();
        }

        final leadsInvestidor = await _db
            .collection('leads_investidores')
            .where('uid', isEqualTo: user.uid)
            .get();
        for (final doc in leadsInvestidor.docs) {
          await doc.reference.delete();
        }

        await _db.collection('usuarios').doc(user.uid).delete();
      } catch (_) {}

      await user.delete();
    } on FirebaseAuthException catch (e) {
      throw Exception(_traduzirErro(e));
    }
  }

  // ============================================================
  // TRADUÇÃO DE ERROS
  // ============================================================
  static String _traduzirErro(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        return 'Este e-mail já está cadastrado.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'weak-password':
        return 'Senha muito fraca.';
      case 'user-not-found':
        return 'E-mail não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente em alguns minutos.';
      case 'network-request-failed':
        return 'Sem conexão com a internet.';
      case 'requires-recent-login':
        return 'Faça login novamente para continuar.';
      case 'account-exists-with-different-credential':
        return 'Este e-mail já está cadastrado com outro método de login.';
      case 'invalid-credential':
        return 'Credencial inválida. Tente novamente.';
      case 'popup-closed-by-user':
        return 'Login cancelado.';
      case 'cancelled':
        return 'Login cancelado.';
      default:
        return 'Erro: ${e.message ?? e.code}';
    }
  }
}
