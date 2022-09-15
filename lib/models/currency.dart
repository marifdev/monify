class Currency {
  final String symbol;
  final String code;

  Currency({
    required this.symbol,
    required this.code,
  });

  @override
  bool operator ==(Object other) => other is Currency && other.code == code;

  @override
  int get hashCode => code.hashCode;

  factory Currency.fromJson(Map<String, dynamic> json) {
    return Currency(
      symbol: json['symbol'],
      code: json['code'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'code': code,
    };
  }
}
