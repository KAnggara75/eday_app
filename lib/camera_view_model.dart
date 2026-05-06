import 'dart:typed_data';
import 'package:flutter/material.dart';

class CameraViewModel extends ChangeNotifier {
  bool _isInit = false;
  bool _isProcessing = false;
  bool _showGuideline = true;
  String? _previewImagePath;
  Uint8List? _guidelineBytes;
  bool _isLoadingGuideline = false;

  bool get isInit => _isInit;
  bool get isProcessing => _isProcessing;
  bool get showGuideline => _showGuideline;
  String? get previewImagePath => _previewImagePath;
  Uint8List? get guidelineBytes => _guidelineBytes;
  bool get isLoadingGuideline => _isLoadingGuideline;

  set isInit(bool val) { _isInit = val; notifyListeners(); }
  set isProcessing(bool val) { _isProcessing = val; notifyListeners(); }
  set showGuideline(bool val) { _showGuideline = val; notifyListeners(); }
  set previewImagePath(String? val) { _previewImagePath = val; notifyListeners(); }
  set guidelineBytes(Uint8List? val) { _guidelineBytes = val; notifyListeners(); }
  set isLoadingGuideline(bool val) { _isLoadingGuideline = val; notifyListeners(); }

  void toggleGuideline() {
    _showGuideline = !_showGuideline;
    notifyListeners();
  }
}
