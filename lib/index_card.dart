import 'package:flutter/material.dart';
import './stock.dart';

class IndexCard extends StatelessWidget {
  final IndexData data;
  final VoidCallback? onTap;

  const IndexCard({super.key, required this.data, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    const Color gainColor = Color(0xFF3FD47E);
    const Color lossColor = Color(0xFFE05252);
    final semanticColor = data.isPositive ? gainColor : lossColor;

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          decoration: BoxDecoration(
            color: isDark
                ? theme
                      .colorScheme
                      .surface // dark: keep as-is
                : Colors.white, // light: pure white card
            borderRadius: BorderRadius.circular(10),
            // Softer border: barely visible in light, subtle in dark
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(
                      alpha: 0.08,
                    ) // dark: very faint white
                  : Colors.black.withValues(
                      alpha: 0.07,
                    ), // light: very faint shadow-like
              width: 1,
            ),
            boxShadow: isDark
                ? [] // dark mode: no shadow needed, surface contrast is enough
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.06),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Title: single line with ellipsis ──────────────────────────
              Text(
                data.name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 5),
              // ── Value ─────────────────────────────────────────────────────
              Text(
                data.value,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              // ── Change pill ───────────────────────────────────────────────
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                decoration: BoxDecoration(
                  color: semanticColor.withValues(alpha: isDark ? 0.15 : 0.12),
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
