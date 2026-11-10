import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/core/widgets/app_text_field.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import 'package:w51/features/member/presentation/providers/member_provider.dart';

class MemberCompleteProfilePage extends ConsumerStatefulWidget {
  const MemberCompleteProfilePage({super.key});

  @override
  ConsumerState<MemberCompleteProfilePage> createState() =>
      _MemberCompleteProfilePageState();
}

class _MemberCompleteProfilePageState
    extends ConsumerState<MemberCompleteProfilePage> {
  final _formKey = GlobalKey<FormState>();
  final _callSign = TextEditingController();
  final _phone = TextEditingController();
  final _htCode = TextEditingController();
  final _domicile = TextEditingController();
  final _emergencyName = TextEditingController();
  final _emergencyPhone = TextEditingController();

  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final user = ref.read(authProvider);
    if (user?.callSign != null) {
      _callSign.text = user!.callSign!;
    }
    // Jika dashboard member sudah pernah dimuat, isi dari state
    final memberData = ref.read(memberDashboardProvider).value?.member;
    if (memberData != null) {
      if (_callSign.text.isEmpty && memberData.callSign != null) {
        _callSign.text = memberData.callSign!;
      }
      if (memberData.phone != null) _phone.text = memberData.phone!;
      if (memberData.htCode != null) _htCode.text = memberData.htCode!;
      if (memberData.domicile != null) _domicile.text = memberData.domicile!;
      if (memberData.emergencyName != null) {
        _emergencyName.text = memberData.emergencyName!;
      }
      if (memberData.emergencyPhone != null) {
        _emergencyPhone.text = memberData.emergencyPhone!;
      }
    }
  }

  @override
  void dispose() {
    _callSign.dispose();
    _phone.dispose();
    _htCode.dispose();
    _domicile.dispose();
    _emergencyName.dispose();
    _emergencyPhone.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _saving = true);
    final messenger = ScaffoldMessenger.of(context);

    try {
      await ref.read(memberDashboardProvider.notifier).saveProfile(
            callSign: _callSign.text,
            phone: _phone.text,
            htCode: _htCode.text,
            domicile: _domicile.text,
            emergencyName: _emergencyName.text,
            emergencyPhone: _emergencyPhone.text,
          );

      if (!mounted) return;
      messenger.showSnackBar(
        const SnackBar(
          content: Text('Profil kru operasional berhasil dilengkapi.'),
          backgroundColor: AppColors.success,
        ),
      );
      context.go(AppRoutes.memberDashboard);
    } catch (e) {
      if (!mounted) return;
      messenger.showSnackBar(
        SnackBar(
          content: Text('Gagal menyimpan profil: $e'),
          backgroundColor: AppColors.error,
        ),
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Profil Kru Operasional'),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'Keluar Akun',
            icon: const Icon(Icons.logout, color: AppColors.error),
            onPressed: () async {
              await ref.read(authProvider.notifier).signOut();
              if (context.mounted) context.go(AppRoutes.login);
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header Card
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.outline),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 28,
                      backgroundColor: AppColors.surfaceTint,
                      backgroundImage: user?.avatarUrl != null
                          ? NetworkImage(user!.avatarUrl!)
                          : null,
                      child: user?.avatarUrl == null
                          ? const Icon(Icons.person,
                              color: AppColors.primary, size: 30)
                          : null,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            user?.name ?? 'Kru Member',
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            user?.email ?? '',
                            style: const TextStyle(
                              fontSize: 13,
                              color: AppColors.textSecondary,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 9, vertical: 3),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceTint,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: const Text(
                              'WO Operational Crew',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.bold,
                                color: AppColors.primary,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Identitas Radio HT
              const Text(
                'Identitas Komunikasi Lapangan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Digunakan untuk koordinasi Handy Talky (HT) dan kontak antar kru saat event berlangsung.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),

              AppTextField(
                label: 'Call Sign / Nama Panggilan HT *',
                controller: _callSign,
                hint: 'Contoh: Alpha 1, Bravo Acara, Romeo PIC',
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Call sign wajib diisi untuk koordinasi kru.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              AppTextField(
                label: 'Nomor WhatsApp / HP Aktif *',
                controller: _phone,
                hint: '081234567890',
                keyboardType: TextInputType.phone,
                validator: (val) {
                  if (val == null || val.trim().isEmpty) {
                    return 'Nomor HP aktif wajib diisi.';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 14),

              AppTextField(
                label: 'Kode / Frekuensi HT (Opsional)',
                controller: _htCode,
                hint: 'Contoh: Channel 02 / 462.5625 MHz',
              ),
              const SizedBox(height: 14),

              AppTextField(
                label: 'Domisili / Kota Tempat Tinggal',
                controller: _domicile,
                hint: 'Contoh: Jakarta Barat, Surabaya',
              ),

              const SizedBox(height: 24),

              // Kontak Darurat
              const Text(
                'Kontak Darurat (Opsional)',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              const Text(
                'Hubungi pihak terdekat bila terjadi keadaan mendesak saat bertugas di event.',
                style: TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),

              AppTextField(
                label: 'Nama Kontak Darurat',
                controller: _emergencyName,
                hint: 'Contoh: Bpk. Santoso (Ayah)',
              ),
              const SizedBox(height: 14),

              AppTextField(
                label: 'Nomor Telepon Darurat',
                controller: _emergencyPhone,
                hint: '089876543210',
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 32),

              FilledButton(
                onPressed: _saving ? null : _submit,
                style: FilledButton.styleFrom(
                  backgroundColor: AppColors.primary,
                  minimumSize: const Size.fromHeight(50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: _saving
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.5,
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'Simpan & Buka Workspace Kru',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }
}

