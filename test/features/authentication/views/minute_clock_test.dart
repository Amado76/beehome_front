import 'package:beehome/features/authentication/views/minute_clock.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('clock advances the date at midnight and refreshes on resume', (
    WidgetTester tester,
  ) async {
    DateTime now = DateTime(2026, 12, 31, 23, 59, 59);
    await tester.pumpWidget(
      Directionality(
        textDirection: TextDirection.ltr,
        child: MinuteClock(
          now: () => now,
          builder: (BuildContext context, DateTime value) => Text(
            '${value.year}-${value.month}-${value.day} ${value.hour}:${value.minute}',
          ),
        ),
      ),
    );
    expect(find.text('2026-12-31 23:59'), findsOneWidget);
    now = DateTime(2027, 1, 1);
    await tester.pump(const Duration(seconds: 1));
    expect(find.text('2027-1-1 0:0'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.paused);
    now = DateTime(2027, 1, 2, 12, 30);
    await tester.pump(const Duration(minutes: 2));
    expect(find.text('2027-1-1 0:0'), findsOneWidget);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pump();
    expect(find.text('2027-1-2 12:30'), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.pump(const Duration(minutes: 1));
    expect(tester.takeException(), isNull);
  });
}
