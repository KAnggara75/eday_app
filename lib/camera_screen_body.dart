import 'package:flutter/material.dart';
import 'camera_view.dart';
import 'camera_controller_service.dart';
import 'dart:typed_data';

class CameraScreenBody extends StatelessWidget {
  final CameraControllerService cameraService;
  final bool showGuideline;
  final bool isLoadingGuideline;
  final Uint8List? guidelineBytes;
  final String? previewImagePath;
  final bool isProcessing;
  final double cameraVisualRatio;
  final VoidCallback onToggleGuideline;
  final VoidCallback onOpenGallery;
  final VoidCallback onTakePicture;

  const CameraScreenBody({
    super.key,
    required this.cameraService,
    required this.showGuideline,
    required this.isLoadingGuideline,
    this.guidelineBytes,
    this.previewImagePath,
    required this.isProcessing,
    required this.cameraVisualRatio,
    required this.onToggleGuideline,
    required this.onOpenGallery,
    required this.onTakePicture,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        // Kiri: Layer Kamera dan Preview
        Expanded(
          child: CameraView(
            cameraService: cameraService,
            showGuideline: showGuideline,
            isLoadingGuideline: isLoadingGuideline,
            guidelineBytes: guidelineBytes,
            previewImagePath: previewImagePath,
            isProcessing: isProcessing,
            cameraVisualRatio: cameraVisualRatio,
          ),
        ),

        // Kanan: Tombol-tombol Aksi (Vertikal)
        Container(
          width: 100,
          color: Colors.black,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              // Toggle Guideline
              IconButton(
                icon: Icon(
                  showGuideline ? Icons.grid_on : Icons.grid_off,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: onToggleGuideline,
                tooltip: 'Toggle Guideline',
              ),

              // Tombol Shutter (Tengah)
              GestureDetector(
                onTap: onTakePicture,
                child: Container(
                  height: 70,
                  width: 70,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.grey, width: 5),
                  ),
                  child: isProcessing
                      ? const Padding(
                          padding: EdgeInsets.all(15.0),
                          child: CircularProgressIndicator(color: Colors.black),
                        )
                      : null,
                ),
              ),

              // Gallery Button
              IconButton(
                icon: const Icon(
                  Icons.photo_library,
                  color: Colors.white,
                  size: 30,
                ),
                onPressed: onOpenGallery,
                tooltip: 'Gallery',
              ),
            ],
          ),
        ),
      ],
    );
  }
}
