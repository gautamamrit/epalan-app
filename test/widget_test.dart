import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:epalan_app/main.dart';

void main() {
  testWidgets('App loads successfully', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: EPalanApp(),
      ),
    );

    // Verify that the app loads
    expect(find.text('All Farms'), findsOneWidget);
  });
}
