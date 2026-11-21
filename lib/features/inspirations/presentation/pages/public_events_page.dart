import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/core/widgets/app_image.dart';
import 'package:w51/core/widgets/badge_pill.dart';
import 'package:w51/core/widgets/empty_state.dart';
import 'package:w51/core/widgets/error_state.dart';
import 'package:w51/features/contact/presentation/contact_actions.dart';
import 'package:w51/features/inspirations/domain/entities/inspiration_entities.dart';
import 'package:w51/features/inspirations/presentation/providers/inspirations_provider.dart';
import 'package:w51/features/inspirations/presentation/widgets/story_vendors.dart';

class PublicEventsPage extends ConsumerStatefulWidget {
  const PublicEventsPage({super.key});

  @override
  ConsumerState<PublicEventsPage> createState() => _PublicEventsPageState();
}

class _PublicEventsPageState extends ConsumerState<PublicEventsPage> {
  String? _status;

  void _openDetail(PublicEventItem event) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => PublicEventDetailPage(event: event),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(inspirationsDataProvider);
    return SafeArea(
      bottom: false,
      child: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(
          message: userMessage(e, fallback: 'Event gagal dimuat.'),
          onRetry: () => ref.invalidate(inspirationsDataProvider),
        ),
        data: (d) => _buildContent(d.events),
      ),
    );
  }

  Widget _buildContent(List<PublicEventItem> allEvents) {
    final ongoingCount = allEvents.where((e) => e.isOngoing).length;
    final upcomingCount = allEvents.where((e) => e.isUpcoming).length;
    final finishedCount = allEvents.where((e) => e.isFinished).length;

    final filtered = _status == null
        ? allEvents
        : allEvents.where((e) => e.status == _status).toList();

    final filters = <(String?, String)>[
      (null, 'Semua (${allEvents.length})'),
      if (ongoingCount > 0) ('ongoing', '🔴 Berlangsung ($ongoingCount)'),
      ('upcoming', 'Akan Datang ($upcomingCount)'),
      ('finished', 'Selesai ($finishedCount)'),
    ];

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(inspirationsDataProvider);
        await ref.read(inspirationsDataProvider.future);
      },
      child: ListView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.md,
          AppSpacing.screenPadding,
          AppSpacing.xl,
        ),
        children: [
          Text('KALENDER KEGIATAN', style: AppTypography.eyebrow),
          const SizedBox(height: 4),
          Text('Event & Pameran MyDream', style: AppTypography.heading(26)),
          const SizedBox(height: 4),
          const Text(
            'Ikuti pameran pernikahan, open house venue, workshop, dan sesi konsultasi bersama tim MyDream.',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 12),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (final (key, label) in filters)
                  Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: ChoiceChip(
                      label: Text(label),
                      selected: _status == key,
                      onSelected: (_) => setState(() => _status = key),
                      selectedColor: AppColors.primary,
                      labelStyle: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: _status == key
                            ? Colors.white
                            : AppColors.textPrimary,
                      ),
                      backgroundColor: AppColors.surfaceTint,
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                      showCheckmark: false,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (filtered.isEmpty)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 24),
              child: EmptyState(
                message: 'Belum ada event di kategori ini.',
                icon: Icons.event_available_outlined,
              ),
            )
          else
            for (final event in filtered)
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: PublicEventCard(
                  event: event,
                  onTap: () => _openDetail(event),
                ),
              ),
          const SizedBox(height: 8),
          _EventCtaCard(
            title: 'Ingin Diundang ke Event Berikutnya?',
            subtitle:
                'Hubungi tim kami untuk info event dan pameran terbaru dari MyDream.',
            buttonLabel: 'Hubungi via WhatsApp',
            onPressed: () =>
                contactAdmin(context, ref, topic: 'info event terbaru MyDream'),
          ),
        ],
      ),
    );
  }
}

class PublicEventCard extends StatelessWidget {
  const PublicEventCard({
    required this.event,
    required this.onTap,
    super.key,
  });

  final PublicEventItem event;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final (badgeBg, badgeFg) = _statusColors(event.status);
    final dateAndTime = [
      if (event.dateLabel != null && event.dateLabel!.isNotEmpty)
        event.dateLabel!,
      if (event.timeLabel != null && event.timeLabel!.isNotEmpty)
        event.timeLabel!,
    ].join(' · ');

