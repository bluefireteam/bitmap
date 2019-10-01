import 'dart:typed_data';
import 'dart:ffi' as ffi;

import 'package:bitmap/ffi.dart';

import '../bitmap.dart';
import 'utils/color.dart';

Bitmap brightness(Bitmap bitmap, double brightnessRate) {
  final Bitmap copy = bitmap.cloneHeadless();
  brightnessCoreFFI(copy.content, brightnessRate);
  return copy;
}

/// Changes brightness of [sourceBmp] accordingly to [brightnessRate] .
///
/// [brightnessRate] Can be between -1.0 and 1.0. 0.0 does nothing;
void brightnessCore(Uint8List sourceBmp, double brightnessRate) {
  assert(brightnessRate >= -1.0 && brightnessRate <= 1.0);
  assert(sourceBmp != null);

  if (brightnessRate == 0.0) {
    return;
  }

  final brightness = (brightnessRate * 255).toInt();

  final size = sourceBmp.length;
  for (int i = 0; i < size; i += 4) {
    sourceBmp[i] = clamp255Int(nativeSum(sourceBmp[i], brightness));
    sourceBmp[i + 1] = clamp255Int(nativeSum(sourceBmp[i + 1], brightness));
    sourceBmp[i + 2] = clamp255Int(nativeSum(sourceBmp[i + 2], brightness));
  }
}



void brightnessCoreFFI(Uint8List sourceBmp, double brightnessRate) {
  assert(brightnessRate >= -1.0 && brightnessRate <= 1.0);
  assert(sourceBmp != null);

  if (brightnessRate == 0.0) {
    return;
  }

  final brightnessAmount = brightnessRate * 255;
  print("shit $brightnessAmount");
  final ffi.Pointer<ffi.Uint8> startingPointer = prepareFFI(sourceBmp);
  print("fuck $brightnessAmount");
  brightnessFFIImpl(startingPointer, sourceBmp.length, brightnessAmount);
  for (int i = 0; i < sourceBmp.length; i++) {
    startingPointer.elementAt(i).load();
  }

}
