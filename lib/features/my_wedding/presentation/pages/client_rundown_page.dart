import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/core/utils/formatters.dart';
import 'package:w51/core/widgets/empty_state.dart';
import 'package:w51/core/widgets/error_state.dart';
import 'package:w51/features/my_wedding/domain/entities/client_portal_models.dart';
import 'package:w51/features/my_wedding/presentation/providers/client_portal_provider.dart';
import 'package:w51/features/payment/domain/entities/client_booking_summary.dart';
import 'package:w51/features/payment/presentation/providers/payments_provider.dart';

class ClientRundownPage extends ConsumerStatefulWidget {
  const ClientRundownPage({super.key});

  @override
  ConsumerState<ClientRundownPage> createState() => _ClientRundownPageState();
}

class _ClientRundownPageState extends ConsumerState<ClientRundownPage> {
  int _selectedIndex = 0;
  bool _showCalendar = true;

  Future<void> _refresh() async {
    ref.invalidate(clientEventsProvider);
    ref.invalidate(clientBookingsProvider);
    await ref.read(clientEventsProvider.future);
  }

  Future<void> _showCreateEventSheet(List<ClientBookingSummary> bookings) async {
    if (bookings.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Buat reservasi paket/vendor terlebih dahulu.'),
        ),
      );
      return;
    }

    final created = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _CreateEventBottomSheet(bookings: bookings),
    );

    if (created == true && mounted) {
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Rangkaian acara baru berhasil diajukan ke Admin.'),
        ),
      );
    }
  }

  Future<void> _showReviewSheet(ClientEventItem event) async {
    final submitted = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => _SubmitReviewBottomSheet(event: event),
    );

    if (submitted == true && mounted) {
      await _refresh();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Terima kasih! Ulasan pernikahan Anda berhasil dikirim.'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final eventsAsync = ref.watch(clientEventsProvider);
    final bookingsAsync = ref.watch(clientBookingsProvider);
    final bookings = bookingsAsync.value ?? const [];

    return Scaffold(
      appBar: AppBar(
        title: Text('Rundown & Kalender Acara', style: AppTypography.heading(20)),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: _showCalendar ? 'Sembunyikan Kalender' : 'Tampilkan Kalender',
            onPressed: () => setState(() => _showCalendar = !_showCalendar),
            icon: Icon(
              _showCalendar
                  ? Icons.calendar_month_rounded
                  : Icons.calendar_month_outlined,
            ),
          ),
          IconButton(
            tooltip: 'Segarkan Jadwal',
            onPressed: _refresh,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      floatingActionButton: bookings.isEmpty
          ? null
          : FloatingActionButton.extended(
              onPressed: () => _showCreateEventSheet(bookings),
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              icon: const Icon(Icons.add_rounded),
              label: const Text('Ajukan Acara'),
            ),
      body: eventsAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => ErrorState(
          message: 'Gagal memuat jadwal rundown acara.',
          onRetry: _refresh,
        ),
        data: (events) {
          if (events.isEmpty) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const EmptyState(
                      message:
                          'Belum ada jadwal acara aktif. Pesan paket pernikahan untuk mulai menyusun rundown bersama Admin.',
                      icon: Icons.event_note_outlined,
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: () => context.go(AppRoutes.packages),
                      style: FilledButton.styleFrom(
                        minimumSize: const Size(220, 48),
                      ),
                      child: const Text('Lihat Paket Pernikahan'),
                    ),
                  ],
                ),
              ),
            );
          }

          final safeIndex = _selectedIndex.clamp(0, events.length - 1);
          final selected = events[safeIndex];

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.screenPadding,
                AppSpacing.md,
                AppSpacing.screenPadding,
                96,
              ),
              children: [
                if (events.length > 1) ...[
                  const Text(
                    'Pilih Rangkaian Acara',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (var i = 0; i < events.length; i++) ...[
                          _EventSelectorChip(
                            event: events[i],
                            selected: i == safeIndex,
                            onTap: () => setState(() => _selectedIndex = i),
                          ),
                          const SizedBox(width: 8),
                        ],
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                if (_showCalendar) ...[
                  _EventMiniCalendarCard(
                    events: events,
                    selectedIndex: safeIndex,
                    onSelectEvent: (idx) => setState(() => _selectedIndex = idx),
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
                _EventHeaderCard(event: selected),
                if (selected.isCompleted) ...[
                  const SizedBox(height: AppSpacing.md),
                  _EventReviewBanner(
                    event: selected,
                    onWriteReview: () => _showReviewSheet(selected),
                  ),
                ],
                if (selected.crew.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.md),
                  _EventCrewSection(crew: selected.crew),
                ],
                const SizedBox(height: AppSpacing.lg),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'Timeline Rundown & Jadwal',
                        style: AppTypography.heading(20),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${selected.approvedScheduleCount}/${selected.schedules.length} Siap',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 12.5,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                const Text(
                  'Jam pelaksanaan, lokasi, dan PIC kru disiapkan oleh Admin MyDream (vendor otomatis terjadwal selama tersedia).',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 14),
                if (selected.schedules.isEmpty)
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.surface,
                      borderRadius: AppRadius.card,
                    ),
                    child: const EmptyState(
                      message:
                          'Admin sedang menyusun jadwal vendor untuk rangkaian acara ini.',
                      icon: Icons.schedule_outlined,
                    ),
                  )
                else
                  for (var i = 0; i < selected.schedules.length; i++)
                    _ScheduleTimelineTile(
                      item: selected.schedules[i],
                      isLast: i == selected.schedules.length - 1,
                    ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _EventSelectorChip extends StatelessWidget {
  const _EventSelectorChip({
    required this.event,
    required this.selected,
    required this.onTap,
  });

  final ClientEventItem event;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: selected ? AppColors.primary : AppColors.surface,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                event.name,
                style: TextStyle(
                  color: selected ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                ),
              ),
              if (event.eventDate != null)
                Text(
                  formatDateShortId(event.eventDate!),
                  style: TextStyle(
                    color: selected ? Colors.white70 : AppColors.textSecondary,
                    fontSize: 11,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _EventMiniCalendarCard extends StatefulWidget {
  const _EventMiniCalendarCard({
    required this.events,
    required this.selectedIndex,
    required this.onSelectEvent,
  });

  final List<ClientEventItem> events;
  final int selectedIndex;
  final ValueChanged<int> onSelectEvent;

  @override
  State<_EventMiniCalendarCard> createState() => _EventMiniCalendarCardState();
}

class _EventMiniCalendarCardState extends State<_EventMiniCalendarCard> {
  static const _monthsId = [
    'Januari',
    'Februari',
    'Maret',
    'April',
    'Mei',
    'Juni',
    'Juli',
    'Agustus',
    'September',
    'Oktober',
    'November',
    'Desember',
  ];
  static const _weekdays = ['Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab', 'Min'];

  late DateTime _focusedMonth;

  @override
  void initState() {
    super.initState();
    final initialDate = widget.events[widget.selectedIndex].eventDate ?? DateTime.now();
    _focusedMonth = DateTime(initialDate.year, initialDate.month);
  }

  @override
  void didUpdateWidget(covariant _EventMiniCalendarCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedIndex != widget.selectedIndex) {
      final d = widget.events[widget.selectedIndex].eventDate;
      if (d != null) {
        _focusedMonth = DateTime(d.year, d.month);
      }
    }
  }

  String _key(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  @override
  Widget build(BuildContext context) {
    final eventIndexByDate = <String, int>{};
    for (var i = 0; i < widget.events.length; i++) {
      final d = widget.events[i].eventDate;
      if (d != null) {
        eventIndexByDate.putIfAbsent(_key(d), () => i);
      }
    }

    final selectedDate = widget.events[widget.selectedIndex].eventDate;
    final selectedKey = selectedDate != null ? _key(selectedDate) : null;
    final todayKey = _key(DateTime.now());

    final firstOfMonth = DateTime(_focusedMonth.year, _focusedMonth.month, 1);
    final daysInMonth = DateTime(_focusedMonth.year, _focusedMonth.month + 1, 0).day;
    final leadingBlanks = firstOfMonth.weekday - 1; // Monday = 1 -> 0 blanks
    final totalCells = leadingBlanks + daysInMonth;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              IconButton(
                tooltip: 'Bulan Sebelumnya',
                onPressed: () => setState(() {
                  _focusedMonth =
                      DateTime(_focusedMonth.year, _focusedMonth.month - 1);
                }),
                icon: const Icon(Icons.chevron_left_rounded),
                visualDensity: VisualDensity.compact,
              ),
              Expanded(
                child: Text(
                  '${_monthsId[_focusedMonth.month - 1]} ${_focusedMonth.year}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14.5,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              IconButton(
                tooltip: 'Bulan Berikutnya',
                onPressed: () => setState(() {
                  _focusedMonth =
                      DateTime(_focusedMonth.year, _focusedMonth.month + 1);
                }),
                icon: const Icon(Icons.chevron_right_rounded),
                visualDensity: VisualDensity.compact,
              ),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            children: [
              for (final day in _weekdays)
                Expanded(
                  child: Text(
                    day,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: totalCells,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 7,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 1.15,
            ),
            itemBuilder: (context, index) {
              if (index < leadingBlanks) {
                return const SizedBox.shrink();
              }
              final dayNum = index - leadingBlanks + 1;
              final cellDate =
                  DateTime(_focusedMonth.year, _focusedMonth.month, dayNum);
              final k = _key(cellDate);
              final eventIdx = eventIndexByDate[k];
              final hasEvent = eventIdx != null;
              final isSelected = k == selectedKey;
              final isToday = k == todayKey;

              return InkWell(
                onTap: hasEvent ? () => widget.onSelectEvent(eventIdx) : null,
                borderRadius: BorderRadius.circular(10),
                child: Container(
                  decoration: BoxDecoration(
                    color: isSelected
                        ? AppColors.primary
                        : hasEvent
                            ? AppColors.gold.withValues(alpha: 0.18)
                            : isToday
                                ? AppColors.surfaceTint
                                : null,
                    borderRadius: BorderRadius.circular(10),
                    border: isToday && !isSelected
                        ? Border.all(
                            color: AppColors.primary.withValues(alpha: 0.4),
                          )
                        : null,
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        '$dayNum',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: (hasEvent || isSelected || isToday)
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : AppColors.textPrimary,
                        ),
                      ),
                      if (hasEvent)
                        Container(
                          width: 5,
                          height: 5,
                          margin: const EdgeInsets.only(top: 2),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.gold : AppColors.primary,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _EventHeaderCard extends StatelessWidget {
  const _EventHeaderCard({required this.event});

  final ClientEventItem event;

  @override
  Widget build(BuildContext context) {
    final total = event.schedules.length;
    final approved = event.approvedScheduleCount;
    final progress = total > 0 ? approved / total : 0.0;

    final statusColor = switch (event.status) {
      'completed' || 'ongoing' => const Color(0xFF1E7E5A),
      'cancelled' => AppColors.error,
      _ => AppColors.gold,
    };

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  event.statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontWeight: FontWeight.w700,
                    fontSize: 11,
                  ),
                ),
              ),
              const Spacer(),
              Text(
                event.eventType.toUpperCase(),
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  letterSpacing: 0.8,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(event.name, style: AppTypography.heading(22)),
          if (event.packageName != null) ...[
            const SizedBox(height: 4),
            Text(
              'Paket: ${event.packageName}',
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
          const SizedBox(height: 10),
          Wrap(
            spacing: 14,
            runSpacing: 6,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.calendar_month_outlined,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      event.eventDate != null
                          ? formatDateId(event.eventDate!)
                          : 'Tanggal belum ditentukan',
                      style: const TextStyle(
                        color: AppColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.groups_outlined,
                      size: 16, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Text(
                    '${event.guestCount} Tamu',
                    style: const TextStyle(
                      color: AppColors.textPrimary,
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (event.notes != null && event.notes!.trim().isNotEmpty) ...[
            const SizedBox(height: 8),
            Text(
              'Catatan: ${event.notes}',
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: 12,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.surfaceTint,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'Kesiapan Jadwal & PIC (Admin)',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${(progress * 100).round()}% ($approved/$total)',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: AppColors.primary,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(6),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: AppColors.outline.withValues(alpha: 0.3),
                    valueColor:
                        const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _EventCrewSection extends StatelessWidget {
  const _EventCrewSection({required this.crew});

  final List<ClientEventCrew> crew;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.outline.withValues(alpha: 0.5)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.badge_outlined, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Text(
                'Koordinator & Kru WO Bertugas',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
              ),
            ],
          ),
          const SizedBox(height: 10),
          for (final c in crew)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppColors.primary.withValues(alpha: 0.12),
                    child: Text(
                      c.memberName.isNotEmpty
                          ? c.memberName[0].toUpperCase()
                          : 'K',
                      style: const TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          c.memberName,
                          style: const TextStyle(
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                        Text(
                          c.role,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: 11.5,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (c.callSign != null && c.callSign!.trim().isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.surfaceTint,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        'HT: ${c.callSign}',
                        style: const TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _EventReviewBanner extends StatelessWidget {
  const _EventReviewBanner({
    required this.event,
    required this.onWriteReview,
  });

  final ClientEventItem event;
  final VoidCallback onWriteReview;

  @override
  Widget build(BuildContext context) {
    if (event.hasReview) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: const Color(0xFF1E7E5A).withValues(alpha: 0.1),
          borderRadius: AppRadius.card,
          border: Border.all(
            color: const Color(0xFF1E7E5A).withValues(alpha: 0.3),
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.verified_rounded,
                    color: Color(0xFF1E7E5A), size: 18),
                const SizedBox(width: 6),
                const Expanded(
                  child: Text(
                    'Ulasan Anda Telah Diterbitkan',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      color: Color(0xFF1E7E5A),
                      fontSize: 13.5,
                    ),
                  ),
                ),
                if (event.reviewRating != null)
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var i = 0; i < event.reviewRating!; i++)
                        const Icon(Icons.star_rounded,
                            color: AppColors.gold, size: 16),
                    ],
                  ),
              ],
            ),
            if (event.reviewContent != null) ...[
              const SizedBox(height: 6),
              Text(
                event.reviewContent!,
                style: const TextStyle(
                  fontSize: 12.5,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.gold.withValues(alpha: 0.14),
        borderRadius: AppRadius.card,
        border: Border.all(color: AppColors.gold.withValues(alpha: 0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.stars_rounded, color: AppColors.primary, size: 20),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Acara Telah Selesai! Bagikan Cerita & Rating Anda',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Berikan penilaian untuk pengalaman pernikahan Anda bersama MyDream Wedding Organizer.',
            style: TextStyle(fontSize: 12, color: AppColors.textSecondary),
          ),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: onWriteReview,
            style: FilledButton.styleFrom(
              minimumSize: const Size.fromHeight(44),
            ),
            icon: const Icon(Icons.rate_review_outlined, size: 18),
            label: const Text('Beri Rating & Tulis Ulasan'),
          ),
        ],
      ),
    );
  }
}

class _ScheduleTimelineTile extends StatelessWidget {
  const _ScheduleTimelineTile({
    required this.item,
    required this.isLast,
  });

  final ClientScheduleItem item;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final badgeColor = switch (item.status) {
      'approved' => const Color(0xFF1E7E5A),
      'rejected' => AppColors.error,
      _ => AppColors.gold,
    };

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 28,
            child: Column(
              children: [
                Container(
                  width: 14,
                  height: 14,
                  margin: const EdgeInsets.only(top: 4),
                  decoration: BoxDecoration(
                    color: badgeColor,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      color: AppColors.outline.withValues(alpha: 0.6),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.only(bottom: 14),
              child: Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppColors.surface,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                    color: AppColors.outline.withValues(alpha: 0.45),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.access_time_rounded,
                            size: 14, color: AppColors.primary),
                        const SizedBox(width: 4),
                        Expanded(
                          child: Text(
                            item.timeRangeLabel,
                            style: const TextStyle(
                              color: AppColors.primary,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: badgeColor.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            item.statusLabel,
                            style: TextStyle(
                              color: badgeColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 10.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      item.activity,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                    if (item.vendorName != null) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.storefront_outlined,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              '${item.vendorName}${item.vendorCategory != null ? ' · ${item.vendorCategory}' : ''}',
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (item.location != null &&
                        item.location!.trim().isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          const Icon(Icons.place_outlined,
                              size: 14, color: AppColors.textSecondary),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              item.location!,
                              style: const TextStyle(
                                color: AppColors.textSecondary,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                    if (item.picMemberName != null) ...[
                      const SizedBox(height: 6),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceTint,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          'PIC Kru: ${item.picMemberName}${item.picMemberCallSign != null ? ' (${item.picMemberCallSign})' : ''}',
                          style: const TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ],
                    if (item.notes != null &&
                        item.notes!.trim().isNotEmpty) ...[
                      const SizedBox(height: 6),
                      Text(
                        item.notes!,
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: 11.5,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CreateEventBottomSheet extends ConsumerStatefulWidget {
  const _CreateEventBottomSheet({required this.bookings});

  final List<ClientBookingSummary> bookings;

  @override
  ConsumerState<_CreateEventBottomSheet> createState() =>
      _CreateEventBottomSheetState();
}

class _CreateEventBottomSheetState
    extends ConsumerState<_CreateEventBottomSheet> {
  final _nameCtrl = TextEditingController();
  final _guestsCtrl = TextEditingController(text: '100');
  final _notesCtrl = TextEditingController();

  late int _bookingId;
  String _eventType = 'wedding';
  DateTime _eventDate = DateTime.now().add(const Duration(days: 30));
  bool _submitting = false;

  @override
  void initState() {
    super.initState();
    _bookingId = widget.bookings.first.id;
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _guestsCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _eventDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365 * 3)),
    );
    if (picked != null) {
      setState(() => _eventDate = picked);
    }
  }

  Future<void> _submit() async {
    final name = _nameCtrl.text.trim();
    final guests = int.tryParse(_guestsCtrl.text.trim()) ?? 0;
    if (name.length < 3 || guests <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Isi nama acara dan jumlah tamu dengan benar.'),
        ),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      await createClientEvent(
        ref,
        bookingId: _bookingId,
        name: name,
        eventType: _eventType,
        eventDate: _eventDate,
        guestCount: guests,
        notes: _notesCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ValidationException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengajukan acara baru.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Ajukan Rangkaian Acara Baru', style: AppTypography.heading(20)),
            const SizedBox(height: 4),
            const Text(
              'Tambahkan rangkaian acara (misal: Akad, Resepsi, Gladi Bersih, atau Lamaran) ke reservasi Anda.',
              style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5),
            ),
            const SizedBox(height: 16),
            DropdownButtonFormField<int>(
              initialValue: _bookingId,
              decoration: const InputDecoration(labelText: 'Pilih Reservasi'),
              items: [
                for (final b in widget.bookings)
                  DropdownMenuItem(
                    value: b.id,
                    child: Text(
                      '${b.invoiceNumber ?? '#${b.id}'} · ${b.title}',
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _bookingId = v);
              },
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _nameCtrl,
              decoration: const InputDecoration(
                labelText: 'Nama Acara',
                hintText: 'Contoh: Gladi Bersih & Technical Meeting',
              ),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              initialValue: _eventType,
              decoration: const InputDecoration(labelText: 'Jenis Acara'),
              items: const [
                DropdownMenuItem(
                    value: 'wedding', child: Text('Akad & Resepsi Utama')),
                DropdownMenuItem(
                    value: 'rehearsal', child: Text('Gladi Bersih / Rehearsal')),
                DropdownMenuItem(
                    value: 'engagement', child: Text('Lamaran / Pengajian')),
                DropdownMenuItem(
                    value: 'intimate', child: Text('Intimate Party / Lainnya')),
              ],
              onChanged: (v) {
                if (v != null) setState(() => _eventType = v);
              },
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: _pickDate,
                    borderRadius: BorderRadius.circular(12),
                    child: InputDecorator(
                      decoration: const InputDecoration(
                        labelText: 'Tanggal Acara',
                      ),
                      child: Text(formatDateShortId(_eventDate)),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: TextField(
                    controller: _guestsCtrl,
                    keyboardType: TextInputType.number,
                    inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                    decoration: const InputDecoration(
                      labelText: 'Jumlah Tamu',
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _notesCtrl,
              maxLines: 2,
              decoration: const InputDecoration(
                labelText: 'Catatan Acara (Opsional)',
                hintText: 'Permintaan khusus jadwal atau susunan acara',
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: Text(_submitting ? 'Mengirim...' : 'Simpan & Ajukan Acara'),
            ),
          ],
        ),
      ),
    );
  }
}

class _SubmitReviewBottomSheet extends ConsumerStatefulWidget {
  const _SubmitReviewBottomSheet({required this.event});

  final ClientEventItem event;

  @override
  ConsumerState<_SubmitReviewBottomSheet> createState() =>
      _SubmitReviewBottomSheetState();
}

class _SubmitReviewBottomSheetState
    extends ConsumerState<_SubmitReviewBottomSheet> {
  final _excerptCtrl = TextEditingController();
  final _commentCtrl = TextEditingController();
  int _rating = 5;
  bool _submitting = false;

  @override
  void dispose() {
    _excerptCtrl.dispose();
    _commentCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    setState(() => _submitting = true);
    try {
      await submitClientReview(
        ref,
        eventId: widget.event.id,
        rating: _rating,
        excerpt: _excerptCtrl.text.trim(),
        comment: _commentCtrl.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } on ValidationException catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Gagal mengirim ulasan.')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;
    return Padding(
      padding: EdgeInsets.fromLTRB(20, 20, 20, bottomInset + 20),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text('Ulasan Acara Pernikahan', style: AppTypography.heading(20)),
            const SizedBox(height: 4),
            Text(
              widget.event.name,
              style: const TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Penilaian Bintang',
              style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var star = 1; star <= 5; star++)
                  IconButton(
                    onPressed: () => setState(() => _rating = star),
                    iconSize: 36,
                    icon: Icon(
                      star <= _rating
                          ? Icons.star_rounded
                          : Icons.star_border_rounded,
                      color: AppColors.gold,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _excerptCtrl,
              decoration: const InputDecoration(
                labelText: 'Kesan Singkat (Opsional)',
                hintText: 'Contoh: Koordinasi tim WO sangat rapi & tepat waktu!',
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentCtrl,
              maxLines: 4,
              decoration: const InputDecoration(
                labelText: 'Cerita Pengalaman Anda',
                hintText:
                    'Bagikan pengalaman Anda bersama tim dan vendor MyDream...',
              ),
            ),
            const SizedBox(height: 18),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: Text(_submitting ? 'Mengirim...' : 'Kirim Ulasan'),
            ),
          ],
        ),
      ),
    );
  }
}
