import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../auth/presentation/login_screen.dart';

class _OnboardPage {
  const _OnboardPage(this.icon, this.title, this.body);
  final IconData icon;
  final String title;
  final String body;
}

const _pages = [
  _OnboardPage(
    Icons.terrain_rounded,
    'شاخ و دۆڵەکانی کوردستان بدۆزەرەوە',
    'سەدان شوێنی سروشتی و مێژوویی، لەگەڵ ڕێنمایی وردی هەر شوێنێک.',
  ),
  _OnboardPage(
    Icons.map_outlined,
    'ڕێگاکان تۆمار بکە',
    'هەرکات چوویت بۆ هایکینگ، ڕێگاکەت بە GPS تۆمار بکە و لەگەڵ کۆمەڵگا هاوبەشی بکە.',
  ),
  _OnboardPage(
    Icons.cloud_off_rounded,
    'بەبێ ئینتەرنێتیش کاردەکات',
    'ناوچەکانی دڵخوازت وەربگرە بۆ کاتێک ئینتەرنێت نییە لە شاخەکاندا.',
  ),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _controller = PageController();
  int _index = 0;

  Future<void> _finish() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('seen_onboarding', true);
    if (!mounted) return;
    Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const LoginScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.ink,
      body: SafeArea(
        child: Column(
          children: [
            Align(
              alignment: Alignment.topLeft,
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: TextButton(
                  onPressed: _finish,
                  child: const Text('پەڕاندن', style: TextStyle(color: AppColors.riverstone)),
                ),
              ),
            ),
            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: _pages.length,
                onPageChanged: (i) => setState(() => _index = i),
                itemBuilder: (context, i) {
                  final p = _pages[i];
                  return Padding(
                    padding: const EdgeInsets.all(AppSpacing.xl),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(p.icon, size: 72, color: AppColors.saffron),
                        const SizedBox(height: AppSpacing.xl),
                        Text(p.title,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                                color: AppColors.limestoneWhite, fontSize: 22, fontWeight: FontWeight.w700)),
                        const SizedBox(height: AppSpacing.md),
                        Text(p.body,
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: Color(0xFFC9C2AA), fontSize: 14, height: 1.6)),
                      ],
                    ),
                  );
                },
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                _pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: i == _index ? 20 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: i == _index ? AppColors.saffron : AppColors.riverstone,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () {
                    if (_index == _pages.length - 1) {
                      _finish();
                    } else {
                      _controller.nextPage(
                        duration: const Duration(milliseconds: 250), curve: Curves.easeOut);
                    }
                  },
                  child: Text(_index == _pages.length - 1 ? 'دەستپێکردن' : 'دواتر'),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
