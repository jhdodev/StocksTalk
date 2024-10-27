// lib/models/stock.dart
class Stock {
  final String name;
  final String price;
  final String changePrice;
  final String changeRate;
  final String tradingVolume;

  Stock({
    required this.name,
    required this.price,
    required this.changePrice,
    required this.changeRate,
    required this.tradingVolume,
  });

  // isRising getter 추가
  bool get isRising {
    final double? parsedChangePrice =
        double.tryParse(changePrice.replaceAll(',', ''));
    return parsedChangePrice != null && parsedChangePrice > 0;
  }

  factory Stock.fromJson(Map<String, dynamic> json) {
    String formatValue(dynamic value) {
      if (value == null) return '0';
      return value.toString();
    }

    return Stock(
      name: json['itmsNm']?.toString() ?? 'Unknown Stock',
      price: formatValue(json['clpr']),
      changePrice: formatValue(json['vs']),
      changeRate: formatValue(json['fltRt']),
      tradingVolume: formatValue(json['trPrc']),
    );
  }

  // Deep copy method
  Stock copyWith({
    String? name,
    String? price,
    String? changePrice,
    String? changeRate,
    String? tradingVolume,
  }) {
    return Stock(
      name: name ?? this.name,
      price: price ?? this.price,
      changePrice: changePrice ?? this.changePrice,
      changeRate: changeRate ?? this.changeRate,
      tradingVolume: tradingVolume ?? this.tradingVolume,
    );
  }
}
