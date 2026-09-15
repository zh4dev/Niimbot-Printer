import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:niimbot_print/niimbot_print.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('native plugin reports a boolean connection state',
      (tester) async {
    final connected = await NiimbotPrint().isConnected();
    expect(connected, isA<bool>());
  });
}
