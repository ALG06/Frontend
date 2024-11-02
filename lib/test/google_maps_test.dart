import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() async {
    await dotenv.load(fileName: 'env');
  });

  testWidgets('API key should be available from environment',
      (WidgetTester tester) async {
    expect(dotenv.env['MAPS_API_KEY'], isNotNull);
    expect(dotenv.env['MAPS_API_KEY']?.isEmpty, isFalse);
  });

  testWidgets('API key should be available from environment',
      (WidgetTester tester) async {
    expect(dotenv.env['MAPS_API_URL'], isNotNull);
    expect(dotenv.env['MAPS_API_URL']?.isEmpty, isFalse);
  });
}
