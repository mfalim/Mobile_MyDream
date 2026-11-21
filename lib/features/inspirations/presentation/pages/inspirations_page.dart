import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:w51/app/router/route_names.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_spacing.dart';
import 'package:w51/app/theme/app_typography.dart';
import 'package:w51/core/errors/app_exceptions.dart';
import 'package:w51/core/widgets/empty_state.dart';
import 'package:w51/core/widgets/error_state.dart';
import 'package:w51/features/inspirations/domain/entities/inspiration_entities.dart';
import 'package:w51/features/inspirations/presentation/providers/inspirations_provider.dart';
import 'package:w51/features/inspirations/presentation/widgets/more_stories_list.dart';
import 'package:w51/features/inspirations/presentation/widgets/story_view.dart';

class InspirationsPage extends ConsumerStatefulWidget {
  const InspirationsPage({super.key});

  @override
  ConsumerState<InspirationsPage> createState() => _InspirationsPageState();
}

class _InspirationsPageState extends ConsumerState<InspirationsPage> {
  String? _category;

  Future<void> _pickCategory(List<String> categories) async {
    final result = await showModalBottomSheet<String>(
      context: context,
      showDragHandle: true,
      backgroundColor: AppColors.surface,
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Filter Kategori Artikel', style: AppTypography.heading(20)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final c in ['', ...categories])
                    ChoiceChip(
                      label: Text(c.isEmpty ? 'Semua' : c),
                      selected: (_category ?? '') == c,
                      onSelected: (_) => Navigator.of(ctx).pop(c),
                      selectedColor: AppColors.coral.withValues(alpha: 0.3),
                      backgroundColor: AppColors.surfaceTint,
                      side: BorderSide.none,
                      shape: const StadiumBorder(),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
    if (result == null || !mounted) return;
    setState(() => _category = result.isEmpty ? null : result);
  }

  @override
  Widget build(BuildContext context) {
    final data = ref.watch(inspirationsDataProvider);
    return SafeArea(
      bottom: false,
      child: data.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ErrorState(
          message: userMessage(e, fallback: 'Artikel gagal dimuat.'),
          onRetry: () => ref.invalidate(inspirationsDataProvider),
        ),
        data: _buildContent,
      ),
    );
  }

  Widget _buildContent(InspirationsData d) {
    const gap = SizedBox(height: AppSpacing.lg);
    final story = d.story;
    final filteredAll = _category == null
        ? d.more
        : d.allArticles.where((s) => s.category == _category).toList();
    final showMainStory =
        story != null && (_category == null || story.category == _category);
    final listItems = (_category != null && showMainStory)
        ? filteredAll.where((s) => s.id != story.id).toList()
        : filteredAll;

    return Stack(
      children: [
        RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(inspirationsDataProvider);
            await ref.read(inspirationsDataProvider.future);
          },
          child: ListView(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.screenPadding,
              AppSpacing.md,
              AppSpacing.screenPadding,
              96,
            ),
            children: [
              Text('CERITA & TIPS', style: AppTypography.eyebrow),
              const SizedBox(height: 4),
              Text('Artikel & Blog MyDream', style: AppTypography.heading(26)),
              const SizedBox(height: 4),
              const Text(
                'Pengalaman client, panduan perencanaan, dan tips memilih vendor untuk hari istimewa Anda.',
                style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
              ),
              if (d.categories.isNotEmpty) ...[
                const SizedBox(height: 12),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      for (final c in ['', ...d.categories])
                        Padding(
                          padding: const EdgeInsets.only(right: 8),
                          child: ChoiceChip(
                            label: Text(c.isEmpty ? 'Semua' : c),
                            selected: (_category ?? '') == c,
                            onSelected: (_) =>
                                setState(() => _category = c.isEmpty ? null : c),
                            selectedColor: AppColors.primary,
                            labelStyle: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: (_category ?? '') == c
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
              ],
              const SizedBox(height: AppSpacing.md),
              if (showMainStory) ...[
                StoryView(
                  key: ValueKey(story.id),
                  story: story,
                  onOpenVendor: (v) {
                    final id = v.vendorId;
                    if (id != null) context.push(AppRoutes.vendorDetailPath(id));
                  },
                  onRelatedPackage: (id) =>
                      context.push(AppRoutes.packageDetailPath(id)),
                ),
                gap,
                const Divider(color: AppColors.outline),
                gap,
              ] else if (_category == null) ...[
                const EmptyState(
                  message: 'Belum ada artikel.',
                  icon: Icons.menu_book_outlined,
                ),
                gap,
              ],
              MoreStoriesList(
                stories: listItems,
                onOpen: (s) => context.push(AppRoutes.storyPath(s.id)),
                onSeeAll: () => setState(() => _category = null),
              ),
            ],
          ),
        ),
        if (d.categories.isNotEmpty)
          Positioned(
            left: 0,
            right: 0,
            bottom: 16,
            child: Center(
              child: FilledButton.icon(
                onPressed: () => _pickCategory(d.categories),
                icon: const Icon(Icons.tune, size: 18),
                label: Text(
                  _category == null
                      ? 'Filter Kategori Artikel'
                      : 'Kategori: $_category',
                ),
                style: FilledButton.styleFrom(
                  minimumSize: const Size(0, 48),
                  padding: const EdgeInsets.symmetric(horizontal: 22),
                  elevation: 3,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
