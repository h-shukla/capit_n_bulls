import 'package:capit_n_bulls/wallet_screen.dart';
import 'package:flutter/material.dart';

class WatchlistAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const WatchlistAppBar({super.key, required this.title});

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBar(
      // Let theme.appBarTheme.backgroundColor drive this
      elevation: 0,
      titleSpacing: 16,
      title: Text(
        title,
        style: TextStyle(
          color: theme.colorScheme.onSurface,
          fontSize: 22,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.2,
        ),
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 16),
          child: GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WalletScreen()),
              );
            },
            child: Icon(
              Icons.credit_card_outlined,
              color: theme.iconTheme.color,
              size: 26,
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(
          height: 1,
          thickness: 1,
          color: isDark ? const Color(0xFF2C2C2C) : Colors.grey.shade200,
        ),
      ),
    );
  }
}
