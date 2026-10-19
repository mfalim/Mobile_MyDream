import 'package:flutter/material.dart';
import 'package:w51/app/theme/app_colors.dart';
import 'package:w51/features/home/domain/entities/home_entities.dart';

class ServiceGrid extends StatelessWidget {
  const ServiceGrid({required this.services, this.onSelected, super.key});

  final List<ServiceCategory> services;
  final ValueChanged<ServiceCategory>? onSelected;

  static final _tints = [
    AppColors.coral.withValues(alpha: 0.25),
    AppColors.gold,
    AppColors.outline.withValues(alpha: 0.8),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const gap = 8.0;
        final itemWidth = (constraints.maxWidth - gap * 3) / 4;
        return Wrap(
          spacing: gap,
          runSpacing: 16,
          children: [
            for (var i = 0; i < services.length; i++)
              SizedBox(
                width: itemWidth,
                child: _ServiceItem(
                  service: services[i],
                  tint: _tints[i % _tints.length],
                  onTap: onSelected == null
                      ? null
                      : () => onSelected!(services[i]),
                ),
              ),
          ],
        );
      },
    );
  }
}

class _ServiceItem extends StatelessWidget {
  const _ServiceItem({required this.service, required this.tint, this.onTap});

  final ServiceCategory service;
  final Color tint;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(color: tint, shape: BoxShape.circle),
            child: Icon(service.icon, size: 26, color: AppColors.primary),
          ),
          const SizedBox(height: 8),
          Text(
            service.label,
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ],
      ),
    );
  }
}
