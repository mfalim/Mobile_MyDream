import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/core/widgets/app_text_field.dart';
import 'package:w51/features/auth/domain/validators.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import 'package:w51/features/auth/presentation/widgets/auth_layout.dart';
import 'package:w51/features/auth/presentation/widgets/google_sign_in_button.dart';
import 'package:w51/core/widgets/password_field.dart';
import 'package:w51/app/router/auth_redirect.dart';
import 'package:w51/features/my_wedding/presentation/providers/couple_provider.dart';
import 'package:w51/core/config/app_features.dart';

class LoginPage extends ConsumerStatefulWidget {
  const LoginPage({this.from, super.key});

  /// Alamat tujuan setelah berhasil (diteruskan dari penjaga login).
  final String? from;

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  /// 'google' atau 'email' selama permintaan berjalan; null bila diam.
  String? _busy;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.red.shade700,
        ),
      );
  }

  /// Login dengan Google via API Laravel.
  Future<void> _google() async {
    if (_busy != null) return;
    setState(() => _busy = 'google');

    try {
      final result =
          await ref.read(authProvider.notifier).signInWithGoogle();

      if (!mounted) return;
      final router = GoRouter.of(context);

      // Tentukan tujuan navigasi berdasarkan next_step & role dari API
      if (result.user.role == 'member') {
        if (result.nextStep == 'complete_profile' ||
            result.user.callSign == null ||
            result.user.callSign!.isEmpty) {
          router.go(AppRoutes.memberCompleteProfile);
        } else {
          router.go(AppRoutes.memberDashboard);
        }
      } else if (result.nextStep == 'complete_profile') {
        // Belum lengkapi profil client → arahkan ke couple setup
        final dest = AppRoutes.coupleSetupPath(from: widget.from ?? AppRoutes.home);
        router.go(dest);
      } else {
        // Profil client sudah lengkap → ke tujuan semula atau home
        final dest = postLoginDestination(
          from: widget.from,
          role: result.user.role,
          needsCoupleSetup: ref.read(coupleProvider) == null &&
              result.user.role == 'client',
        );
        router.go(dest);
      }
    } on RoleRestrictedException catch (e) {
      if (!mounted) return;
      _showRoleRestrictedDialog(e.role);
    } on UnauthorizedException catch (e) {
      _showError(e.message);
    } on ServerException catch (e) {
      _showError(e.message);
    } on NetworkException catch (e) {
      _showError(e.message);
    } on GoogleSignInException catch (e) {
      _showError(
        e.description ??
            (e.code == GoogleSignInExceptionCode.canceled
                ? 'Login dibatalkan atau SHA-1 belum cocok di Google Cloud Console.'
                : 'Google Sign-In gagal: ${e.code.name}'),
      );
    } catch (e) {
      _showError('Login Google gagal: $e');
    } finally {
      if (mounted) setState(() => _busy = null);
    }
  }

  Future<void> _showRoleRestrictedDialog(String role) async {
    final title = role == 'admin' ? 'Portal Administrator' : 'Portal Vendor Partner';
    final roleName = role == 'admin' ? 'Admin (Administrator)' : 'Vendor Rekanan';

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        icon: Container(
          width: 56,
          height: 56,
          decoration: const BoxDecoration(
            color: AppColors.surfaceTint,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.laptop_chromebook_rounded,
            size: 30,
            color: AppColors.primary,
          ),
        ),
        title: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Akun Anda terdaftar sebagai $roleName.',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Aplikasi mobile MyDream saat ini dikhususkan untuk '
              'Calon Pengantin (Client) dan Kru Lapangan (Member).\n\n'
              'Silakan kelola sistem melalui Dashboard Web MyDream di komputer / laptop Anda.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13.5,
                color: AppColors.textSecondary,
                height: 1.45,
              ),
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.primary,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            ),
            child: const Text('Saya Mengerti'),
          ),
        ],
      ),
    );
  }

  void _soon(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fitur $feature akan segera hadir.')),
    );
  }

  void _submit() {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    // Email/password login belum terhubung ke API — tampilkan info
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Login email belum tersedia. Gunakan Google.')),
    );
  }

  @override
  Widget build(BuildContext context) {
    final busy = _busy != null;
    return AuthLayout(
      title: 'Selamat Datang Kembali',
      subtitle:
          'Masuk untuk menyimpan keranjang, memesan vendor, dan melanjutkan '
          'perencanaanmu.',
      onBack: context.canPop() ? context.pop : null,
      fields: [
        GoogleSignInButton(
          label: 'Lanjutkan dengan Google',
          loading: _busy == 'google',
          onPressed: busy ? null : _google,
        ),
        const AuthDivider('atau masuk dengan email'),
        Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              AppTextField(
                label: 'Email',
                controller: _email,
                hint: 'nama@email.com',
                keyboardType: TextInputType.emailAddress,
                validator: validateEmail,
              ),
              const SizedBox(height: 14),
              PasswordField(
                label: 'Kata Sandi',
                controller: _password,
                hint: 'Masukkan kata sandi',
                validator: validateLoginPassword,
                onSubmitted: (_) => busy ? null : _submit(),
              ),
              if (AppFeatures.passwordRecovery)
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed:
                        busy ? null : () => _soon('Pemulihan kata sandi'),
                    child: const Text('Lupa kata sandi?'),
                  ),
                )
              else
                const SizedBox(height: 10),
              const SizedBox(height: 4),
              FilledButton(
                onPressed: busy ? null : _submit,
                child: _busy == 'email'
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Masuk'),
              ),
            ],
          ),
        ),
      ],
      footer: Column(
        children: [
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text(
                'Belum punya akun?',
                style: TextStyle(color: AppColors.textSecondary),
              ),
              TextButton(
                onPressed: busy
                    ? null
                    : () => context.pushReplacement(
                          AppRoutes.registerPath(from: widget.from),
                        ),
                child: const Text('Daftar'),
              ),
            ],
          ),
          TextButton(
            onPressed: busy ? null : () => context.go(AppRoutes.home),
            child: const Text('Lanjut sebagai tamu'),
          ),
        ],
      ),
    );
  }
}
