import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../stock.dart';

final liveStocksProvider =
    StateNotifierProvider<LiveStocksNotifier, Map<int, StockData>>(
      (_) => LiveStocksNotifier(),
    );

class LiveStocksNotifier extends StateNotifier<Map<int, StockData>> {
  LiveStocksNotifier() : super({});

  void update(int token, StockData data) {
    state = {...state, token: data};
  }

  void updateBatch(Map<int, StockData> updates) {
    if (updates.isEmpty) return;
    state = {...state, ...updates};
  }
}