    return Material(
      color: AppColors.surface,
      borderRadius: AppRadius.card,
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: onTap,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: 170,
              width: double.infinity,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ColorFiltered(
                    colorFilter: event.isFinished
                        ? const ColorFilter.mode(
                            Colors.grey,
                            BlendMode.saturation,
                          )
                        : const ColorFilter.mode(
                            Colors.transparent,
                            BlendMode.multiply,
                          ),
                    child: AppImage(
                      url: event.photoUrl,
                      icon: Icons.event_outlined,
                    ),
                  ),
                  Positioned(
                    top: 12,
                    left: 12,
                    child: BadgePill(
                      event.statusLabel,
                      background: badgeBg,
                      foreground: badgeFg,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    event.title,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w700,
                      height: 1.3,
                    ),
                  ),
                  if (dateAndTime.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    _IconMeta(
                      icon: Icons.calendar_today_outlined,
                      text: dateAndTime,
                    ),
                  ],
                  if (event.location != null &&
                      event.location!.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    _IconMeta(
                      icon: Icons.location_on_outlined,
                      text: event.location!,
                    ),
                  ],
                  if (event.description != null &&
                      event.description!.isNotEmpty) ...[
                    const SizedBox(height: 8),
                    Text(
                      event.description!,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 13,
                        color: AppColors.textSecondary,
                        height: 1.4,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class PublicEventDetailPage extends ConsumerWidget {
  const PublicEventDetailPage({required this.event, super.key});

  final PublicEventItem event;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final (badgeBg, badgeFg) = _statusColors(event.status, subtleUpcoming: true);

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: Text('Detail Event', style: AppTypography.heading(20)),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(
          AppSpacing.screenPadding,
          AppSpacing.sm,
          AppSpacing.screenPadding,
          AppSpacing.xl,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ClipRRect(
              borderRadius: AppRadius.card,
              child: SizedBox(
                height: 220,
                child: AppImage(
                  url: event.photoUrl,
                  icon: Icons.event_outlined,
                ),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerLeft,
              child: BadgePill(
                event.statusLabel,
                background: badgeBg,
                foreground: badgeFg,
              ),
            ),
            const SizedBox(height: 10),
            Text(event.title, style: AppTypography.heading(24)),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.surfaceTint,
                borderRadius: AppRadius.card,
              ),
              child: Column(
                children: [
                  _InfoRow(
                    icon: Icons.calendar_today_outlined,
                    label: 'TANGGAL',
                    value: event.dateLabel ?? 'Akan diumumkan',
                  ),
                  const Divider(height: 20, color: AppColors.outline),
                  _InfoRow(
                    icon: Icons.schedule_outlined,
                    label: 'WAKTU',
                    value: event.timeLabel ?? 'Akan diumumkan',
                  ),
                  const Divider(height: 20, color: AppColors.outline),
                  _InfoRow(
                    icon: Icons.location_on_outlined,
                    label: 'LOKASI',
                    value: event.location ?? 'Akan diumumkan',
                  ),
                ],
              ),
            ),
            if (event.description != null &&
                event.description!.isNotEmpty) ...[
              const SizedBox(height: 20),
              Text(
                event.description!,
                style: const TextStyle(
                  fontSize: 15,
                  height: 1.65,
                  color: AppColors.textPrimary,
                ),
              ),
            ],
            if (event.vendors.isNotEmpty) ...[
              const SizedBox(height: 24),
              StoryVendors(
                title: 'Vendor yang Berpartisipasi',
                vendors: event.vendors,
                onOpen: (v) {
                  final id = v.vendorId;
                  if (id != null) context.push(AppRoutes.vendorDetailPath(id));
                },
              ),
            ],
            if (!event.isFinished) ...[
              const SizedBox(height: 24),
              _EventCtaCard(
                title: 'Mau Ikut Hadir?',
                subtitle:
                    'Daftarkan diri lewat WhatsApp, tim kami akan mengonfirmasi kehadiranmu.',
                buttonLabel: 'Daftar via WhatsApp',
                onPressed: () => contactAdmin(
                  context,
                  ref,
                  topic: 'pendaftaran event ${event.title}',
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

(Color, Color) _statusColors(String status, {bool subtleUpcoming = false}) =>
    switch (status) {
      'ongoing' => (AppColors.primary, Colors.white),
      'finished' => (Colors.black87, Colors.white),
      _ => (
          subtleUpcoming
              ? AppColors.coral.withValues(alpha: 0.25)
              : AppColors.surface,
          AppColors.primary,
        ),
    };

class _IconMeta extends StatelessWidget {
  const _IconMeta({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 13.5, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Expanded(
          child: Text(
            text,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppColors.primary),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: AppTypography.eyebrow.copyWith(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _EventCtaCard extends StatelessWidget {
  const _EventCtaCard({
    required this.title,
    required this.subtitle,
    required this.buttonLabel,
    required this.onPressed,
  });

  final String title;
  final String subtitle;
  final String buttonLabel;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surfaceTint,
        borderRadius: AppRadius.card,
      ),
      child: Column(
        children: [
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppTypography.heading(18),
          ),
          const SizedBox(height: 6),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton.icon(
            onPressed: onPressed,
            icon: const Icon(Icons.chat_bubble_outline, size: 18),
            label: Text(buttonLabel),
            style: FilledButton.styleFrom(
              minimumSize: const Size(0, 44),
              padding: const EdgeInsets.symmetric(horizontal: 20),
            ),
          ),
        ],
      ),
    );
  }
}
