import 'package:flutter/material.dart';
import 'camera_controller_service.dart';
import 'camera_guideline_overlay.dart';
import 'package:camera/camera.dart';
import 'dart:typed_data';

class CameraView extends StatelessWidget {
  final CameraControllerService cameraService;
  final bool showGuideline;
  final bool isLoadingGuideline;
  final Uint8List? guidelineBytes;
  final String? previewImagePath;
  final bool isProcessing;
  final double cameraVisualRatio;

  const CameraView({
    super.key,
    required this.cameraService,
    required this.showGuideline,
    required this.isLoadingGuideline,
    this.guidelineBytes,
    this.previewImagePath,
    required this.isProcessing,
    required this.cameraVisualRatio,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Camera Preview
        Center(
          child: AspectRatio(
            aspectRatio: 3 / 2,
            child: SizedBox(
              width: cameraVisualRatio,
              height: 1.0,
              child: cameraService.isInitialized
                  ? CameraPreview(cameraService.controller!)
                  : const Center(child: CircularProgressIndicator()),
            ),
          ),
        ),

        // Guideline Overlay
        CameraGuidelineOverlay(
          showGuideline: showGuideline,
          isLoading: isLoadingGuideline,
          guidelineBytes: guidelineBytes,
        ),

        // Processing Indicator
        if (isProcessing)
          const Center(child: CircularProgressIndicator()),

        // Recent Preview Thumbnail
        if (previewImagePath != null)
          Positioned(
            bottom: 20,
            right: 20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.white, width: 2),
                image: DecorationImage(
                  image: AssetImage(previewImagePath!), // Or FileImage in real app
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
