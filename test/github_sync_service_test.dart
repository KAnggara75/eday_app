import 'dart:typed_data';
import 'package:file/memory.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:mocktail/mocktail.dart';
import 'package:eday_app/github_sync_service.dart';

class MockClient extends Mock implements http.Client {}

class FakeUri extends Fake implements Uri {}

void main() {
  setUpAll(() {
    registerFallbackValue(FakeUri());
  });

  group('GithubSyncService', () {
    late GithubSyncService service;
    late MockClient mockClient;
    const token = 'fake_token';
    const owner = 'test_owner';
    const repo = 'test_repo';

    setUp(() {
      mockClient = MockClient();
      service = GithubSyncService(
        token: token,
        owner: owner,
        repo: repo,
        client: mockClient,
      );
    });

    test(
      'uploadFileWithBytes returns true on successful upload (201)',
      () async {
        final bytes = Uint8List.fromList([1, 2, 3]);
        const targetPath = '2026/test.jpg';

        // Mock GET to check if file exists (returns 404 to trigger upload)
        when(
          () => mockClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => http.Response('Not Found', 404));

        // Mock PUT to upload file
        when(
          () => mockClient.put(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).thenAnswer((_) async => http.Response('Created', 201));

        final result = await service.uploadFileWithBytes(bytes, targetPath);

        expect(result, isTrue);
        verify(
          () => mockClient.get(
            any(that: predicate<Uri>((uri) => uri.path.contains(targetPath))),
            headers: any(named: 'headers'),
          ),
        ).called(1);
        verify(
          () => mockClient.put(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        ).called(1);
      },
    );

    test(
      'uploadFileWithBytes returns true and skips upload if file already exists',
      () async {
        final bytes = Uint8List.fromList([1, 2, 3]);
        const targetPath = '2026/test.jpg';

        // Mock GET to check if file exists (returns 200)
        when(
          () => mockClient.get(any(), headers: any(named: 'headers')),
        ).thenAnswer((_) async => http.Response('{"sha": "123"}', 200));

        final result = await service.uploadFileWithBytes(bytes, targetPath);

        expect(result, isTrue);
        verify(
          () => mockClient.get(any(), headers: any(named: 'headers')),
        ).called(1);
        verifyNever(
          () => mockClient.put(
            any(),
            headers: any(named: 'headers'),
            body: any(named: 'body'),
          ),
        );
      },
    );

    test('uploadFileWithBytes returns false on upload failure', () async {
      final bytes = Uint8List.fromList([1, 2, 3]);
      const targetPath = '2026/test.jpg';

      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response('Not Found', 404));

      when(
        () => mockClient.put(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('Bad Request', 400));

      final result = await service.uploadFileWithBytes(bytes, targetPath);

      expect(result, isFalse);
    });

    test('syncFiles processes list of files and calls onProgress', () async {
      final fs = MemoryFileSystem();
      final testDir = fs.directory('/test')..createSync();
      final file1 = testDir.childFile('260505120000.jpg')
        ..writeAsBytesSync([1]);
      final file2 = testDir.childFile('260505120001.jpg')
        ..writeAsBytesSync([2]);

      // Re-initialize service with MemoryFileSystem
      service = GithubSyncService(
        token: token,
        owner: owner,
        repo: repo,
        client: mockClient,
      );

      // Mock GET (not found) and PUT (success) for both files
      when(
        () => mockClient.get(any(), headers: any(named: 'headers')),
      ).thenAnswer((_) async => http.Response('Not Found', 404));
      when(
        () => mockClient.put(
          any(),
          headers: any(named: 'headers'),
          body: any(named: 'body'),
        ),
      ).thenAnswer((_) async => http.Response('Created', 201));

      int progressCount = 0;
      await service.syncFiles([file1, file2], (current, total) {
        progressCount++;
      });

      expect(progressCount, 2);
      expect(file1.existsSync(), isFalse); // Should be deleted after sync
      expect(file2.existsSync(), isFalse);
    });
  });
}
