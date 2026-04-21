class IndexData {
  final String name, value, change;
  final bool isPositive;
  final String? open, high, low, prevClose, week52High, week52Low;

  const IndexData({
    required this.name,
    required this.value,
    required this.change,
    required this.isPositive,
    this.open,
    this.high,
    this.low,
    this.prevClose,
    this.week52High,
    this.week52Low,
  });
}

class StockData {
  final int instrumentToken; // WS key — 0 if unknown
  final String symbol;
  final String exchange;
  final double price;
  final double changePercent;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final double upperCircuit;
  final double lowerCircuit;
  final double week52High;
  final double week52Low;
  final String? companyName;

  // Extra fields from the WebSocket feed
  final double averageTradedPrice;
  final int totalBuyQuantity;
  final int totalSellQuantity;
  final int lastTradedQuantity;
  final DateTime? lastTradeTime;
  final DateTime? exchangeTimestamp;
  final List<DepthEntry> depthBuy;
  final List<DepthEntry> depthSell;

  const StockData({
    this.instrumentToken = 0,
    required this.symbol,
    required this.exchange,
    required this.price,
    required this.changePercent,
    double? open,
    double? high,
    double? low,
    double? close,
    this.volume = 0,
    double? upperCircuit,
    double? lowerCircuit,
    double? week52High,
    double? week52Low,
    this.averageTradedPrice = 0,
    this.totalBuyQuantity = 0,
    this.totalSellQuantity = 0,
    this.lastTradedQuantity = 0,
    this.lastTradeTime,
    this.exchangeTimestamp,
    this.depthBuy = const [],
    this.depthSell = const [],
    this.companyName,
  }) : open = open ?? price,
       high = high ?? price,
       low = low ?? price,
       close = close ?? price,
       upperCircuit = upperCircuit ?? price * 1.10,
       lowerCircuit = lowerCircuit ?? price * 0.90,
       week52High = week52High ?? price * 1.30,
       week52Low = week52Low ?? price * 0.70;

  /// Construct directly from a WebSocket price_feed entry.
  /// [token] is the integer key, [map] is the value map.
  /// [symbol] and [exchange] must be supplied from your token→symbol lookup.
  factory StockData.fromWsFeed({
    required int token,
    required Map<String, dynamic> map,
    required String symbol,
    String exchange = 'NSE',
    // Pass previous values so fields absent from the feed are preserved.
    double? prevUpperCircuit,
    double? prevLowerCircuit,
    double? prevWeek52High,
    double? prevWeek52Low,
  }) {
    final ohlc = map['ohlc'] as Map<String, dynamic>? ?? {};

    List<DepthEntry> parseDepth(List<dynamic>? raw) => (raw ?? [])
        .map((e) => DepthEntry.fromMap(e as Map<String, dynamic>))
        .toList();

    final buyDepth = parseDepth(
      (map['depth'] as Map<String, dynamic>?)?['buy'] as List?,
    );
    final sellDepth = parseDepth(
      (map['depth'] as Map<String, dynamic>?)?['sell'] as List?,
    );

    final price = (map['last_price'] as num).toDouble();

    return StockData(
      instrumentToken: token,
      symbol: symbol,
      exchange: exchange,
      price: price,
      changePercent: (map['change'] as num).toDouble(),
      open: (ohlc['open'] as num?)?.toDouble(),
      high: (ohlc['high'] as num?)?.toDouble(),
      low: (ohlc['low'] as num?)?.toDouble(),
      close: (ohlc['close'] as num?)?.toDouble(),
      volume: (map['volume_traded'] as num?)?.toDouble() ?? 0,
      upperCircuit: prevUpperCircuit,
      lowerCircuit: prevLowerCircuit,
      week52High: prevWeek52High,
      week52Low: prevWeek52Low,
      averageTradedPrice:
          (map['average_traded_price'] as num?)?.toDouble() ?? 0,
      totalBuyQuantity: (map['total_buy_quantity'] as num?)?.toInt() ?? 0,
      totalSellQuantity: (map['total_sell_quantity'] as num?)?.toInt() ?? 0,
      lastTradedQuantity: (map['last_traded_quantity'] as num?)?.toInt() ?? 0,
      lastTradeTime: _parseDateTime(map['last_trade_time']),
      exchangeTimestamp: _parseDateTime(map['exchange_timestamp']),
      depthBuy: buyDepth,
      depthSell: sellDepth,
    );
  }

  static DateTime? _parseDateTime(dynamic raw) {
    if (raw == null) return null;
    try {
      return DateTime.parse(raw.toString().replaceFirst(' ', 'T'));
    } catch (_) {
      return null;
    }
  }

  bool get isPositive => changePercent >= 0;

  String get formattedPrice => price.toStringAsFixed(2);

  String get formattedChange =>
      '${isPositive ? '+' : ''}${changePercent.toStringAsFixed(2)}%';

  String get formattedVolume {
    if (volume >= 1e7) return '${(volume / 1e7).toStringAsFixed(2)}Cr';
    if (volume >= 1e5) return '${(volume / 1e5).toStringAsFixed(2)}L';
    if (volume >= 1e3) return '${(volume / 1e3).toStringAsFixed(1)}K';
    return volume.toStringAsFixed(0);
  }
}

class DepthEntry {
  final int quantity;
  final double price;
  final int orders;

  const DepthEntry({
    required this.quantity,
    required this.price,
    required this.orders,
  });

  factory DepthEntry.fromMap(Map<String, dynamic> map) => DepthEntry(
    quantity: (map['quantity'] as num).toInt(),
    price: (map['price'] as num).toDouble(),
    orders: (map['orders'] as num).toInt(),
  );
}
