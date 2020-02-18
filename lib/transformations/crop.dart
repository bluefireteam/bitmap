import 'dart:typed_data';

import '../bitmap.dart';

/// Crops the source bitmap to rectangle defined by top, left, width and height.
Bitmap cropLTWH(
  Bitmap bitmap,
  int left,
  int top,
  int width,
  int height,
) {
  assert(left >= 0);
  assert(top >= 0);
  assert(width > 0);
  assert(height > 0);
  assert(left + width <= bitmap.width);
  assert(top + height <= bitmap.height);

  final int newBitmapSize = width * height * bitmapPixelLength;

  final Bitmap cropped = Bitmap.fromHeadless(
    width,
    height,
    Uint8List(newBitmapSize),
  );

  cropCore(
    bitmap.content,
    cropped.content,
    bitmap.width, // Height is not needed.
    left,
    top,
    width,
    height,
  );

  return cropped;
}

/// Crops the source bitmap to rectangle defined by top, left, right and bottom.
Bitmap cropLTRB(
  Bitmap bitmap,
  int left,
  int top,
  int right,
  int bottom,
) =>
    cropLTWH(
      bitmap,
      left,
      top,
      right - left,
      bottom - top,
    );

void cropCore(
  Uint8List sourceBmp,
  Uint8List destBmp,
  int sourceWidth,
  int left,
  int top,
  int width,
  int height,
) {
  for (int x = left * bitmapPixelLength;
      x < (left + width) * bitmapPixelLength;
      x++) {
    for (int y = top; y < (top + height); y++) {
      destBmp[x -
              left * bitmapPixelLength +
              (y - top) * width * bitmapPixelLength] =
          sourceBmp[x + y * sourceWidth * bitmapPixelLength];
    }
  }
}
