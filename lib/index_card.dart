import 'package:flutter/material.dart';
import './stock.dart';
import './providers/theme_provider.dart';

class IndexCard extends StatelessWidget {
  final IndexData data;
  final VoidCallback? onTap;

  const IndexCard({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    // Use the semantic colors from your theme setup
    // Fallback to standard green/red if the constants aren't in scope
    final Color gainColor = const Color(0xFF3FD47E);
    final Color lossColor = const Color(0xFFE05252);
    final semanticColor = data.isPositive ? gainColor : lossColor;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            // Uses the surface color defined in your dark/light themes
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              // Adds a subtle border that matches your theme's outline
              color: theme.dividerColor,
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.name,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                  // Uses the "subtle" color from theme
                ),
              ),
              const SizedBox(height: 5),
              Text(
                data.value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  // Automatically switches between _darkOnBg and black
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: semanticColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      data.isPositive
                          ? Icons.arrow_upward_rounded
                          : Icons.arrow_downward_rounded,
                      size: 9,
                      color: semanticColor,
                    ),
                    const SizedBox(width: 2),
                    Text(
                      data.change,
                      style: TextStyle(
                        fontSize: 10,
                        color: semanticColor,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
