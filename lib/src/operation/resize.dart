import 'dart:typed_data';
import '../bitmap.dart';
import 'operation.dart';

class BitmapResize implements BitmapOperation {
  BitmapResize.to({int? width, int? height})
      : resizeWidth = width,
        resizeHeight = height,
        assert(
          width != null || height != null,
          "You have to provide either width or height to resize an image",
        );

  final int? resizeHeight;
  final int? resizeWidth;

  @override
  Bitmap applyTo(Bitmap bitmap) {
    final width = bitmap.width;
    final height = bitmap.height;

    if (resizeWidth == null && resizeHeight == null) {
      throw UnsupportedError(
        "You have to provide either width or height to resize an image",
      );
    }

    // keep aspect ratio
    final toWidth = resizeWidth ?? (resizeHeight! * (width / height)).toInt();
    final toHeight = resizeHeight ?? (resizeWidth! * (height / width)).toInt();

    final int newBitmapBytesExtent =
        (toWidth * toHeight) * RGBA32BitmapHeader.pixelLength;

    final Bitmap resized = Bitmap.fromHeadless(
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
    assert(width > 0 && height > 0);
    const pixelLength = RGBA32BitmapHeader.pixelLength;

    final double proportionY = sourceHeight / height;
    final double proportionX = sourceWidth / width;

    final int lineLength = width * pixelLength;
    final int sourceLineLength = sourceWidth * pixelLength;

    // inspired by dart_image, interpolation: nearest
    final sourceColumns = Int32List(width);

    for (int column = 0; column < width; column++) {
      sourceColumns[column] = (column * proportionX).toInt();
    }

    for (int line = 0; line < height; line++) {
      final int startOfLine = line * lineLength;

      final int sourceLine = (line * proportionY).toInt();
      final int sourceStartOfLine = sourceLine * sourceLineLength;

      for (int column = 0; column < width; column++) {
        final int columnStart = column * pixelLength;
        final int pixelStart = startOfLine + columnStart;
        final int pixelEnd = pixelStart + pixelLength;

        final int sourceColumnStart = sourceColumns[column] * pixelLength;
        final int sourcePixelStart = sourceStartOfLine + sourceColumnStart;
        final int sourcePixelEnd = sourcePixelStart + pixelLength;

        final Uint8List sourcePixel =
            sourceBmp.sublist(sourcePixelStart, sourcePixelEnd);

        destBmp.setRange(pixelStart, pixelEnd, sourcePixel);
      }
    }
  }
}
