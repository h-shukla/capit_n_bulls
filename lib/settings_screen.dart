import 'package:capit_n_bulls/edit_profile_screen.dart';
import 'package:capit_n_bulls/login_screen.dart';
import 'package:capit_n_bulls/providers/auth_provider.dart';
import 'package:capit_n_bulls/providers/trading_prefs_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import './providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  final TextEditingController _qtyController = TextEditingController();

  /// Tracks whether the user is actively editing the qty field so we don't
  /// overwrite their in-progress input when the provider emits a new value.
  bool _qtyFieldFocused = false;

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  // ── Theme helpers ────────────────────────────────────────────────────────

  String _themeModeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
      case ThemeMode.system:
        return 'System';
    }
  }

  ThemeMode _labelToThemeMode(String label) {
    switch (label) {
      case 'Dark':
        return ThemeMode.dark;
      case 'System':
        return ThemeMode.system;
      default:
        return ThemeMode.light;
    }
  }

  // ── Bottom-sheet dialogs ─────────────────────────────────────────────────

  void _showOrderTypeDialog(String currentOrder) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _sheetHandle(theme),
                ...['Delivery', 'Intraday'].map((type) {
                  final selected = currentOrder == type;
                  return InkWell(
                    onTap: () {
                      ref
                          .read(tradingPrefsProvider.notifier)
                          .setDefaultOrder(type);
                      Navigator.pop(context);
                    },
                    child: _sheetRow(
                      theme: theme,
                      label: type,
                      selected: selected,
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showThemeDialog(ThemeMode currentMode) {
    final theme = Theme.of(context);
    showModalBottomSheet(
      context: context,
      backgroundColor: theme.colorScheme.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (_) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _sheetHandle(theme),
                ...['Light', 'Dark', 'System'].map((label) {
                  final selected = _themeModeLabel(currentMode) == label;
                  return InkWell(
                    onTap: () {
                      ref
                          .read(themeProvider.notifier)
                          .setTheme(_labelToThemeMode(label));
                      Navigator.pop(context);
                    },
                    child: _sheetRow(
                      theme: theme,
                      label: label,
                      selected: selected,
                    ),
                  );
                }),
              ],
            ),
          ),
        );
      },
    );
  }

  // ── Shared sheet widgets ─────────────────────────────────────────────────

  Widget _sheetHandle(ThemeData theme) => Container(
    width: 36,
    height: 4,
    margin: const EdgeInsets.only(bottom: 12),
    decoration: BoxDecoration(
      color: theme.dividerColor,
      borderRadius: BorderRadius.circular(2),
    ),
  );

  Widget _sheetRow({
    required ThemeData theme,
    required String label,
    required bool selected,
  }) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 15,
                color: theme.colorScheme.onSurface,
                fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
            if (selected)
              Icon(Icons.check, size: 18, color: theme.colorScheme.primary),
          ],
        ),
      );

  // ── Build ────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    final themeAsync = ref.watch(themeProvider);
    final currentMode = themeAsync.valueOrNull ?? ThemeMode.light;
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    // Auth
    final authNotifier = ref.read(authProvider.notifier);
    final username = authNotifier.username ?? 'User';
    final email = authNotifier.email ?? '';

    // Trading prefs — watch the async provider
    final prefsAsync = ref.watch(tradingPrefsProvider);

    return prefsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error loading settings: $err')),
      data: (prefs) {
        // Sync controller only when the user isn't typing
        if (!_qtyFieldFocused) {
          final text = prefs.defaultQty.toString();
          if (_qtyController.text != text) {
            _qtyController.text = text;
            _qtyController.selection = TextSelection.collapsed(
              offset: text.length,
            );
          }
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Profile ────────────────────────────────────────────────
              GestureDetector(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => const EditProfileScreen()),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person_outline,
                        size: 30,
                        color: colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          username,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w700,
                            color: colorScheme.onSurface,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),
              Divider(color: theme.dividerColor),
              const SizedBox(height: 16),

              // ── Trading Preferences ────────────────────────────────────
              Text(
                'Trading Preferences',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 16),

              // Default order
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Default order',
                    style: TextStyle(
                        fontSize: 14, color: colorScheme.onSurface),
                  ),
                  GestureDetector(
                    onTap: () =>
                        _showOrderTypeDialog(prefs.defaultOrder),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        border: Border.all(color: theme.dividerColor),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Text(
                            prefs.defaultOrder,
                            style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurface),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Default Qty
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Default Qty',
                    style: TextStyle(
                        fontSize: 14, color: colorScheme.onSurface),
                  ),
                  Focus(
                    onFocusChange: (hasFocus) {
                      _qtyFieldFocused = hasFocus;
                      // Persist when focus is lost
                      if (!hasFocus) {
                        final parsed =
                        int.tryParse(_qtyController.text);
                        if (parsed != null &&
                            parsed != prefs.defaultQty) {
                          ref
                              .read(tradingPrefsProvider.notifier)
                              .setDefaultQty(parsed);
                        }
                      }
                    },
                    child: SizedBox(
                      width: 64,
                      height: 34,
                      child: TextField(
                        controller: _qtyController,
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            fontSize: 13,
                            color: colorScheme.onSurface),
                        decoration: InputDecoration(
                          contentPadding:
                          const EdgeInsets.symmetric(
                              vertical: 6, horizontal: 8),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide:
                            BorderSide(color: theme.dividerColor),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(6),
                            borderSide: BorderSide(
                                color: colorScheme.primary),
                          ),
                        ),
                        // Also save on submit (keyboard "done")
                        onSubmitted: (val) {
                          final parsed = int.tryParse(val);
                          if (parsed != null) {
                            ref
                                .read(tradingPrefsProvider.notifier)
                                .setDefaultQty(parsed);
                          }
                        },
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),

              // Order Confirmation Dialog
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Order Confirmation Dialog',
                    style: TextStyle(
                        fontSize: 14, color: colorScheme.onSurface),
                  ),
                  Switch(
                    value: prefs.orderConfirmation,
                    onChanged: (val) => ref
                        .read(tradingPrefsProvider.notifier)
                        .setOrderConfirmation(val),
                    activeThumbColor: Colors.white,
                    activeTrackColor: const Color(0xFF4CAF50),
                  ),
                ],
              ),

              const SizedBox(height: 8),
              Divider(color: theme.dividerColor),
              const SizedBox(height: 16),

              // ── Additional Settings ────────────────────────────────────
              Text(
                'Additional Settings',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 14),

              _SettingsItem(
                icon: Icons.shield_outlined,
                label: 'Account & Security',
                onTap: () {},
              ),
              const SizedBox(height: 14),
              _SettingsItem(
                icon: Icons.history,
                label: 'Transaction History',
                onTap: () {},
              ),
              const SizedBox(height: 14),

              // Theme Mode row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.palette_outlined,
                          size: 20,
                          color: colorScheme.onSurfaceVariant),
                      const SizedBox(width: 10),
                      Text(
                        'Theme Mode',
                        style: TextStyle(
                            fontSize: 14,
                            color: colorScheme.onSurface),
                      ),
                    ],
                  ),
                  GestureDetector(
                    onTap: () => _showThemeDialog(currentMode),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 6),
                      decoration: BoxDecoration(
                        color: colorScheme.surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Row(
                        children: [
                          Text(
                            _themeModeLabel(currentMode),
                            style: TextStyle(
                                fontSize: 13,
                                color: colorScheme.onSurface),
                          ),
                          const SizedBox(width: 4),
                          Icon(
                            Icons.keyboard_arrow_down,
                            size: 16,
                            color: colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // ── Logout ─────────────────────────────────────────────────
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    await ref.read(authProvider.notifier).logout();
                    if (context.mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const LoginScreen()),
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFD32F2F),
                    foregroundColor: Colors.white,
                    padding:
                    const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                    elevation: 0,
                  ),
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                        fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ── Reusable settings row ─────────────────────────────────────────────────────

class _SettingsItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _SettingsItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: colorScheme.onSurfaceVariant),
          const SizedBox(width: 10),
          Text(label,
              style:
              TextStyle(fontSize: 14, color: colorScheme.onSurface)),
        ],
      ),
    );
  }
}