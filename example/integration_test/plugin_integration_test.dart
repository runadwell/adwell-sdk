import 'package:adwell_sdk/adwell_sdk.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('install id is a stable lowercase UUID', (tester) async {
    await Adwell.configure(apiKey: 'not a key'); // logged, never thrown
    final id = await Adwell.installId;
    expect(
        id,
        matches(RegExp(
            r'^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$')));
    expect(await Adwell.installId, id);
  });
}
