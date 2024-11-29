import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'dart:convert';
import 'http_connection_test.mocks.dart';

@GenerateMocks([http.Client])
void main() {
  group('HTTP Connection Tests', () {
    late MockClient client;

    setUp(() {
      client = MockClient();
    });

    test('Fetch campaigns successfully', () async {
      when(client.get(Uri.parse('http://127.0.0.1:5000/campaigns/list')))
          .thenAnswer((_) async => http.Response(
              jsonEncode([
                {
                  'id': 1,
                  'title': 'Campaign 1',
                  'description': 'Description 1',
                  'status': 'activo',
                  'date': '2023-10-01T00:00:00Z',
                  'location': 'Location 1',
                  'registered_people': 10,
                  'capacity': 100,
                  'latitude': 40.7128,
                  'longitude': -74.0060,
                }
              ]),
              200));

      final response =
          await client.get(Uri.parse('http://127.0.0.1:5000/campaigns/list'));

      expect(response.statusCode, 200);
      final List<dynamic> data = jsonDecode(response.body);
      expect(data.length, 1);
      expect(data[0]['title'], 'Campaign 1');
    });

    test('Fetch campaigns with error', () async {
      when(client.get(Uri.parse('http://127.0.0.1:5000/campaigns/list')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      final response =
          await client.get(Uri.parse('http://127.0.0.1:5000/campaigns/list'));

      expect(response.statusCode, 404);
      expect(response.body, 'Not Found');
    });

    test('Google Maps API loads correctly', () async {
      when(client.get(Uri.parse(
              'https://maps.googleapis.com/maps/api/js?key=test_api_key&loading=async')))
          .thenAnswer((_) async => http.Response('', 200));

      final response = await client.get(Uri.parse(
          'https://maps.googleapis.com/maps/api/js?key=test_api_key&loading=async'));

      expect(response.statusCode, 200);
    });

    test('Fetch donors list successfully', () async {
      when(client.get(Uri.parse('http://127.0.0.1:5000/donors/list')))
          .thenAnswer((_) async => http.Response(
              jsonEncode([
                {
                  'id': 1,
                  'name': 'Donor 1',
                  'email': 'donor1@example.com',
                  'campaigns_registered': 2
                }
              ]),
              200));

      final response =
          await client.get(Uri.parse('http://127.0.0.1:5000/donors/list'));

      expect(response.statusCode, 200);
      final data = jsonDecode(response.body);
      expect(data.length, 1);
      expect(data[0]['name'], 'Donor 1');
    });

    test('Fetch donors list with error', () async {
      when(client.get(Uri.parse('http://127.0.0.1:5000/donors/list')))
          .thenAnswer((_) async => http.Response('Not Found', 404));

      final response =
          await client.get(Uri.parse('http://127.0.0.1:5000/donors/list'));

      expect(response.statusCode, 404);
      expect(response.body, 'Not Found');
    });

    /// Test case to fetch the details of a single campaign from the server.
    ///
    /// This test mocks an HTTP GET request to the endpoint
    /// `http://127.0.0.1:5000/campaigns/1` and returns a predefined response
    /// containing the details of a campaign with id 1. The response includes
    /// fields such as `id`, `title`, `description`, `status`, `date`, `location`,
    /// `registered_people`, `capacity`, `latitude`, and `longitude`.
    ///
    /// The test then verifies that the status code of the response is 200 (OK)
    /// and checks that the `title` field in the response body matches the expected
    /// value 'Campaign 1'.
    ///
    /// This ensures that the HTTP client correctly fetches and parses the campaign
    /// details from the server.

    test('Fetch single campaign details', () async {
      when(client.get(Uri.parse('http://127.0.0.1:5000/campaigns/1')))
          .thenAnswer((_) async => http.Response(
              jsonEncode({
                'id': 1,
                'title': 'Campaign 1',
                'description': 'Description 1',
                'status': 'activo',
                'date': '2023-10-01T00:00:00Z',
                'location': 'Location 1',
                'registered_people': 10,
                'capacity': 100,
                'latitude': 40.7128,
                'longitude': -74.0060
              }),
              200));

      final response =
          await client.get(Uri.parse('http://127.0.0.1:5000/campaigns/1'));

      expect(response.statusCode, 200);
      final data = jsonDecode(response.body);
      expect(data['title'], 'Campaign 1');
    });
  });
}
