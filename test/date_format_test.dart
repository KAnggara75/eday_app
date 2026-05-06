import 'package:flutter_test/flutter_test.dart';
import 'package:intl/intl.dart';

void main() {
  group('Date Formatting', () {
    test(
      'format matches "Updated: Tue May 5 21:30:24 WIB 2026 [APP]" format',
      () {
        // Mocking a specific date: Tuesday, May 5, 2026, 21:30:24
        final testDate = DateTime(2026, 5, 5, 21, 30, 24);

        final timestamp =
            '${DateFormat('E MMM d HH:mm:ss', 'en_US').format(testDate)} WIB ${DateFormat('yyyy', 'en_US').format(testDate)}';

        final message = 'Updated: $timestamp [APP]';

        expect(message, 'Updated: Tue May 5 21:30:24 WIB 2026 [APP]');
      },
    );

    test('format handles different dates correctly', () {
      final testDate = DateTime(2026, 12, 31, 23, 59, 59);
      final timestamp =
          '${DateFormat('E MMM d HH:mm:ss', 'en_US').format(testDate)} WIB ${DateFormat('yyyy', 'en_US').format(testDate)}';

      expect(timestamp, 'Thu Dec 31 23:59:59 WIB 2026');
    });
  });
}
