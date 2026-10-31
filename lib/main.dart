import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_app_check/firebase_app_check.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializa o locale pt_BR para DateFormat funcionar
  await initializeDateFormatting('pt_BR', null);

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // ============================================================
  // APP CHECK
  // ============================================================
  // Web: PRECISA da chave do reCAPTCHA v3 (senão o app quebra).
  //      Enquanto não tiver a chave, o App Check fica DESATIVADO na web.
  // Android: usa debug em desenvolvimento; no AAB final, troque por playIntegrity.
  // ============================================================
  if (kIsWeb) {
    // ⚠️ Descomente as 3 linhas abaixo SÓ depois de pegar a chave
    //    em: App Check → Apps → Web → reCAPTCHA v3
    //
    // await FirebaseAppCheck.instance.activate(
    //   webProvider: ReCaptchaV3Provider('SUA_CHAVE_RECAPTCHA_AQUI'),
    // );
  } else {
    await FirebaseAppCheck.instance.activate(
      androidProvider: AndroidProvider.debug, // 🔁 No AAB final: playIntegrity
    );
  }

  runApp(const KodaffApp());
}
