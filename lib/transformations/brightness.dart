import 'dart:typed_data';

import '../bitmap.dart';
import 'utils/color.dart';

Bitmap brightness(Bitmap bitmap, double brightnessRate) {
  final Bitmap copy = bitmap.copyHeadless();
  brightnessCore(copy.contentByteData, brightnessRate);
  return copy;
}

/// Changes brightness of [sourceBmp] accordingly to [brightnessRate] .
///
/// [brightnessRate] Can be between -1.0 and 1.0. 0.0 does nothing;
void brightnessCore(Uint8List sourceBmp, double brightnessRate) {
  assert(brightnessRate >= -1.0 && brightnessRate <= 1.0);
  assert(sourceBmp != null);

  if (brightnessRate == 0.0) return;

  final brightness = brightnessRate * 255;

  final size = sourceBmp.length;
  for (int i = 0; i < size; i += 4) {
    sourceBmp[i] = clamp255(sourceBmp[i] + brightness);
    sourceBmp[i + 1] = clamp255(sourceBmp[i + 1] + brightness);
    sourceBmp[i + 2] = clamp255(sourceBmp[i + 2] + brightness);
  }
}
