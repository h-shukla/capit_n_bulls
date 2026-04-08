import 'package:flutter/material.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String _defaultOrder = 'Delivery';
  int _defaultQty = 10;
  bool _orderConfirmation = true;
  String _themeMode = 'Light';

  final TextEditingController _qtyController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _qtyController.text = _defaultQty.toString();
  }

  @override
  void dispose() {
    _qtyController.dispose();
    super.dispose();
  }

  void _showOrderTypeDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
                // drag handle
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ...['Delivery', 'Intraday'].map((type) {
                  final selected = _defaultOrder == type;
                  return InkWell(
                    onTap: () {
                      setState(() => _defaultOrder = type);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            type,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          if (selected)
                            const Icon(Icons.check,
                                size: 18, color: Colors.black),
                        ],
                      ),
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

  void _showThemeDialog() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
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
                Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                ...['Light', 'Dark', 'System'].map((theme) {
                  final selected = _themeMode == theme;
                  return InkWell(
                    onTap: () {
                      setState(() => _themeMode = theme);
                      Navigator.pop(context);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            theme,
                            style: TextStyle(
                              fontSize: 15,
                              color: Colors.black,
                              fontWeight: selected
                                  ? FontWeight.w600
                                  : FontWeight.w400,
                            ),
                          ),
                          if (selected)
                            const Icon(Icons.check,
                                size: 18, color: Colors.black),
                        ],
                      ),
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

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Profile ──
          Row(
            children: [
              Container(
                width: 56,
                height: 56,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.person_outline,
                    size: 30, color: Colors.grey.shade600),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'John Doe',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Colors.black,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    'hjohndoe33@gmail.com',
                    style: TextStyle(
                      fontSize: 13,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ],
          ),

          const SizedBox(height: 20),
          Divider(color: Colors.grey.shade200, thickness: 1),
          const SizedBox(height: 16),

          // ── Trading Preferences ──
          const Text(
            'Trading Preferences',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 16),

          // Default order
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Default order',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              GestureDetector(
                onTap: _showOrderTypeDialog,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.grey.shade300),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _defaultOrder,
                        style: const TextStyle(fontSize: 13, color: Colors.black),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down,
                          size: 16, color: Colors.grey.shade600),
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
              const Text(
                'Default Qty',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              SizedBox(
                width: 64,
                height: 34,
                child: TextField(
                  controller: _qtyController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 13, color: Colors.black),
                  decoration: InputDecoration(
                    contentPadding:
                    const EdgeInsets.symmetric(vertical: 6, horizontal: 8),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: BorderSide(color: Colors.grey.shade300),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(6),
                      borderSide: const BorderSide(color: Colors.black),
                    ),
                  ),
                  onChanged: (val) {
                    final parsed = int.tryParse(val);
                    if (parsed != null) setState(() => _defaultQty = parsed);
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Order Confirmation Dialog
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Order Confirmation Dialog',
                style: TextStyle(fontSize: 14, color: Colors.black),
              ),
              Switch(
                value: _orderConfirmation,
                onChanged: (val) => setState(() => _orderConfirmation = val),
                activeColor: Colors.white,
                activeTrackColor: const Color(0xFF4CAF50),
                inactiveThumbColor: Colors.white,
                inactiveTrackColor: Colors.grey.shade300,
              ),
            ],
          ),

          const SizedBox(height: 8),
          Divider(color: Colors.grey.shade200, thickness: 1),
          const SizedBox(height: 16),

          // ── Additional Settings ──
          const Text(
            'Additional Settings',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w700,
              color: Colors.black,
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
                  Icon(Icons.compare_arrows,
                      size: 20, color: Colors.grey.shade700),
                  const SizedBox(width: 10),
                  const Text(
                    'Theme Mode',
                    style: TextStyle(fontSize: 14, color: Colors.black),
                  ),
                ],
              ),
              GestureDetector(
                onTap: _showThemeDialog,
                child: Container(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _themeMode,
                        style:
                        const TextStyle(fontSize: 13, color: Colors.black),
                      ),
                      const SizedBox(width: 4),
                      Icon(Icons.keyboard_arrow_down,
                          size: 16, color: Colors.grey.shade600),
                    ],
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 48),

          // ── Logout ──
          SizedBox(
            child: ElevatedButton(
              onPressed: () {},
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFD32F2F),
                foregroundColor: Colors.white,
                padding:
                const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                elevation: 0,
              ),
              child: const Text(
                'Logout',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

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
    return GestureDetector(
      onTap: onTap,
      child: Row(
        children: [
          Icon(icon, size: 20, color: Colors.grey.shade700),
          const SizedBox(width: 10),
          Text(
            label,
            style: const TextStyle(fontSize: 14, color: Colors.black),
          ),
        ],
      ),
    );
  }
}