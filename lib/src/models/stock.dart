// lib/models/stock.dart
class Stock {
  final String name;
  final String srtnCd;
  final String price;
  final String changePrice;
  final String changeRate;
  final String tradingVolume;

  Stock({
    required this.name,
    required this.srtnCd,
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
    return Stock(
      name: json['itmsNm']?.toString() ?? 'Unknown Stock',
      srtnCd: json['srtnCd']?.toString() ?? '',
      price: json['clpr']?.toString() ?? '0',
      changePrice: json['vs']?.toString() ?? '0',
      changeRate: json['fltRt']?.toString() ?? '0',
      tradingVolume: json['trPrc']?.toString() ?? '0',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itmsNm': name,
      'srtnCd': srtnCd,
      'clpr': price,
      'vs': changePrice,
      'fltRt': changeRate,
      'trPrc': tradingVolume,
    };
  }
}
