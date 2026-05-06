import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:eday_app/camera_guideline_overlay.dart';

void main() {
  group('CameraGuidelineOverlay', () {
    testWidgets('shows nothing when showGuideline is false', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CameraGuidelineOverlay(showGuideline: false, isLoading: false),
        ),
      );
      expect(find.byType(SizedBox), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading is true', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CameraGuidelineOverlay(showGuideline: true, isLoading: true),
        ),
      );
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows image when guidelineBytes is provided', (
      WidgetTester tester,
    ) async {
      // Use valid PNG bytes for a 1x1 image
      final bytes = Uint8List.fromList([
        137,
        80,
        78,
        71,
        13,
        10,
        26,
        10,
        0,
        0,
        0,
        13,
        73,
        72,
        68,
        82,
        0,
        0,
        0,
        1,
        0,
        0,
        0,
        1,
        8,
        6,
        0,
        0,
        0,
        31,
        21,
        196,
        137,
        0,
        0,
        0,
        10,
        73,
        68,
        65,
        84,
        120,
        156,
        99,
        0,
        1,
        0,
        0,
        5,
        0,
        1,
        13,
        10,
        45,
        180,
        0,
        0,
        0,
        0,
        73,
        69,
        78,
        68,
        174,
        66,
        96,
        130,
      ]);
      await tester.pumpWidget(
        MaterialApp(
          home: CameraGuidelineOverlay(
            showGuideline: true,
            isLoading: false,
            guidelineBytes: bytes,
          ),
        ),
      );
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('shows error text when guidelineBytes is null', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: CameraGuidelineOverlay(
            showGuideline: true,
            isLoading: false,
            guidelineBytes: null,
          ),
        ),
      );
      expect(find.text('Guideline not available'), findsOneWidget);
    });
  });
}
