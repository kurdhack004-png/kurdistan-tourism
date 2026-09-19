import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../shell/main_shell.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    await ref.read(authProvider.notifier).login(_emailCtrl.text.trim(), _passCtrl.text);
    final state = ref.read(authProvider);
    if (state.isAuthenticated && mounted) {
      Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (_) => const MainShell()));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.ink,
      // Ensure the keyboard never pushes/resizes content into a stray
      // empty region, and that the Scaffold always paints a solid
      // background edge-to-edge (no default Material gray showing through).
      resizeToAvoidBottomInset: true,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.all(AppSpacing.xl),
              child: ConstrainedBox(
                // Fill at least the visible height so the Column's
                // mainAxisAlignment.center behaves predictably instead of
                // collapsing to its intrinsic size inside a scroll view.
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const Icon(Icons.terrain_rounded, size: 48, color: AppColors.saffron),
                      const SizedBox(height: AppSpacing.md),
                      const Text(
                        'چوونەژوورەوە',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: AppColors.limestoneWhite,
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _DarkField(
                        controller: _emailCtrl,
                        hint: 'ئیمەیل',
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: AppSpacing.md),
                      _DarkField(controller: _passCtrl, hint: 'وشەی نهێنی', obscure: true),
                      const SizedBox(height: AppSpacing.lg),
                      if (auth.error != null)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.md),
                          child: Text(
                            auth.error!,
                            style: const TextStyle(color: Color(0xFFE38E7E), fontSize: 13),
                          ),
                        ),
                      FilledButton(
                        onPressed: auth.isLoading ? null : _submit,
                        child: auth.isLoading
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: AppColors.inkDeep,
                                ),
                              )
                            : const Text('چوونەژوورەوە'),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      TextButton(
                        onPressed: () => Navigator.of(context)
                            .push(MaterialPageRoute(builder: (_) => const RegisterScreen())),
                        child: const Text(
                          'هەژمارت نییە؟ خۆت تۆمار بکە',
                          style: TextStyle(color: AppColors.riverstone, fontSize: 13),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

class _DarkField extends StatelessWidget {
  const _DarkField({
    required this.controller,
    required this.hint,
    this.obscure = false,
    this.keyboardType,
  });

  final TextEditingController controller;
  final String hint;
  final bool obscure;
  final TextInputType? keyboardType;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      style: const TextStyle(color: AppColors.limestoneWhite),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppColors.riverstone),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.06),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppSpacing.chipRadius),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}
