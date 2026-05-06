import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eday_app/camera_view.dart';
import 'package:eday_app/camera_controller_service.dart';
import 'package:mocktail/mocktail.dart';

class MockCameraControllerService extends Mock implements CameraControllerService {}

void main() {
  group('CameraView', () {
    late MockCameraControllerService mockService;

    setUp(() {
      mockService = MockCameraControllerService();
      when(() => mockService.isInitialized).thenReturn(false);
    });

    testWidgets('shows loading when not initialized', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CameraView(
          cameraService: mockService,
          showGuideline: false,
          isLoadingGuideline: false,
          isProcessing: false,
          cameraVisualRatio: 1.0,
        ),
      ));
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows processing indicator', (WidgetTester tester) async {
      await tester.pumpWidget(MaterialApp(
        home: CameraView(
          cameraService: mockService,
          showGuideline: false,
          isLoadingGuideline: false,
          isProcessing: true,
          cameraVisualRatio: 1.0,
        ),
      ));
      expect(find.byType(CircularProgressIndicator), findsNWidgets(2)); // One for not init, one for processing
    });
  });
}
