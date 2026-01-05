import 'dart:typed_data';
import 'package:bitmap/src/bitmap.dart';
import 'package:bitmap/src/operation/operation.dart';

class BitmapResize implements BitmapOperation {
  BitmapResize.to({int? width, int? height})
      : resizeWidth = width,
        resizeHeight = height,
        assert(
          width != null || height != null,
          'You have to provide either width or height to resize an image',
        );

  final int? resizeHeight;
  final int? resizeWidth;

  @override
  Bitmap applyTo(Bitmap bitmap) {
    final width = bitmap.width;
    final height = bitmap.height;

    if (resizeWidth == null && resizeHeight == null) {
      throw UnsupportedError(
        'You have to provide either width or height to resize an image',
      );
    }

    // keep aspect ratio
    final toWidth = resizeWidth ?? (resizeHeight! * (width / height)).toInt();
    final toHeight = resizeHeight ?? (resizeWidth! * (height / width)).toInt();

    final newBitmapBytesExtent =
        (toWidth * toHeight) * RGBA32BitmapHeader.kPixelLength;

    final resized = Bitmap.fromHeadless(
      toWidth,
      toHeight,
      Uint8List(newBitmapBytesExtent),
    );

    _resizeCore(
      bitmap.content,
      resized.content,
      width,
      height,
      toWidth,
      toHeight,
    );

    return resized;
  }

  void _resizeCore(
    Uint8List sourceBmp,
    Uint8List destBmp,
    int sourceWidth,
    int sourceHeight,
    int width, [
    int height = -1,
  ]) {
    assert(width > 0 && height > 0, 'width and height must be > 0');
    const pixelLength = RGBA32BitmapHeader.kPixelLength;

    final proportionY = sourceHeight / height;
    final proportionX = sourceWidth / width;

    final lineLength = width * pixelLength;
    final sourceLineLength = sourceWidth * pixelLength;

    // inspired by dart_image, interpolation: nearest
    final sourceColumns = Int32List(width);

    for (var column = 0; column < width; column++) {
      sourceColumns[column] = (column * proportionX).toInt();
    }

    for (var line = 0; line < height; line++) {
      final startOfLine = line * lineLength;

      final sourceLine = (line * proportionY).toInt();
      final sourceStartOfLine = sourceLine * sourceLineLength;

      for (var column = 0; column < width; column++) {
        final columnStart = column * pixelLength;
        final pixelStart = startOfLine + columnStart;
        final pixelEnd = pixelStart + pixelLength;

        final sourceColumnStart = sourceColumns[column] * pixelLength;
        final sourcePixelStart = sourceStartOfLine + sourceColumnStart;
        final sourcePixelEnd = sourcePixelStart + pixelLength;

        final sourcePixel =
            sourceBmp.sublist(sourcePixelStart, sourcePixelEnd);

        destBmp.setRange(pixelStart, pixelEnd, sourcePixel);
      }
    }
  }
}
