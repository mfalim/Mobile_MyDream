import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_typography.dart';

/// Tata letak bersama untuk Login dan Register.
class AuthLayout extends StatelessWidget {
  const AuthLayout({
    required this.title,
    required this.subtitle,
    required this.fields,
    required this.footer,
    this.onBack,
    super.key,
  });

  final String title;
  final String subtitle;
  final List<Widget> fields;
  final Widget footer;
  final VoidCallback? onBack;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            stops: [0, 0.45],
            colors: [AppColors.surfaceTint, AppColors.background],
          ),
        ),
        child: SafeArea(
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 440),
              child: SingleChildScrollView(
                keyboardDismissBehavior:
                    ScrollViewKeyboardDismissBehavior.onDrag,
                padding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: onBack == null
                          ? const SizedBox(height: 48)
                          : IconButton(
                              tooltip: 'Kembali',
                              onPressed: onBack,
                              icon: const Icon(Icons.arrow_back),
                            ),
                    ),
                    const _Brand(),
                    const SizedBox(height: 24),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: AppTypography.heading(28),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 14,
                        height: 1.5,
                      ),
                    ),
                    const SizedBox(height: 28),
                    ...fields,
                    const SizedBox(height: 16),
                    footer,
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Brand extends StatelessWidget {
  const _Brand();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 64,
          height: 64,
          decoration: const BoxDecoration(
            color: AppColors.primary,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.favorite_rounded,
            color: Colors.white,
            size: 30,
          ),
        ),
        const SizedBox(height: 12),
        Text('AURA WEDDING', style: AppTypography.eyebrow),
      ],
    );
  }
}

/// Garis pemisah dengan teks di tengah, mis. "atau masuk dengan email".
class AuthDivider extends StatelessWidget {
  const AuthDivider(this.label, {super.key});

  final String label;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20),
      child: Row(
        children: [
          const Expanded(child: Divider(color: AppColors.outline)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Text(
              label,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
              ),
            ),
          ),
          const Expanded(child: Divider(color: AppColors.outline)),
        ],
      ),
    );
  }
}
