import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

class TradingPrefs {
  final String defaultOrder; // 'Delivery' | 'Intraday'
  final int defaultQty;
  final bool orderConfirmation;

  const TradingPrefs({
    this.defaultOrder = 'Delivery',
    this.defaultQty = 10,
    this.orderConfirmation = true,
  });

  TradingPrefs copyWith({
    String? defaultOrder,
    int? defaultQty,
    bool? orderConfirmation,
  }) =>
      TradingPrefs(
        defaultOrder: defaultOrder ?? this.defaultOrder,
        defaultQty: defaultQty ?? this.defaultQty,
        orderConfirmation: orderConfirmation ?? this.orderConfirmation,
      );
}

const _kOrderKey = 'pref_default_order';
const _kQtyKey = 'pref_default_qty';
const _kConfirmKey = 'pref_order_confirmation';

class TradingPrefsNotifier extends AsyncNotifier<TradingPrefs> {
  late SharedPreferences _prefs;

  @override
  Future<TradingPrefs> build() async {
    _prefs = await SharedPreferences.getInstance();
    return TradingPrefs(
      defaultOrder: _prefs.getString(_kOrderKey) ?? 'Delivery',
      defaultQty: _prefs.getInt(_kQtyKey) ?? 10,
      orderConfirmation: _prefs.getBool(_kConfirmKey) ?? true,
    );
  }

  Future<void> setDefaultOrder(String order) async {
    await _prefs.setString(_kOrderKey, order);
    state = AsyncData(state.requireValue.copyWith(defaultOrder: order));
  }

  Future<void> setDefaultQty(int qty) async {
    await _prefs.setInt(_kQtyKey, qty);
    state = AsyncData(state.requireValue.copyWith(defaultQty: qty));
  }

  Future<void> setOrderConfirmation(bool val) async {
    await _prefs.setBool(_kConfirmKey, val);
    state = AsyncData(state.requireValue.copyWith(orderConfirmation: val));
  }
}

final tradingPrefsProvider =
AsyncNotifierProvider<TradingPrefsNotifier, TradingPrefs>(
  TradingPrefsNotifier.new,
);