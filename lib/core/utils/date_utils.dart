import 'package:intl/intl.dart';

/// Date helpers for grouping, labelling, and formatting transactions.
abstract final class AppDateUtils {
  static final _headerFmt = DateFormat('EEE, MMM d');
  static final _fullFmt = DateFormat('MMM d, yyyy');
  static final _timeFmt = DateFormat('h:mm a');
  static final _monthFmt = DateFormat('MMMM yyyy');
  static final _shortMonthFmt = DateFormat('MMM');

  /// Returns "Today", "Yesterday", or "Wed, Oct 23".
  static String groupLabel(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final d = DateTime(date.year, date.month, date.day);
    final diff = today.difference(d).inDays;

    if (diff == 0) return 'Today';
    if (diff == 1) return 'Yesterday';
    return _headerFmt.format(date);
  }

  /// Returns a date group label in uppercase: "TODAY, OCT 24".
  static String groupLabelUpper(DateTime date) =>
      groupLabel(date).toUpperCase();

  static String formatFull(DateTime date) => _fullFmt.format(date);
  static String formatTime(DateTime date) => _timeFmt.format(date);
  static String formatMonth(DateTime date) => _monthFmt.format(date);
  static String formatShortMonth(DateTime date) => _shortMonthFmt.format(date);

  static bool isToday(DateTime date) {
    final now = DateTime.now();
    return date.year == now.year &&
        date.month == now.month &&
        date.day == now.day;
  }

  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return date.year == yesterday.year &&
        date.month == yesterday.month &&
        date.day == yesterday.day;
  }

  static bool isSameDay(DateTime a, DateTime b) =>
      a.year == b.year && a.month == b.month && a.day == b.day;

  /// Groups a list of transactions by their date (day boundary).
  /// Returns an ordered map: date → items.
  static Map<DateTime, List<T>> groupByDate<T>(
    List<T> items,
    DateTime Function(T) dateOf,
  ) {
    final map = <DateTime, List<T>>{};
    for (final item in items) {
      final date = dateOf(item);
      final key = DateTime(date.year, date.month, date.day);
      (map[key] ??= []).add(item);
    }
    // Sort by date descending
    return Map.fromEntries(
      map.entries.toList()
        ..sort((a, b) => b.key.compareTo(a.key)),
    );
  }

  /// Start of the current month.
  static DateTime get startOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month, 1);
  }

  /// End of the current month.
  static DateTime get endOfMonth {
    final now = DateTime.now();
    return DateTime(now.year, now.month + 1, 0, 23, 59, 59);
  }

  /// Start of the current week (Monday at 00:00:00).
  static DateTime get startOfWeek {
    final now = DateTime.now();
    final monday = now.subtract(Duration(days: now.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day);
  }

  /// Date range for [n] months ago from today.
  static (DateTime start, DateTime end) monthRange(int monthsAgo) {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month - monthsAgo, 1);
    final end = DateTime(now.year, now.month - monthsAgo + 1, 0, 23, 59, 59);
    return (start, end);
  }

  /// Checks if [date] falls inclusively within [start] and [end].
  static bool isWithinRange(DateTime date, DateTime start, DateTime end) {
    return !date.isBefore(start) && !date.isAfter(end);
  }
}
