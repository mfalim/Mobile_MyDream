import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/app/theme/app_radius.dart';
import 'package:w51/features/vendors/domain/entities/vendor_detail.dart';
import 'package:w51/core/utils/icon_mapper.dart';

class PackageAccordion extends StatelessWidget {
  const PackageAccordion({
    required this.section,
    this.initiallyExpanded = false,
    super.key,
  });

  final PackageSection section;
  final bool initiallyExpanded;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: AppRadius.card,
      ),
      clipBehavior: Clip.antiAlias,
      child: Theme(
        data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
        child: ExpansionTile(
          initiallyExpanded: initiallyExpanded,
          tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          childrenPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          shape: const RoundedRectangleBorder(),
          collapsedShape: const RoundedRectangleBorder(),
          leading: Container(
            width: 44,
            height: 44,
            decoration: const BoxDecoration(
              color: AppColors.surfaceTint,
              shape: BoxShape.circle,
            ),
            child: Icon(
              iconFor(section.iconKey),
              color: AppColors.primary,
              size: 22,
            ),
          ),
          title: Text(
            section.title,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
          subtitle: Text(
            section.subtitle,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: 13,
            ),
          ),
          children: [
            for (final item in section.inclusions)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Padding(
                      padding: EdgeInsets.only(top: 2),
                      child: Icon(
                        Icons.check_circle_outline,
                        size: 18,
                        color: AppColors.primary,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(item, style: const TextStyle(height: 1.4)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
