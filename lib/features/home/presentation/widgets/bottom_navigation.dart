import 'package:flutter/material.dart';

class CustomBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const CustomBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildNavItem(
                icon: Icons.grid_view,
                label: 'Tổng quan',
                index: 0,
                isSelected: currentIndex == 0,
                color: Colors.pink[400]!,
              ),
              _buildNavItem(
                icon: Icons.history,
                label: 'Lịch sử',
                index: 1,
                isSelected: currentIndex == 1,
                color: Colors.grey[600]!,
              ),
              _buildNavItem(
                icon: Icons.bar_chart,
                label: 'Báo cáo',
                index: 2,
                isSelected: currentIndex == 2,
                color: Colors.grey[600]!,
              ),
              _buildNavItem(
                icon: Icons.menu,
                label: 'Menu',
                index: 3,
                isSelected: currentIndex == 3,
                color: Colors.grey[600]!,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isSelected,
    required Color color,
  }) {
    return GestureDetector(
      onTap: () => onTap(index),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isSelected ? color : Colors.grey[400],
            size: 24,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              color: isSelected ? color : Colors.grey[400],
              fontSize: 12,
              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
