import 'dart:typed_data';

import 'package:bitmap/src/bitmap.dart';
import 'package:bitmap/src/operation/operation.dart';

/// Crops the source bitmap to rectangle defined by [top], [left], 
/// [width] and [height].
class BitmapCrop extends BitmapOperation {
  /// Crops the source bitmap to rectangle defined by top,
  /// left, width and height.
  BitmapCrop.fromLTWH({
    required this.left,
    required this.top,
    required this.width,
    required this.height,
  })  : assert(left >= 0, 'left must be >= 0'),
        assert(top >= 0, 'top must be >= 0'),
        assert(width > 0, 'width must be > 0'),
        assert(height > 0, 'height must be > 0');

  BitmapCrop.fromLTRB({
    required this.left,
    required this.top,
    required int right,
    required int bottom,
  })  : width = right - left,
        height = bottom - top;

  int left;
  int top;
  int width;
  int height;

  @override
  Bitmap applyTo(Bitmap bitmap) {
    assert(
      left + width <= bitmap.width,
      'left + width must be <= bitmap.width',
    );
    assert(
      top + height <= bitmap.height,
      'top + height must be <= bitmap.height',
    );

    final newBitmapSize = width * height * RGBA32BitmapHeader.kPixelLength;

    final cropped = Bitmap.fromHeadless(
      width,
      height,
      Uint8List(newBitmapSize),
    );

    _cropCore(
      bitmap.content,
      cropped.content,
      bitmap.width,
      // Height is not needed.
      left,
      top,
      width,
      height,
    );

    return cropped;
  }

  void _cropCore(
    Uint8List sourceBmp,
    Uint8List destBmp,
    int sourceWidth,
    int left,
    int top,
    int width,
    int height,
  ) {
    const pixelLength = RGBA32BitmapHeader.kPixelLength;

    for (var x = left * pixelLength; x < (left + width) * pixelLength; x++) {
      for (var y = top; y < (top + height); y++) {
        destBmp[x - left * pixelLength + (y - top) * width * pixelLength] =
            sourceBmp[x + y * sourceWidth * pixelLength];
      }
    }
  }
}
