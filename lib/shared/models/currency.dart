import 'package:hive/hive.dart';

part 'currency.g.dart';

/// Supported currencies
@HiveType(typeId: 8)
enum Currency {
  @HiveField(0)
  usd('USD', '\$', 'US Dollar'),
  @HiveField(1)
  inr('INR', '₹', 'Indian Rupee'),
  @HiveField(2)
  eur('EUR', '€', 'Euro'),
  @HiveField(3)
  gbp('GBP', '£', 'British Pound'),
  @HiveField(4)
  cad('CAD', 'CA\$', 'Canadian Dollar'),
  @HiveField(5)
  aud('AUD', 'A\$', 'Australian Dollar'),
  @HiveField(6)
  jpy('JPY', '¥', 'Japanese Yen'),
  @HiveField(7)
  cny('CNY', '¥', 'Chinese Yuan'),
  @HiveField(8)
  sgd('SGD', 'S\$', 'Singapore Dollar'),
  @HiveField(9)
  hkd('HKD', 'HK\$', 'Hong Kong Dollar');

  final String code;
  final String symbol;
  final String name;

  const Currency(this.code, this.symbol, this.name);

  static Currency fromCode(String code) {
    return Currency.values.firstWhere(
      (c) => c.code == code,
      orElse: () => Currency.usd,
    );
  }
}

