import 'package:flutter_test/flutter_test.dart';
import 'package:eday_app/camera_view_model.dart';

void main() {
  group('CameraViewModel', () {
    test('toggleGuideline changes state', () {
      final vm = CameraViewModel();
      expect(vm.showGuideline, isTrue);
      vm.toggleGuideline();
      expect(vm.showGuideline, isFalse);
    });

    test('setters notify listeners', () {
      final vm = CameraViewModel();
      int callCount = 0;
      vm.addListener(() => callCount++);

      vm.isInit = true;
      vm.isProcessing = true;
      vm.previewImagePath = 'test';
      
      expect(callCount, 3);
    });
  });
}
