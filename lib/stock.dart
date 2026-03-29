class IndexData {
  final String name, value, change;
  final bool isPositive;
  final String? open, high, low, prevClose, week52High, week52Low; // ADD

  const IndexData({
    required this.name,
    required this.value,
    required this.change,
    required this.isPositive,
    this.open, this.high, this.low,
    this.prevClose, this.week52High, this.week52Low,
  });
}

class StockData {
  final String symbol;
  final String exchange;
  final double price;
  final double changePercent;

  // Detail fields — optional with sensible defaults
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final double upperCircuit;
  final double lowerCircuit;
  final double week52High;
  final double week52Low;

  const StockData({
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
  })  : open = open ?? price,
        high = high ?? price,
        low = low ?? price,
        close = close ?? price,
        upperCircuit = upperCircuit ?? price * 1.10,  // default: +10%
        lowerCircuit = lowerCircuit ?? price * 0.90,  // default: -10%
        week52High = week52High ?? price * 1.30,
        week52Low = week52Low ?? price * 0.70;

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