import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/core/utils/validators.dart';
import 'package:w51/core/widgets/app_text_field.dart';
import 'package:w51/features/support/domain/entities/support_report.dart';
import 'package:w51/features/support/presentation/providers/support_provider.dart';

class ReportIssuePage extends ConsumerStatefulWidget {
  const ReportIssuePage({super.key});

  @override
  ConsumerState<ReportIssuePage> createState() => _ReportIssuePageState();
}

class _ReportIssuePageState extends ConsumerState<ReportIssuePage> {
  final _formKey = GlobalKey<FormState>();
  final _message = TextEditingController();
  String? _category;
  bool _categoryError = false;
  bool _busy = false;

  @override
  void dispose() {
    _message.dispose();
    super.dispose();
  }

  void _snack(ScaffoldMessengerState messenger, String message) {
    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _submit() async {
    if (_busy) return;
    final formOk = _formKey.currentState?.validate() ?? false;
    final category = _category;
    setState(() => _categoryError = category == null);
    if (!formOk || category == null) return;

    setState(() => _busy = true);
    final repository = ref.read(supportRepositoryProvider);
    final messenger = ScaffoldMessenger.of(context);
    final router = GoRouter.of(context);
    try {
      final ticket = await repository.submit(
        SupportReport(category: category, message: _message.text.trim()),
      );
      _snack(messenger, 'Laporan terkirim. Nomor tiket: $ticket');
      if (router.canPop()) {
        router.pop();
      } else {
        router.go(AppRoutes.myWedding);
      }
    } on ValidationException catch (e) {
      _snack(messenger, e.message);
    } catch (_) {
      _snack(
          messenger, 'Laporan gagal dikirim. Periksa koneksi lalu coba lagi.');
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        leading: IconButton(
          tooltip: 'Kembali',
          onPressed: () {
            if (context.canPop()) {
              context.pop();
            } else {
              context.go(AppRoutes.myWedding);
            }
          },
          icon: const Icon(Icons.arrow_back),
        ),
        centerTitle: true,
        title: Text('Laporkan Kendala', style: AppTypography.heading(20)),
      ),
      body: SingleChildScrollView(
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.sm,
          AppSpacing.screenPadding,
          AppSpacing.xl,
        ),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Ceritakan kendala atau masukanmu. Semakin rinci, semakin '
                'cepat kami bantu.',
                style: TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: 13,
                  height: 1.4,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              const FieldLabel('Kategori', required: true),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in kReportCategories)
                    ChoiceChip(
                      label: Text(c),
                      selected: c == _category,
                      onSelected: (_) => setState(() {
                        _category = c;
                        _categoryError = false;
                      }),
                      selectedColor: AppColors.coral.withValues(alpha: 0.3),
                      backgroundColor: AppColors.surfaceTint,
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                    ),
                ],
              ),
              if (_categoryError)
                const Padding(
                  padding: EdgeInsets.only(top: 6, left: 4),
                  child: Text(
                    'Pilih kategori kendala',
                    style: TextStyle(color: AppColors.error, fontSize: 12),
                  ),
                ),
              const SizedBox(height: AppSpacing.md),
              AppTextField(
                label: 'Ceritakan Kendalamu',
                required: true,
                controller: _message,
                maxLines: 6,
                textCapitalization: TextCapitalization.sentences,
                hint: 'Contoh: saat menekan Kirim Pesanan, layar berhenti...',
                validator: (v) =>
                    validateRequired(v, 'Deskripsi', minLength: 10) ??
                    ((v?.trim().length ?? 0) > 1000
                        ? 'Deskripsi maksimal 1000 karakter'
                        : null),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton(
                onPressed: _busy ? null : _submit,
                child: _busy
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text('Kirim Laporan'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
