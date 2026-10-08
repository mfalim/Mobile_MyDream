import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';

class VendorCategoriesSection extends StatelessWidget {
  const VendorCategoriesSection({super.key});

  static const _categories = [
    (
      'Venue',
      'https://images.unsplash.com/photo-1519167758481-83f550bb49b3?auto=format&fit=crop&w=800&q=80',
      Icons.location_city_rounded
    ),
    (
      'Fotografer',
      'https://images.unsplash.com/photo-1554080353-a576cf803bda?auto=format&fit=crop&w=800&q=80',
      Icons.camera_alt_outlined
    ),
    (
      'MUA',
      'https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?auto=format&fit=crop&w=800&q=80',
      Icons.brush_outlined
    ),
    (
      'Catering',
      'https://images.unsplash.com/photo-1515003197210-e0cd71810b5f?auto=format&fit=crop&w=800&q=80',
      Icons.restaurant_outlined
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Jelajahi Kategori',
              style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _categories.length,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.55,
            ),
            itemBuilder: (context, index) {
              final category = _categories[index];
              return ClipRRect(
                borderRadius: BorderRadius.circular(7),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    Image.network(
                      category.$2,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) =>
                          Container(color: AppColors.blush),
                    ),
                    ColoredBox(color: Colors.black.withValues(alpha: 0.35)),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(category.$3, color: Colors.white, size: 30),
                        const SizedBox(height: 7),
                        Text(category.$1,
                            style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600)),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
