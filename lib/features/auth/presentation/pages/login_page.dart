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

      // Tentukan tujuan navigasi berdasarkan next_step dari API
      if (result.nextStep == 'complete_profile') {
        // Belum lengkapi profil → arahkan ke couple setup (untuk client)
        // atau home (role lain); router akan menjaga halaman terproteksi
        final dest = result.user.role == 'client'
            ? AppRoutes.coupleSetupPath(from: widget.from ?? AppRoutes.home)
            : safeInternalPath(widget.from);
        router.go(dest);
      } else {
        // Profil sudah lengkap → ke tujuan semula atau home
        final dest = postLoginDestination(
          from: widget.from,
          needsCoupleSetup: ref.read(coupleProvider) == null &&
              result.user.role == 'client',
        );
        router.go(dest);
      }
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
              Align(
                alignment: Alignment.centerRight,
                child: TextButton(
                  onPressed: busy ? null : () {},
                  child: const Text('Lupa kata sandi?'),
                ),
              ),
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
