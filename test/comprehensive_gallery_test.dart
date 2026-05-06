import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eday_app/gallery_screen.dart';
import 'package:eday_app/github_sync_service.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:file/memory.dart';
import 'package:mocktail/mocktail.dart';
import 'helpers.dart';

class MockGithubSyncService extends Mock implements GithubSyncService {}

void main() {
  setupPathProviderMock();

  setUpAll(() async {
    await dotenv.load(
      fileName: '.env',
      isOptional: true,
      mergeWith: {'GITHUB_PAT': 'fake'},
    );
  });

  group('GalleryScreen Comprehensive', () {
    testWidgets('shows loading then empty state', (WidgetTester tester) async {
      final fs = MemoryFileSystem();
      // Initially empty
      await tester.pumpWidget(MaterialApp(home: GalleryScreen(fileSystem: fs)));

      // Should show loading then empty
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      await tester.pumpAndSettle();
      expect(find.text('Belum ada gambar'), findsOneWidget);
    });

    testWidgets('sync button disabled when syncing', (
      WidgetTester tester,
    ) async {
      final fs = MemoryFileSystem();
      fs.directory('.').childFile('a.jpg').createSync();

      final mockSync = MockGithubSyncService();
      // Don't complete the sync immediately to test loading state
      when(() => mockSync.syncFiles(any(), any())).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
      });

      await tester.pumpWidget(
        MaterialApp(
          home: GalleryScreen(fileSystem: fs, syncService: mockSync),
        ),
      );
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.cloud_upload));
      await tester.pump(); // Start sync

      // Check if sync count is shown (e.g. 0/1)
      expect(find.text('0/1'), findsOneWidget);

      // Tap again should do nothing (disabled)
      await tester.tap(find.byIcon(Icons.cloud_upload));
      verify(() => mockSync.syncFiles(any(), any())).called(1);

      // Finish sync
      await tester.pumpAndSettle(const Duration(seconds: 2));
      expect(find.text('Sync completed!'), findsOneWidget);
    });
  });
}
