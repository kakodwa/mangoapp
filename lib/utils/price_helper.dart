String formatPrice(double price) {
  if (price >= 1000000) {
    return "${(price / 1000000).toStringAsFixed(1)}M";
  }

  if (price >= 1000) {
    return "${(price / 1000).toStringAsFixed(1)}K";
  }

  return price.toStringAsFixed(0);
}