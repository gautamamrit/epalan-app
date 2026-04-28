class MarketPriceItem {
  final String id;
  final String name;
  final String? nameNe;
  final String unit;
  final int sortOrder;
  final bool isActive;

  MarketPriceItem({
    required this.id,
    required this.name,
    this.nameNe,
    required this.unit,
    required this.sortOrder,
    required this.isActive,
  });

  factory MarketPriceItem.fromJson(Map<String, dynamic> json) {
    return MarketPriceItem(
      id: json['id'] as String,
      name: json['name'] as String,
      nameNe: json['nameNe'] as String?,
      unit: json['unit'] as String,
      sortOrder: json['sortOrder'] as int? ?? 0,
      isActive: json['isActive'] as bool? ?? true,
    );
  }

  String get unitLabel {
    const map = {
      'per_kg': 'Per KG',
      'per_piece': 'Per Piece',
      'per_dozen': 'Per Dozen',
      'per_litre': 'Per Litre',
    };
    return map[unit] ?? unit;
  }
}

class MarketPrice {
  final String id;
  final String itemId;
  final int provinceId;
  final String date;
  final double price;
  final String? notes;
  final String? source;
  final MarketPriceItem? item;
  final MarketPriceProvince? province;

  MarketPrice({
    required this.id,
    required this.itemId,
    required this.provinceId,
    required this.date,
    required this.price,
    this.notes,
    this.source,
    this.item,
    this.province,
  });

  factory MarketPrice.fromJson(Map<String, dynamic> json) {
    return MarketPrice(
      id: json['id'] as String,
      itemId: json['itemId'] as String,
      provinceId: json['provinceId'] is int
          ? json['provinceId'] as int
          : int.parse(json['provinceId'].toString()),
      date: (json['date'] as String).substring(0, 10),
      price: (json['price'] is num)
          ? (json['price'] as num).toDouble()
          : double.parse(json['price'].toString()),
      notes: json['notes'] as String?,
      source: json['source'] as String?,
      item: json['item'] != null
          ? MarketPriceItem.fromJson(json['item'] as Map<String, dynamic>)
          : null,
      province: json['province'] != null
          ? MarketPriceProvince.fromJson(json['province'] as Map<String, dynamic>)
          : null,
    );
  }
}

class MarketPriceProvince {
  final int id;
  final String name;

  MarketPriceProvince({required this.id, required this.name});

  factory MarketPriceProvince.fromJson(Map<String, dynamic> json) {
    return MarketPriceProvince(
      id: json['id'] is int ? json['id'] as int : int.parse(json['id'].toString()),
      name: json['name'] as String,
    );
  }
}
