// Integration test for ExelBid plugin global channel.

import 'package:exelbid_plugin/exelbid_plugin.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('sdkVersion returns a non-empty string', (tester) async {
    final version = await Exelbid.sdkVersion;
    expect(version, isNotEmpty);
  });

  testWidgets('setLogLevel does not throw', (tester) async {
    await Exelbid.setLogLevel(LogLevel.debug);
  });
}
