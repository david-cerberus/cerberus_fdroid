import 'package:flutter_test/flutter_test.dart';
import 'package:secure_password_manager/main.dart';

void main() {
  testWidgets('App loads and starts checking auth status', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const MyApp());

    // It should initially show the loading screen/checking state
    expect(find.byType(AuthWrapper), findsOneWidget);
  });
}
