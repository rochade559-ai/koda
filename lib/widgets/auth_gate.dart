import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../core/constants/app_colors.dart';
import '../../screens/auth/verificar_email_screen.dart';
import '../../widgets/loading_kodaff.dart';

class AuthGate extends StatelessWidget {
  final Widget? child;
  const AuthGate({super.key, this.child});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            backgroundColor: AppColors.background,
            body: Center(
              child: LoadingKodaff(
                size: 80,
                texto: 'Verificando sessão...',
              ),
            ),
          );
        }

        final user = snapshot.data;

        // Logado mas NÃO verificado → bloqueia o app
        if (user != null && !user.emailVerified) {
          return VerificarEmailScreen(email: user.email ?? '');
        }

        return child ?? const SizedBox.shrink();
      },
    );
  }
}
