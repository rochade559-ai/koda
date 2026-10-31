import 'package:flutter/material.dart';
import 'dart:async';
import '../../core/constants/app_colors.dart';
import '../../routes/app_routes.dart';
import '../../widgets/loading_kodaff.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    Timer(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: const Center(
        child: LoadingKodaff(
          size: 160,
          texto: 'CARREGANDO',
        ),
      ),
    );
  }
}
