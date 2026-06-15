import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fit_byte/main.dart';

void main() {
  testWidgets('App splash screen smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(
      const ProviderScope(
        child: FitByteApp(),
      ),
    );

    // Verify that Splash screen is shown with the app name.
    expect(find.text('FitByte'), findsOneWidget);
    expect(find.text('AI-Powered Nutrition'), findsOneWidget);
  });
}
