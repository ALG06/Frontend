import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;

void main() {
  test('Test connection to http://127.0.0.1:5000/sample', () async {
    final response = await http.get(Uri.parse('http://127.0.0.1:5000/sample'));
    expect(response.statusCode, 200);
  });
}

// `flutter test test/backend_test.dart`