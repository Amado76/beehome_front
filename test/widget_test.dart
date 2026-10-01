import 'package:beehome/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('MainApp displays its home screen', (tester) async {
    await tester.pumpWidget(const MainApp());

    expect(find.text('Hello World!'), findsOneWidget);
  });
}
