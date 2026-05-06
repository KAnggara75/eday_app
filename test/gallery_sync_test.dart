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
    await dotenv.load(fileName: '.env', isOptional: true, mergeWith: {'GITHUB_PAT': 'fake'});
  });

  testWidgets('GalleryScreen sync button calls syncFiles', (WidgetTester tester) async {
    final fs = MemoryFileSystem();
    final testDir = fs.directory('.');
    testDir.childFile('image1.jpg').createSync();
    
    final mockSyncService = MockGithubSyncService();
    // Mock syncFiles to return immediately
    when(() => mockSyncService.syncFiles(any(), any())).thenAnswer((_) async {});

    await tester.pumpWidget(MaterialApp(
      home: GalleryScreen(
        fileSystem: fs,
        syncService: mockSyncService,
      ),
    ));
    await tester.pumpAndSettle();

    // Find and tap the sync button (cloud_upload icon)
    await tester.tap(find.byIcon(Icons.cloud_upload));
    await tester.pumpAndSettle();

    verify(() => mockSyncService.syncFiles(any(), any())).called(1);
    expect(find.text('Sync completed!'), findsOneWidget);
  });
}
