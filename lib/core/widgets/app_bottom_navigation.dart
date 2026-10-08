import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';

class AppBottomNavigation extends StatelessWidget {
  const AppBottomNavigation({
    required this.selectedIndex,
    required this.onItemSelected,
    super.key,
  });

  final int selectedIndex;
  final ValueChanged<int> onItemSelected;

  static const _items = [
    (Icons.home_outlined, Icons.home_rounded, 'Home'),
    (Icons.storefront_outlined, Icons.storefront_rounded, 'Vendors'),
    (Icons.shopping_bag_outlined, Icons.shopping_bag_rounded, 'Store'),
    (Icons.favorite_border_rounded, Icons.favorite_rounded, 'Inspirations'),
    (Icons.person_outline_rounded, Icons.person_rounded, 'Profile'),
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: Colors.white,
        border: const Border(top: BorderSide(color: AppColors.line)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, -3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          for (var index = 0; index < _items.length; index++) _buildItem(index),
        ],
      ),
    );
  }

  Widget _buildItem(int index) {
    final item = _items[index];
    final selected = selectedIndex == index;
    final color = selected ? AppColors.coralDark : AppColors.muted;

    return Expanded(
      child: InkWell(
        onTap: () => onItemSelected(index),
        child: SizedBox(
          height: double.infinity,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(selected ? item.$2 : item.$1, size: 23, color: color),
              const SizedBox(height: 4),
              Text(
                item.$3,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  color: color,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
