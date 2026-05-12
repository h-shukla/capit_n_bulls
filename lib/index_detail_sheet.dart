import 'dart:convert';
import 'package:capit_n_bulls/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:http/http.dart' as http;
import './stock.dart';

const _gainGreen = Color(0xFF3FD47E);
const _lossRed = Color(0xFFE05252);

class IndexDetailSheet extends StatelessWidget {
  final IndexData data;

  const IndexDetailSheet({super.key, required this.data});

  static void show(BuildContext context, IndexData data) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: 'Dismiss',
      barrierColor: Colors.black54,
      transitionDuration: const Duration(milliseconds: 350),
      pageBuilder: (_, __, ___) => IndexDetailSheet(data: data),
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curved = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        );
        return SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 1),
            end: Offset.zero,
          ).animate(curved),
          child: FadeTransition(opacity: curved, child: child),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final semanticColor = data.isPositive ? _gainGreen : _lossRed;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Align(
      alignment: Alignment.bottomCenter,
      child: Material(
        color: Colors.transparent,
        child: Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: theme.colorScheme.surface,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
            border: isDark
                ? Border(top: BorderSide(color: theme.dividerColor))
                : null,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Drag handle ──
              Padding(
                padding: const EdgeInsets.only(top: 12, bottom: 4),
                child: Center(
                  child: Container(
                    width: 40,
                    height: 4,
                    decoration: BoxDecoration(
                      color: isDark ? Colors.white24 : Colors.black12,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),
              ),

              Padding(
                padding: const EdgeInsets.fromLTRB(24, 12, 24, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ── Header: FIX — Expanded on name, fixed value column ──
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Name + badge — takes all available space, never overflows
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                data.name,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontSize: 22,
                                  fontWeight: FontWeight.w800,
                                  height: 1.2,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: isDark
                                      ? theme
                                            .colorScheme
                                            .surfaceContainerHighest
                                      : Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'NSE Index',
                                  style: TextStyle(
                                    color: theme.hintColor,
                                    fontSize: 11,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),

                        const SizedBox(width: 16),

                        // Value + change pill — fixed width, always right-aligned
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text(
                              data.value,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontSize: 22,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: semanticColor.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    data.isPositive
                                        ? Icons.arrow_upward_rounded
                                        : Icons.arrow_downward_rounded,
                                    color: semanticColor,
                                    size: 13,
                                  ),
                                  const SizedBox(width: 3),
                                  Text(
                                    data.change,
                                    style: TextStyle(
                                      color: semanticColor,
                                      fontSize: 13,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),
                    Divider(color: theme.dividerColor, height: 1),
                    const SizedBox(height: 16),

                    Text(
                      'TODAY',
                      style: TextStyle(
                        color: theme.hintColor,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.5,
                      ),
                    ),
                    const SizedBox(height: 12),

                    _StatsGrid(data: data),

                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // ── Buy/Sell Bar ──
              Container(
                padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottomPad),
                decoration: BoxDecoration(
                  color: isDark
                      ? theme.colorScheme.surfaceContainerHighest
                      : theme.colorScheme.surface,
                  border: Border(top: BorderSide(color: theme.dividerColor)),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: _IndexOrderButton(
                        label: 'BUY',
                        color: _gainGreen,
                        indexData: data,
                        isBuy: true,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: _IndexOrderButton(
                        label: 'SELL',
                        color: _lossRed,
                        indexData: data,
                        isBuy: false,
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

// ── Stats Grid ────────────────────────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final IndexData data;
  const _StatsGrid({required this.data});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _StatItem(label: 'Open', value: data.open ?? '—'),
      _StatItem(label: 'Prev Close', value: data.prevClose ?? '—'),
      _StatItem(label: 'High', value: data.high ?? '—', valueColor: _gainGreen),
      _StatItem(label: 'Low', value: data.low ?? '—', valueColor: _lossRed),
      _StatItem(
        label: '52W High',
        value: data.week52High ?? '—',
        valueColor: _gainGreen,
      ),
      _StatItem(
        label: '52W Low',
        value: data.week52Low ?? '—',
        valueColor: _lossRed,
      ),
    ];

    return Column(
      children: [
        for (var i = 0; i < stats.length; i += 2)
          Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Row(
              children: [
                Expanded(child: _statCell(context, stats[i])),
                if (i + 1 < stats.length)
                  Expanded(child: _statCell(context, stats[i + 1])),
              ],
            ),
          ),
      ],
    );
  }

  Widget _statCell(BuildContext context, _StatItem item) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          item.label,
          style: TextStyle(
            color: theme.hintColor,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          item.value,
          style: TextStyle(
            color: item.valueColor ?? theme.colorScheme.onSurface,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _StatItem {
  final String label;
  final String value;
  final Color? valueColor;
  const _StatItem({required this.label, required this.value, this.valueColor});
}

// ── Order Button ──────────────────────────────────────────────────────────────
class _IndexOrderButton extends StatelessWidget {
  final String label;
  final Color color;
  final IndexData indexData;
  final bool isBuy;

  const _IndexOrderButton({
    required this.label,
    required this.color,
    required this.indexData,
    required this.isBuy,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _IndexOrderDialog.show(context, indexData, isBuy),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(10),
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 15,
            fontWeight: FontWeight.w800,
            letterSpacing: 1.2,
          ),
        ),
      ),
    );
  }
}

// ── Order Result ──────────────────────────────────────────────────────────────
class _OrderResult {
  final bool success;
  final String message;
  const _OrderResult({required this.success, required this.message});
}

// ── Order Dialog ──────────────────────────────────────────────────────────────
class _IndexOrderDialog extends ConsumerStatefulWidget {
  final IndexData indexData;
  final bool isBuy;

  const _IndexOrderDialog({required this.indexData, required this.isBuy});

  static void show(BuildContext context, IndexData indexData, bool isBuy) {
    showDialog(
      context: context,
      barrierColor: Colors.black54,
      builder: (_) => _IndexOrderDialog(indexData: indexData, isBuy: isBuy),
    );
  }

  @override
  ConsumerState<_IndexOrderDialog> createState() => _IndexOrderDialogState();
}

class _IndexOrderDialogState extends ConsumerState<_IndexOrderDialog> {
  int _qty = 1;
  bool _isLoading = false;

  Color get _accentColor => widget.isBuy ? _gainGreen : _lossRed;

  Future<_OrderResult> _placeOrder() async {
    final indexData = widget.indexData;
    final side = widget.isBuy ? 'BUY' : 'SELL';
    final userId = ref.read(authProvider.notifier).userId ?? 'unknown';

    final body = {
      "user_id": userId,
      "timestamp": DateTime.now().toIso8601String(),
      "contract_name": indexData.name,
      "exchange_token": indexData.name,
      "qty": _qty * 50,
      "lots": _qty,
      "side": side,
      "order_type": "MIS",
      "product_type": "MARKET",
      "entry_price":
          double.tryParse(indexData.value.replaceAll(',', '')) ?? 0.0,
      "ltp": double.tryParse(indexData.value.replaceAll(',', '')) ?? 0.0,
      "pnl": 0.0,
      "status": "OPEN",
    };

    try {
      debugPrint("Index Order Payload: ${jsonEncode(body)}");

      final accessToken = ref.read(authProvider.notifier).accessToken;
      final response = await http
          .post(
            Uri.parse('http://69.62.75.117:8765/orders'),
            headers: {
              'Content-Type': 'application/json',
              if (accessToken != null) 'Authorization': 'Bearer $accessToken',
            },
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          debugPrint("Index order success: ${jsonDecode(response.body)}");
        } catch (_) {}
        return const _OrderResult(
          success: true,
          message: 'Order placed successfully',
        );
      }

      String errorMsg = 'Server error (${response.statusCode})';
      try {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        errorMsg =
            decoded['detail']?.toString() ??
            decoded['message']?.toString() ??
            decoded['error']?.toString() ??
            errorMsg;
        debugPrint("Index order error: $decoded");
      } catch (_) {
        debugPrint("Raw error: ${response.body}");
      }

      return _OrderResult(success: false, message: errorMsg);
    } on http.ClientException catch (e) {
      return _OrderResult(
        success: false,
        message: 'Network error: ${e.message}',
      );
    } catch (e) {
      return _OrderResult(success: false, message: 'Unexpected error: $e');
    }
  }

  Future<void> _handleConfirm() async {
    setState(() => _isLoading = true);
    final result = await _placeOrder();
    if (!mounted) return;
    setState(() => _isLoading = false);

    final overlay = Overlay.of(context, rootOverlay: true);
    final bottomPad = MediaQuery.of(context).padding.bottom;

    Navigator.of(context).pop();

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (_) => Positioned(
        bottom: bottomPad + 120,
        left: 16,
        right: 16,
        child: _SnackbarToast(
          success: result.success,
          message: result.success
              ? '${widget.isBuy ? 'Buy' : 'Sell'} order: $_qty lot${_qty > 1 ? 's' : ''} '
                    '(${_qty * 50} qty) of ${widget.indexData.name} placed'
              : result.message,
          accentColor: result.success ? _gainGreen : _lossRed,
          onDone: () => entry.remove(),
        ),
      ),
    );

    overlay.insert(entry);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      backgroundColor: theme.dialogBackgroundColor,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _accentColor,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    widget.isBuy ? 'BUY' : 'SELL',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    widget.indexData.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 6),
            Text(
              '@ ${widget.indexData.value}',
              style: TextStyle(color: theme.hintColor, fontSize: 13),
            ),

            const SizedBox(height: 24),

            Text(
              'QUANTITY (LOTS)',
              style: TextStyle(
                color: theme.hintColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
                letterSpacing: 1.5,
              ),
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                _QtyButton(
                  icon: Icons.remove,
                  onTap: () {
                    if (_qty > 1) setState(() => _qty--);
                  },
                ),
                Expanded(
                  child: Center(
                    child: Text(
                      '$_qty',
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
                _QtyButton(
                  icon: Icons.add,
                  onTap: () => setState(() => _qty++),
                ),
              ],
            ),

            const SizedBox(height: 20),
            Divider(color: theme.dividerColor),
            const SizedBox(height: 12),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Lots',
                  style: TextStyle(color: theme.hintColor, fontSize: 13),
                ),
                Text(
                  '$_qty × 50 units',
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 24),

            Row(
              children: [
                Expanded(
                  child: GestureDetector(
                    onTap: () => Navigator.of(context).pop(),
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: isDark
                            ? theme.colorScheme.surfaceContainerHighest
                            : Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        'Cancel',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: GestureDetector(
                    onTap: _isLoading ? null : _handleConfirm,
                    child: Container(
                      height: 46,
                      decoration: BoxDecoration(
                        color: _accentColor.withOpacity(_isLoading ? 0.6 : 1.0),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      alignment: Alignment.center,
                      child: _isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  Colors.white,
                                ),
                              ),
                            )
                          : Text(
                              'Confirm ${widget.isBuy ? 'Buy' : 'Sell'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _QtyButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const _QtyButton({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: isDark
              ? theme.colorScheme.surfaceContainerHighest
              : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 20, color: theme.colorScheme.onSurface),
      ),
    );
  }
}

// ── Snackbar Toast ────────────────────────────────────────────────────────────
class _SnackbarToast extends StatefulWidget {
  final bool success;
  final String message;
  final Color accentColor;
  final VoidCallback onDone;

  const _SnackbarToast({
    required this.success,
    required this.message,
    required this.accentColor,
    required this.onDone,
  });

  @override
  State<_SnackbarToast> createState() => _SnackbarToastState();
}

class _SnackbarToastState extends State<_SnackbarToast>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _anim = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
    _ctrl.forward();

    Future.delayed(const Duration(seconds: 4), () async {
      if (mounted) {
        await _ctrl.reverse();
        widget.onDone();
      }
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _anim,
      child: Material(
        color: Colors.transparent,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.accentColor,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                widget.success ? Icons.check_circle : Icons.error,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  widget.message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
