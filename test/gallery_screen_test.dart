import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eday_app/gallery_screen.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:file/memory.dart';
import 'helpers.dart';

void main() {
  setupPathProviderMock();

  setUpAll(() async {
    // Mock dotenv by providing values in mergeWith
    await dotenv.load(
      fileName: '.env',
      isOptional: true,
      mergeWith: {
        'GITHUB_PAT': 'fake',
        'GITHUB_OWNER': 'test',
        'GITHUB_REPO': 'test',
      },
    );
  });

  testWidgets('GalleryScreen shows images in grid', (
    WidgetTester tester,
  ) async {
    final fs = MemoryFileSystem();
    final testDir = fs.directory('.'); // path_provider mock returns '.'
    testDir.childFile('image1.jpg').createSync();
    testDir.childFile('image2.jpg').createSync();

    await tester.pumpWidget(MaterialApp(home: GalleryScreen(fileSystem: fs)));
    await tester.pumpAndSettle();

    expect(find.byType(GridView), findsOneWidget);
    expect(find.byType(Image), findsNWidgets(2));

    // Tap on the first image
    await tester.tap(find.byType(Image).first);
    await tester.pumpAndSettle();

    // Verify FullScreenImage is shown
    expect(find.byType(PageView), findsOneWidget);
  });
}
