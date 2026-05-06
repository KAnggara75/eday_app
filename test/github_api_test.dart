import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:eday_app/github_api_service.dart';

class MockClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  group('GithubApiService', () {
    late GithubApiService service;
    late MockClient mockClient;

    setUp(() {
      mockClient = MockClient();
      service = GithubApiService(client: mockClient);
    });

    test('fetchGuidelineImage returns bytes on 200', () async {
      final expectedBytes = Uint8List.fromList([1, 2, 3]);
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response.bytes(expectedBytes, 200));

      final result = await service.fetchGuidelineImage(
        owner: 'o',
        repo: 'r',
        targetPath: 'p',
        token: 't',
      );

      expect(result, expectedBytes);
    });

    test('fetchGuidelineImage returns null on error', () async {
      when(() => mockClient.get(any(), headers: any(named: 'headers')))
          .thenAnswer((_) async => http.Response('Error', 404));

      final result = await service.fetchGuidelineImage(
        owner: 'o',
        repo: 'r',
        targetPath: 'p',
        token: 't',
      );

      expect(result, isNull);
    });
  });
}
