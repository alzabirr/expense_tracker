import 'package:flutter_test/flutter_test.dart';
import 'package:spendra/core/utils/date_utils.dart';

void main() {
  group('AppDateUtils Tests', () {
    test('isSameDay accurately identifies identical calendar days', () {
      final date1 = DateTime(2026, 8, 5, 10, 30);
      final date2 = DateTime(2026, 8, 5, 23, 59);
      final date3 = DateTime(2026, 8, 6, 0, 0);

      expect(AppDateUtils.isSameDay(date1, date2), isTrue);
      expect(AppDateUtils.isSameDay(date1, date3), isFalse);
    });

    test('startOfMonth returns day 1 at 00:00:00', () {
      final start = AppDateUtils.startOfMonth;
      expect(start.day, 1);
      expect(start.hour, 0);
      expect(start.minute, 0);
      expect(start.second, 0);
    });

    test('endOfMonth returns last day of month at 23:59:59', () {
      final end = AppDateUtils.endOfMonth;
      expect(end.hour, 23);
      expect(end.minute, 59);
      expect(end.second, 59);
    });

    test('startOfWeek returns Monday at 00:00:00', () {
      final start = AppDateUtils.startOfWeek;
      expect(start.weekday, DateTime.monday);
      expect(start.hour, 0);
      expect(start.minute, 0);
      expect(start.second, 0);
    });

    test('isWithinRange properly validates inclusive boundaries', () {
      final start = DateTime(2026, 8, 1, 0, 0, 0);
      final end = DateTime(2026, 8, 31, 23, 59, 59);

      expect(AppDateUtils.isWithinRange(start, start, end), isTrue);
      expect(AppDateUtils.isWithinRange(end, start, end), isTrue);
      expect(AppDateUtils.isWithinRange(DateTime(2026, 8, 15, 12, 0), start, end), isTrue);
      expect(AppDateUtils.isWithinRange(DateTime(2026, 7, 31, 23, 59, 59), start, end), isFalse);
      expect(AppDateUtils.isWithinRange(DateTime(2026, 9, 1, 0, 0, 0), start, end), isFalse);
    });

    test('monthRange returns valid boundaries for n months ago', () {
      final (start, end) = AppDateUtils.monthRange(0);
      expect(start.day, 1);
      expect(end.hour, 23);
      expect(end.minute, 59);
      expect(end.second, 59);
    });

    test('groupLabel returns Today for today date', () {
      final now = DateTime.now();
      expect(AppDateUtils.groupLabel(now), 'Today');
      expect(AppDateUtils.groupLabelUpper(now), 'TODAY');
    });

    test('groupByDate correctly groups items by day boundary', () {
      final items = [
        (date: DateTime(2026, 8, 5, 10, 0), title: 'Item 1'),
        (date: DateTime(2026, 8, 5, 14, 0), title: 'Item 2'),
        (date: DateTime(2026, 8, 4, 9, 0), title: 'Item 3'),
      ];

      final grouped = AppDateUtils.groupByDate(items, (i) => i.date);
      expect(grouped.length, 2);

      final aug5Key = DateTime(2026, 8, 5);
      expect(grouped[aug5Key]?.length, 2);
    });
  });
}
