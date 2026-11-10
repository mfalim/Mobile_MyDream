import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/features/auth/presentation/providers/auth_provider.dart';
import '../../domain/entities/member_dashboard_data.dart';
import '../../domain/entities/member_event.dart';
import '../../domain/entities/member_schedule.dart';
import '../providers/member_provider.dart';

class MemberDashboardPage extends ConsumerStatefulWidget {
  const MemberDashboardPage({super.key});

  @override
  ConsumerState<MemberDashboardPage> createState() =>
      _MemberDashboardPageState();
}

class _MemberDashboardPageState extends ConsumerState<MemberDashboardPage>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;
  String _scheduleFilter = 'all'; // 'all', 'pending', 'approved'

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _logout() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar dari Akun?'),
        content: const Text(
          'Anda akan keluar dari workspace kru. Masuk kembali untuk memantau tugas.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Keluar'),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      await ref.read(authProvider.notifier).signOut();
      if (mounted) context.go(AppRoutes.login);
    }
  }

  Future<void> _toggleSchedule(MemberSchedule schedule) async {
    final newStatus = schedule.isApproved ? 'pending' : 'approved';
    final actionLabel =
        newStatus == 'approved' ? 'Tandai Selesai' : 'Kembalikan ke Pending';

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(actionLabel),
        content: Text(
          newStatus == 'approved'
              ? 'Apakah tugas "${schedule.title}" sudah selesai dilaksanakan di lapangan?'
              : 'Ubah kembali status tugas "${schedule.title}" menjadi Pending?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Batal'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: FilledButton.styleFrom(
              backgroundColor: newStatus == 'approved'
                  ? AppColors.success
                  : AppColors.primary,
            ),
            child: Text(actionLabel),
          ),
        ],
      ),
    );

    if (confirmed == true && mounted) {
      try {
        await ref
            .read(memberDashboardProvider.notifier)
            .updateScheduleStatus(scheduleId: schedule.id, newStatus: newStatus);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Tugas "${schedule.title}" diubah menjadi $newStatus.'),
              backgroundColor: AppColors.success,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Gagal memperbarui tugas: $e'),
              backgroundColor: AppColors.error,
            ),
          );
        }
      }
    }
  }

  void _showTeamDialog(MemberEvent event) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => DraggableScrollableSheet(
        initialChildSize: 0.65,
        minChildSize: 0.4,
        maxChildSize: 0.9,
        expand: false,
        builder: (ctx, scroll) => Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          event.eventName,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        Text(
                          'Tim Pelaksana (${event.teamMembers.length} Orang)',
                          style: const TextStyle(
                            fontSize: 13,
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (event.isCoordinator)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(
                        color: AppColors.gold,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Text(
                        'Koordinator',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: AppColors.onGold,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              const Divider(),
              Expanded(
                child: ListView.separated(
                  controller: scroll,
                  itemCount: event.teamMembers.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (ctx, index) {
                    final item = event.teamMembers[index];
                    return ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: CircleAvatar(
                        backgroundColor: item.isCoordinator
                            ? AppColors.primary
                            : AppColors.surfaceTint,
                        child: Text(
                          item.name.isNotEmpty
                              ? item.name[0].toUpperCase()
                              : '?',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: item.isCoordinator
                                ? Colors.white
                                : AppColors.primary,
                          ),
                        ),
                      ),
                      title: Text(
                        item.name,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            [
                              if (item.callSign != null) 'Call: ${item.callSign}',
                              item.role ?? item.position ?? 'Tim Lapangan',
                            ].join(' • '),
                            style: const TextStyle(fontSize: 12),
                          ),
                          if (item.attendanceStatus != null && item.attendanceStatus != 'pending')
                            Padding(
                              padding: const EdgeInsets.only(top: 2),
                              child: Text(
                                item.attendanceStatus == 'present'
                                    ? '✓ Presensi: Hadir (Diajukan)'
                                    : (item.attendanceStatus == 'late'
                                        ? '⏱ Presensi: Terlambat'
                                        : '✕ Presensi: Absen'),
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: item.attendanceStatus == 'present'
                                      ? AppColors.success
                                      : (item.attendanceStatus == 'late'
                                          ? Colors.orange.shade800
                                          : AppColors.error),
                                ),
                              ),
                            ),
                        ],
                      ),
                      trailing: event.isCoordinator
                          ? TextButton(
                              onPressed: () {
                                Navigator.of(ctx).pop();
                                _showAttendanceDialog(event, item);
                              },
                              child: Text(
                                (item.attendanceStatus != null && item.attendanceStatus != 'pending')
                                    ? 'Ubah Absen'
                                    : 'Input Absen',
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAttendanceDialog(MemberEvent event, MemberEventTeamItem teamItem) {
    String status = 'present';
    final hoursCtrl = TextEditingController(text: '8');

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setLocal) => AlertDialog(
          title: Text('Absensi: ${teamItem.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Event: ${event.eventName}',
                style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
              ),
              const SizedBox(height: 14),
              const Text('Status Kehadiran:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              DropdownButtonFormField<String>(
                initialValue: status,
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                ),
                items: const [
                  DropdownMenuItem(value: 'present', child: Text('Hadir (Present)')),
                  DropdownMenuItem(value: 'late', child: Text('Terlambat (Late)')),
                  DropdownMenuItem(value: 'absent', child: Text('Tidak Hadir (Absent)')),
                ],
                onChanged: (val) {
                  if (val != null) setLocal(() => status = val);
                },
              ),
              const SizedBox(height: 12),
              const Text('Jam Kerja Aktual (Hours):', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
              const SizedBox(height: 6),
              TextField(
                controller: hoursCtrl,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                decoration: InputDecoration(
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  suffixText: 'Jam',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(ctx).pop(),
              child: const Text('Batal'),
            ),
            FilledButton(
              onPressed: () async {
                final hours = double.tryParse(hoursCtrl.text) ?? 0.0;
                Navigator.of(ctx).pop();
                try {
                  await ref
                      .read(memberDashboardProvider.notifier)
                      .submitAttendance(
                        eventId: event.eventId,
                        memberId: teamItem.memberId,
                        attendanceStatus: status,
                        actualHours: hours,
                      );
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Presensi ${teamItem.name} berhasil disimpan.'),
                        backgroundColor: AppColors.success,
                      ),
                    );
                  }
                } catch (e) {
                  if (mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text('Gagal input absensi: $e'),
                        backgroundColor: AppColors.error,
                      ),
                    );
                  }
                }
              },
              child: const Text('Simpan'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dashboardAsync = ref.watch(memberDashboardProvider);

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        context.go(AppRoutes.home);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          title: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.primary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.badge_rounded, color: Colors.white, size: 20),
              ),
              const SizedBox(width: 10),
              const Text(
                'Workspace Kru WO',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'Jelajahi Beranda & Vendor',
              icon: const Icon(Icons.explore_outlined, color: AppColors.primary),
              onPressed: () => context.go(AppRoutes.home),
            ),
            IconButton(
              tooltip: 'Lengkapi / Ubah Profil',
              icon: const Icon(Icons.edit_note_rounded, color: AppColors.primary),
              onPressed: () => context.push(AppRoutes.memberCompleteProfile),
            ),
            IconButton(
              tooltip: 'Keluar',
              icon: const Icon(Icons.logout_rounded, color: AppColors.error),
              onPressed: _logout,
            ),
          ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          indicatorWeight: 3,
          tabs: const [
            Tab(icon: Icon(Icons.checklist_rtl_rounded), text: 'Tugas'),
            Tab(icon: Icon(Icons.event_note_rounded), text: 'Event Saya'),
            Tab(icon: Icon(Icons.account_circle_outlined), text: 'Profil & Fee'),
          ],
        ),
      ),
      body: dashboardAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: AppColors.primary),
        ),
        error: (err, _) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.cloud_off_rounded, size: 48, color: AppColors.error),
                const SizedBox(height: 12),
                Text('Gagal memuat data: $err', textAlign: TextAlign.center),
                const SizedBox(height: 16),
                FilledButton.icon(
                  onPressed: () =>
                      ref.read(memberDashboardProvider.notifier).refresh(),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        ),
        data: (data) {
          if (data == null) {
            return const Center(child: Text('Data tidak ditemukan'));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _buildSchedulesTab(data),
              _buildEventsTab(data),
              _buildProfileTab(data),
            ],
          );
        },
      ),
    ),
  );
}

  // ── TAB 1: TUGAS & RUNDOWN HARI H ──────────────────────────────────────────
  Widget _buildSchedulesTab(MemberDashboardData data) {
    final filtered = data.schedules.where((s) {
      if (_scheduleFilter == 'pending') return s.isPending;
      if (_scheduleFilter == 'approved') return s.isApproved;
      return true;
    }).toList();

    return RefreshIndicator(
      onRefresh: () => ref.read(memberDashboardProvider.notifier).refresh(),
      color: AppColors.primary,
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildHeaderProfileCard(data),
          const SizedBox(height: 16),
          _buildStatsGrid(data.stats),
          const SizedBox(height: 20),

          // Filter chips
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Rundown Lapangan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 8),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                physics: const BouncingScrollPhysics(),
                child: Row(
                  children: [
                    _buildFilterChip('all', 'Semua (${data.schedules.length})'),
                    const SizedBox(width: 8),
                    _buildFilterChip(
                        'pending', 'Pending (${data.stats.pendingSchedules})'),
                    const SizedBox(width: 8),
                    _buildFilterChip('approved',
                        'Selesai (${data.stats.approvedSchedules})'),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),

          if (filtered.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.outline),
              ),
              child: Column(
                children: [
                  Icon(Icons.task_alt_rounded,
                      size: 44, color: Colors.grey.shade400),
                  const SizedBox(height: 8),
                  Text(
                    _scheduleFilter == 'pending'
                        ? 'Semua tugas telah diselesaikan!'
                        : 'Tidak ada tugas pada filter ini.',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            )
          else
            for (final schedule in filtered) _buildScheduleCard(schedule),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildFilterChip(String key, String label) {
    final selected = _scheduleFilter == key;
    return InkWell(
      onTap: () => setState(() => _scheduleFilter = key),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: selected ? AppColors.primary : AppColors.outline,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: 11.5,
            fontWeight: FontWeight.bold,
            color: selected ? Colors.white : AppColors.textSecondary,
          ),
        ),
      ),
    );
  }

  Widget _buildScheduleCard(MemberSchedule schedule) {
    final startStr = formatTimeString(schedule.startTime);
    final endStr = formatTimeString(schedule.endTime);
    final timeLabel = [
      if (startStr.isNotEmpty) startStr,
      if (endStr.isNotEmpty) '- $endStr',
    ].join(' ');

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(
          color: schedule.isApproved ? AppColors.success.withValues(alpha: 0.3) : AppColors.outline,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            blurRadius: 8,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Checklist button
          IconButton(
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
            onPressed: () => _toggleSchedule(schedule),
            icon: Icon(
              schedule.isApproved
                  ? Icons.check_circle_rounded
                  : Icons.radio_button_unchecked_rounded,
              color: schedule.isApproved ? AppColors.success : Colors.grey.shade400,
              size: 28,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    if (timeLabel.isNotEmpty)
                      Flexible(
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.surfaceTint,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            timeLabel,
                            style: const TextStyle(
                              fontSize: 11.5,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: schedule.isApproved
                            ? Colors.green.shade50
                            : (schedule.isRejected ? Colors.red.shade50 : Colors.amber.shade50),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        schedule.status.toUpperCase(),
                        style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                          color: schedule.isApproved
                              ? AppColors.success
                              : (schedule.isRejected ? AppColors.error : Colors.amber.shade900),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Text(
                  schedule.title,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                    decoration: schedule.isApproved ? TextDecoration.lineThrough : null,
                    color: schedule.isApproved ? AppColors.textSecondary : AppColors.textPrimary,
                  ),
                ),
                if (schedule.eventName != null && schedule.eventName!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 2),
                    child: Row(
                      children: [
                        const Icon(Icons.event_outlined, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            [
                              schedule.eventName,
                              if (schedule.clientName != null && schedule.clientName!.isNotEmpty)
                                '• ${schedule.clientName}',
                            ].join(' '),
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.primary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                if (schedule.vendorName != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.storefront_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            '${schedule.vendorName} (${schedule.vendorCategory ?? 'Vendor'})',
                            style: const TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.textSecondary,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Row(
                    children: [
                      Icon(
                        schedule.picName != null ? Icons.person_outline_rounded : Icons.group_outlined,
                        size: 14,
                        color: schedule.picName != null ? AppColors.textSecondary : Colors.amber.shade800,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          schedule.picName != null && schedule.picName!.isNotEmpty
                              ? 'PIC: ${schedule.picName}'
                              : 'Tugas Tim / Terbuka untuk PIC',
                          style: TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w500,
                            color: schedule.picName != null ? AppColors.textSecondary : Colors.amber.shade900,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── TAB 2: EVENT SAYA & TIM ────────────────────────────────────────────────
  Widget _buildEventsTab(MemberDashboardData data) {
    if (data.events.isEmpty) {
      return const Center(
        child: Text('Belum ada event yang ditugaskan kepada Anda.'),
      );
    }

    return RefreshIndicator(
      onRefresh: () => ref.read(memberDashboardProvider.notifier).refresh(),
      color: AppColors.primary,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: data.events.length,
        itemBuilder: (ctx, index) {
          final event = data.events[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 14),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.outline),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: event.isCoordinator ? AppColors.gold : AppColors.surfaceTint,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        event.isCoordinator ? 'Koordinator Utama' : 'Tim Pelaksana',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: event.isCoordinator ? AppColors.onGold : AppColors.primary,
                        ),
                      ),
                    ),
                    Text(
                      formatDateString(event.date),
                      style: const TextStyle(
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  event.eventName,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (event.clientName != null)
                  Text(
                    'Klien: ${event.clientName}',
                    style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                if (event.venue != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 14, color: AppColors.textSecondary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            event.venue!,
                            style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                          ),
                        ),
                      ],
                    ),
                  ),
                _buildAttendanceStatusStrip(event),
                const SizedBox(height: 12),
                const Divider(),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Flexible(
                      child: Text(
                        'Honor Event: ${formatRupiah(event.totalFee.toInt())}',
                        style: const TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.bold,
                          color: AppColors.primary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    TextButton.icon(
                      onPressed: () => _showTeamDialog(event),
                      icon: const Icon(Icons.people_outline, size: 18),
                      label: Text('Lihat Tim (${event.teamMembers.length})'),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttendanceStatusStrip(MemberEvent event) {
    final attStatus = event.attendanceStatus;
    final isSubmitted = attStatus == 'present' || attStatus == 'late';
    final isAbsent = attStatus == 'absent';

    String attLabel;
    Color attColor;
    IconData attIcon;

    if (attStatus == 'present') {
      attLabel = 'Hadir (${event.actualHours.toStringAsFixed(1)} jam kerja)';
      attColor = AppColors.success;
      attIcon = Icons.check_circle_rounded;
    } else if (attStatus == 'late') {
      attLabel = 'Terlambat (${event.actualHours.toStringAsFixed(1)} jam kerja)';
      attColor = Colors.orange.shade800;
      attIcon = Icons.access_time_filled_rounded;
    } else if (isAbsent) {
      attLabel = 'Tidak Hadir (Absen)';
      attColor = AppColors.error;
      attIcon = Icons.cancel_rounded;
    } else {
      attLabel = 'Menunggu Presensi Lapangan';
      attColor = AppColors.textSecondary;
      attIcon = Icons.hourglass_empty_rounded;
    }

    String payBadgeLabel;
    Color payBg;
    Color payText;
    String paySubtext;

    if (isAbsent) {
      payBadgeLabel = 'Tidak Ada Honor';
      payBg = Colors.grey.shade100;
      payText = Colors.grey.shade700;
      paySubtext = 'Kehadiran tercatat absen.';
    } else if (event.paymentStatus == 'paid') {
      payBadgeLabel = 'Lunas Dibayar';
      payBg = Colors.blue.shade50;
      payText = Colors.blue.shade800;
      paySubtext = 'Honor sudah ditransfer oleh Admin.';
    } else if (event.paymentStatus == 'approved') {
      payBadgeLabel = 'ACC Admin Disetujui';
      payBg = Colors.green.shade50;
      payText = Colors.green.shade800;
      paySubtext = 'Bayaran siap dicairkan.';
    } else if (isSubmitted) {
      payBadgeLabel = 'Menunggu ACC Admin';
      payBg = Colors.amber.shade50;
      payText = Colors.amber.shade900;
      paySubtext = 'Presensi sudah diajukan Koordinator.';
    } else {
      payBadgeLabel = 'Belum Ada Pengajuan';
      payBg = Colors.grey.shade100;
      payText = Colors.grey.shade700;
      paySubtext = 'Koordinator belum menginput jam kerja.';
    }

    return Container(
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isSubmitted ? Colors.amber.shade300 : AppColors.outline,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(attIcon, size: 16, color: attColor),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'Kehadiran Saya: $attLabel',
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.bold,
                    color: attColor,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2.5),
                decoration: BoxDecoration(
                  color: payBg,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  payBadgeLabel,
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                    color: payText,
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  paySubtext,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── TAB 3: PROFIL KRU & FEE ───────────────────────────────────────────────
  Widget _buildProfileTab(MemberDashboardData data) {
    final m = data.member;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _buildHeaderProfileCard(data),
        const SizedBox(height: 16),

        // Fee Summary Card
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [AppColors.primary, Color(0xFF5D2424)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.3),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Ringkasan Honorarium Kru',
                style: TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const SizedBox(height: 6),
              Text(
                formatRupiah(data.stats.approvedFee.toInt()),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'Estimasi Total: ${formatRupiah(data.stats.estimatedFee.toInt())}',
                style: const TextStyle(color: AppColors.gold, fontSize: 13),
              ),
            ],
          ),
        ),

        const SizedBox(height: 20),

        // Detail Info Operasional
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppColors.outline),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Informasi Operasional Lapangan',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              _buildInfoRow('Nama Lengkap', m.name),
              _buildInfoRow('Call Sign Radio', m.callSign ?? '-'),
              _buildInfoRow('Kode / Frekuensi HT', m.htCode ?? '-'),
              _buildInfoRow('Posisi / Jabatan', m.positionName ?? '-'),
              _buildInfoRow('Divisi Operasional', m.divisionName ?? '-'),
              _buildInfoRow('Nomor WhatsApp', m.phone ?? '-'),
              _buildInfoRow('Domisili', m.domicile ?? '-'),
              _buildInfoRow('Kontak Darurat',
                  '${m.emergencyName ?? '-'} (${m.emergencyPhone ?? '-'})'),
            ],
          ),
        ),

        const SizedBox(height: 20),

        FilledButton.icon(
          onPressed: () => context.push(AppRoutes.memberCompleteProfile),
          icon: const Icon(Icons.edit),
          label: const Text('Edit Profil Kru & Kontak'),
          style: FilledButton.styleFrom(
            backgroundColor: AppColors.primary,
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        const SizedBox(height: 10),

        OutlinedButton.icon(
          onPressed: _logout,
          icon: const Icon(Icons.logout, color: AppColors.error),
          label: const Text('Keluar dari Akun', style: TextStyle(color: AppColors.error)),
          style: OutlinedButton.styleFrom(
            side: const BorderSide(color: AppColors.error),
            minimumSize: const Size.fromHeight(48),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        ),

        const SizedBox(height: 24),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              label,
              style: const TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── SHARED WIDGETS ────────────────────────────────────────────────────────
  Widget _buildHeaderProfileCard(MemberDashboardData data) {
    final m = data.member;
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.primary,
            child: Text(
              m.name.isNotEmpty ? m.name[0].toUpperCase() : 'M',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 20,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Flexible(
                      child: Text(
                        m.name,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (m.callSign != null && m.callSign!.isNotEmpty) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.gold,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Text(
                          m.callSign!,
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                            color: AppColors.onGold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 3),
                Text(
                  [
                    m.positionName ?? 'Crew Member',
                    m.divisionName ?? 'Operasional',
                  ].join(' • '),
                  style: const TextStyle(fontSize: 12.5, color: AppColors.textSecondary),
                ),
                if (m.htCode != null && m.htCode!.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.only(top: 3),
                    child: Row(
                      children: [
                        const Icon(Icons.settings_remote_rounded, size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Text(
                          'HT: ${m.htCode}',
                          style: const TextStyle(
                            fontSize: 11.5,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(MemberDashboardStats stats) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      childAspectRatio: 2.1,
      children: [
        _buildStatTile(
          title: 'Total Jadwal',
          value: '${stats.totalSchedules}',
          icon: Icons.assignment_outlined,
          color: AppColors.primary,
        ),
        _buildStatTile(
          title: 'Tugas Selesai',
          value: '${stats.approvedSchedules}',
          icon: Icons.check_circle_outline,
          color: AppColors.success,
        ),
        _buildStatTile(
          title: 'Menunggu (Pending)',
          value: '${stats.pendingSchedules}',
          icon: Icons.pending_actions_outlined,
          color: Colors.amber.shade800,
        ),
        _buildStatTile(
          title: 'Event Ditugaskan',
          value: '${stats.totalEvents}',
          icon: Icons.calendar_month_outlined,
          color: Colors.blue.shade700,
        ),
      ],
    );
  }

  Widget _buildStatTile({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.outline),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: color,
                  ),
                ),
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
