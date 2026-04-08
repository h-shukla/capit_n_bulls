import 'package:capit_n_bulls/wallet_screen.dart';
import 'package:flutter/material.dart';

class WatchlistAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title; // Add this

  const WatchlistAppBar({super.key, required this.title}); // Add required param

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      titleSpacing: 16,
      title: Text(
        title, // Use the parameter here
        style: const TextStyle(
          color: Colors.black,
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
              color: Colors.black87,
              size: 26,
            ),
          ),
        ),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Divider(height: 1, thickness: 1, color: Colors.grey.shade200),
      ),
    );
  }
}
