/// Stable relative timestamps for mock fixtures.
abstract final class MockClock {
  static DateTime get now => DateTime.now();

  static DateTime minutesAgo(int minutes) =>
      now.subtract(Duration(minutes: minutes));

  static DateTime hoursAgo(int hours) => now.subtract(Duration(hours: hours));

  static DateTime daysAgo(int days) => now.subtract(Duration(days: days));

  static DateTime monthsAgo(int months) =>
      now.subtract(Duration(days: months * 30));

  static DateTime yearsAgo(int years) =>
      now.subtract(Duration(days: years * 365));

  static DateTime daysFromNow(int days) => now.add(Duration(days: days));
}
