import 'dart:typed_data';

import '../bitmap.dart';

Bitmap contrast(Bitmap bitmap, double contrastRate) {
  final Bitmap copy = bitmap.copyHeadless();
  contrastCore(copy.contentByteData, contrastRate);

  return copy;
}

void contrastCore(Uint8List sourceBmp, double contrastRate) {
  assert(contrastRate >= 0.0);
  assert(sourceBmp != null);

  final double contrastSquare = contrastRate * contrastRate;
  final Uint8List contrastApplier = Uint8List(256);
  for (int i = 0; i < 256; ++i) {
    contrastApplier[i] =
        ((((((i / 255.0) - 0.5) * contrastSquare) + 0.5) * 255.0).toInt())
            .clamp(0, 255)
            .toInt();
  }
  final size = sourceBmp.length;
  for (int i = 0; i < size; i += 4) {
    sourceBmp[i] = contrastApplier[sourceBmp[i]];
    sourceBmp[i + 1] = contrastApplier[sourceBmp[i + 1]];
    sourceBmp[i + 2] = contrastApplier[sourceBmp[i + 2]];
  }
}
