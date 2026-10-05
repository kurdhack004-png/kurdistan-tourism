import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:easy_localization/easy_localization.dart' hide TextDirection;
import 'package:shared_preferences/shared_preferences.dart';

import 'core/localization/ckb_localizations.dart';
import 'core/theme/app_theme.dart';
import 'core/services/supabase_service.dart';
import 'features/settings/providers/settings_provider.dart';
import 'features/splash/presentation/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  ErrorWidget.builder = (FlutterErrorDetails details) => Container(
        color: const Color(0xFFFFF3F1),
        alignment: Alignment.center,
        child: const Icon(Icons.error_outline, color: Color(0xFFA33B2E), size: 36),
      );

  await EasyLocalization.ensureInitialized();
  await SupabaseService.initialize();

  final prefs = await SharedPreferences.getInstance();
  final savedLanguage = prefs.getString('settings_language') ?? 'ckb';
  final initialLocale = Locale(savedLanguage);

  runApp(
    ProviderScope(
      child: EasyLocalization(
        supportedLocales: const [
          Locale('ckb'),
          Locale('ar'),
          Locale('en'),
        ],
        path: 'assets/i18n',
        fallbackLocale: const Locale('ckb'),
        startLocale: ['ckb', 'ar', 'en'].contains(initialLocale.languageCode)
            ? initialLocale
            : const Locale('ckb'),
        child: const KurdistanTourismApp(),
      ),
    ),
  );
}

class KurdistanTourismApp extends ConsumerWidget {
  const KurdistanTourismApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);

    return MaterialApp(
      title: 'app_name'.tr(),
      debugShowCheckedModeBanner: false,
      theme: AppTheme.light,
      darkTheme: AppTheme.dark,
      themeMode: themeMode,
      localizationsDelegates: [
        ...ckbLocalizationDelegates,
        ...context.localizationDelegates,
      ],
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      builder: (context, child) => Directionality(
        textDirection: context.locale.languageCode == 'en' ? TextDirection.ltr : TextDirection.rtl,
        child: child!,
      ),
      home: const SplashScreen(),
    );
  }
}
