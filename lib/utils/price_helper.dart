/// Formats numbers with thousand separators (e.g., 1500000 -> "MWK 1,500,000")
String formatWithCommas(num? price, {String currency = 'MWK'}) {
  if (price == null) return '$currency 0';

  final parts = price.toStringAsFixed(0).split('.');
  final formattedInt = parts[0].replaceAllMapped(
    RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
    (Match m) => '${m[1]},',
  );

  return currency.isNotEmpty ? '$currency $formattedInt' : formattedInt;
}

/// Compact price formatter for tight spaces (e.g., 1500000 -> "1.5M")
String formatPrice(double price) {
  if (price >= 1000000) {
    return "${(price / 1000000).toStringAsFixed(1)}M";
  }

  if (price >= 1000) {
    return "${(price / 1000).toStringAsFixed(1)}K";
  }

  return price.toStringAsFixed(0);
}