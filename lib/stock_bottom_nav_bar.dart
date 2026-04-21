import 'package:flutter/material.dart';

class StockBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;

  const StockBottomNavBar({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    final bgColor = colorScheme.surface;
    final activeColor = colorScheme.surfaceContainerHighest;
    final iconColor = colorScheme.onSurface;

    final items = [
      (Icons.home_outlined, Icons.home, 'Home'),
      (Icons.list_alt_outlined, Icons.list_alt, 'Watchlist'),
      (Icons.menu_book_outlined, Icons.menu_book, 'Markets'),
      (Icons.currency_rupee_outlined, Icons.currency_rupee, 'Portfolio'),
      (Icons.menu_outlined, Icons.menu, 'More'),
    ];

    return Container(
      color: bgColor,
      child: Row(
        children: List.generate(items.length, (index) {
          final isActive = index == currentIndex;
          final (outlinedIcon, filledIcon, label) = items[index];

          return Expanded(
            child: GestureDetector(
              onTap: () => onTap(index),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                color: isActive ? activeColor : bgColor,
                padding: const EdgeInsets.symmetric(vertical: 12),
                height: 80,
                child: Icon(
                  isActive ? filledIcon : outlinedIcon,
                  size: 26,
                  color: isActive
                      ? colorScheme.primary
                      : iconColor.withValues(alpha: 0.7),
                ),
              ),
            ),
          );
        }),
      ),
    );
  }
}
