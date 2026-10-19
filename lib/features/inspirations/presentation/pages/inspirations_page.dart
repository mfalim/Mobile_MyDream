import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';

class InspirationsPage extends StatefulWidget {
  const InspirationsPage({super.key});

  @override
  State<InspirationsPage> createState() => _InspirationsPageState();
}

class _InspirationsPageState extends State<InspirationsPage> {
  String _category = 'Semua';
  final Set<int> _saved = {};

  static const _ideas = [
    ('Garden romance', 'Dekorasi', Icons.local_florist_outlined),
    ('Intimate dinner', 'Resepsi', Icons.dinner_dining_outlined),
    ('Soft classic', 'Busana', Icons.checkroom_outlined),
    ('Golden hour', 'Fotografi', Icons.camera_alt_outlined),
    ('White blooms', 'Dekorasi', Icons.spa_outlined),
    ('Modern vows', 'Resepsi', Icons.favorite_border_rounded),
  ];

  @override
  Widget build(BuildContext context) {
    final visibleIdeas = _category == 'Semua'
        ? _ideas
        : _ideas.where((idea) => idea.$2 == _category).toList();

    return SafeArea(
      bottom: false,
      child: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 22, 20, 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('IDEA BOARD',
                      style: TextStyle(
                          color: AppColors.coralDark,
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 1.2)),
                  const SizedBox(height: 6),
                  const Text('Inspirations',
                      style:
                          TextStyle(fontSize: 24, fontWeight: FontWeight.w700)),
                  const SizedBox(height: 6),
                  const Text(
                      'Kumpulkan ide untuk hari yang terasa seperti kamu.',
                      style: TextStyle(color: AppColors.muted)),
                  const SizedBox(height: 18),
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: [
                        for (final category in const [
                          'Semua',
                          'Dekorasi',
                          'Resepsi',
                          'Busana',
                          'Fotografi'
                        ]) ...[
                          Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: ChoiceChip(
                              label: Text(category),
                              selected: _category == category,
                              onSelected: (_) =>
                                  setState(() => _category = category),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 24),
            sliver: SliverGrid.builder(
              itemCount: visibleIdeas.length,
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 16,
                childAspectRatio: 0.78,
              ),
              itemBuilder: (context, index) {
                final idea = visibleIdeas[index];
                final saved = _saved.contains(index);
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Stack(
                        fit: StackFit.expand,
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              color: index.isEven
                                  ? const Color(0xFFE8EEE5)
                                  : AppColors.blush,
                              child: Center(
                                child: Icon(idea.$3,
                                    size: 42,
                                    color: index.isEven
                                        ? AppColors.sage
                                        : AppColors.coralDark),
                              ),
                            ),
                          ),
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Material(
                              color: Colors.white.withValues(alpha: 0.92),
                              shape: const CircleBorder(),
                              child: IconButton(
                                visualDensity: VisualDensity.compact,
                                tooltip:
                                    saved ? 'Hapus simpanan' : 'Simpan ide',
                                onPressed: () => setState(() {
                                  if (saved) {
                                    _saved.remove(index);
                                  } else {
                                    _saved.add(index);
                                  }
                                }),
                                icon: Icon(
                                  saved
                                      ? Icons.bookmark_rounded
                                      : Icons.bookmark_border_rounded,
                                  color: AppColors.coralDark,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(idea.$1,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    const SizedBox(height: 3),
                    Text(idea.$2,
                        style: const TextStyle(
                            color: AppColors.muted, fontSize: 12)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
