import 'package:flutter_test/flutter_test.dart';
import 'package:ai_life_vault/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame.
    await tester.pumpWidget(const AiLifeVaultApp());
  });
}
