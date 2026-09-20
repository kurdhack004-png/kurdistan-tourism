import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/providers/auth_provider.dart';
import '../../shell/main_shell.dart';
import '../../settings/presentation/language_selection_screen.dart';

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

    // Guest mode: opening the app never creates a fake authenticated session.
    // Authentication is requested only when the user starts a protected flow
    // such as accommodation booking/payment.
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    final hasSelectedLanguage = prefs.containsKey('settings_language');
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
        builder: (_) => hasSelectedLanguage
            ? const MainShell()
            : const LanguageSelectionScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.terrain_rounded, size: 56, color: AppColors.saffron),
            const SizedBox(height: 16),
            Text(
              'app_name'.tr(),
              style: const TextStyle(
                color: AppColors.limestoneWhite,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
