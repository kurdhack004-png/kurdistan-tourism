import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shell/main_shell.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _route();
  }

  Future<void> _route() async {
    await Future<void>.delayed(const Duration(milliseconds: 500));
    await ref.read(authProvider.notifier).ready;
    if (!mounted) return;

    // TEMPORARY: skip onboarding and login entirely, and guarantee an
    // authenticated (local demo) session so the dashboard has a valid
    // auth state to work with. Remove this bypass once login/backend
    // are ready and you want the normal onboarding -> login flow back.
    final auth = ref.read(authProvider);
    if (!auth.isAuthenticated) {
      await ref.read(authProvider.notifier).bypassForTesting();
    }

    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      backgroundColor: AppColors.ink,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.terrain_rounded, size: 56, color: AppColors.saffron),
            SizedBox(height: 16),
            Text('گەشتیاری کوردستان',
                style: TextStyle(color: AppColors.limestoneWhite, fontSize: 18, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}
