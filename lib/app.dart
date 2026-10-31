import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/auth_gate.dart';
import 'routes/app_routes.dart';

class KodaffApp extends StatelessWidget {
  const KodaffApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Kodaff Investimentos',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
      // 🔒 Envolve TODO o app com o AuthGate
      builder: (context, child) => AuthGate(child: child),
    );
  }
}
