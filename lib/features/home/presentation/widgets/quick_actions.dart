import 'package:flutter/material.dart';
import '../../../../core/constants/app_constants.dart';

class QuickActions extends StatelessWidget {
  const QuickActions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hành động nhanh',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.add,
                label: 'Thêm giao dịch',
                color: Theme.of(context).colorScheme.primary,
                onTap: () {
                  // TODO: Navigate to add transaction
                },
              ),
            ),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: _ActionButton(
                icon: Icons.category,
                label: 'Quản lý danh mục',
                color: Colors.orange,
                onTap: () {
                  // TODO: Navigate to categories
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppConstants.defaultPadding),
        Row(
          children: [
            Expanded(
              child: _ActionButton(
                icon: Icons.bar_chart,
                label: 'Xem báo cáo',
                color: Colors.green,
                onTap: () {
                  // TODO: Navigate to reports
                },
              ),
            ),
            const SizedBox(width: AppConstants.defaultPadding),
            Expanded(
              child: _ActionButton(
                icon: Icons.sync,
                label: 'Đồng bộ dữ liệu',
                color: Colors.blue,
                onTap: () {
                  // TODO: Sync data
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.borderRadius),
      child: Container(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(AppConstants.borderRadius),
          border: Border.all(
            color: color.withOpacity(0.3),
            width: 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: color,
              size: 32,
            ),
            const SizedBox(height: AppConstants.smallPadding),
            Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: color,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
