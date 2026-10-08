import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/features/vendor/presentation/widgets/vendor_categories_section.dart';
import 'package:w51/features/vendor/presentation/widgets/vendor_search_section.dart';
import 'package:w51/features/vendor/presentation/widgets/vendor_top_bar.dart';

class VendorPage extends StatelessWidget {
  const VendorPage({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      bottom: false,
      child: Column(
        children: [
          const VendorTopBar(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.only(bottom: 24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const VendorSearchSection(),
                  const VendorCategoriesSection(),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 32, 20, 8),
                    child: Text(
                      'Vendor pilihan',
                      style: TextStyle(
                        color: AppColors.ink,
                        fontSize: 17,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const _FeaturedVendor(),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _FeaturedVendor extends StatelessWidget {
  const _FeaturedVendor();

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border.all(color: AppColors.line),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 27,
            backgroundColor: AppColors.blush,
            child: Icon(Icons.camera_alt_outlined, color: AppColors.coralDark),
          ),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Lensa Cerita Studio',
                    style: TextStyle(fontWeight: FontWeight.w600)),
                SizedBox(height: 4),
                Text('Fotografi • Yogyakarta',
                    style: TextStyle(color: AppColors.muted, fontSize: 12)),
              ],
            ),
          ),
          Icon(Icons.star_rounded, color: Color(0xFFE9B45E), size: 18),
          SizedBox(width: 3),
          Text('4.9', style: TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
