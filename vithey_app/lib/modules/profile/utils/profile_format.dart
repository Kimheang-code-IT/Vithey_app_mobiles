String formatProfileCount(int value) {
  if (value >= 1000000) {
    return '${(value / 1000000).toStringAsFixed(1)}M';
  }
  if (value >= 10000) {
    return '${(value / 1000).round()}K';
  }
  if (value >= 1000) {
    final k = value / 1000;
    return k == k.roundToDouble() ? '${k.toInt()}K' : '${k.toStringAsFixed(1)}K';
  }
  return '$value';
}
