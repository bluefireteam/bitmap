import 'dart:typed_data';

import '../bitmap.dart';

Future<Bitmap> resizeHeight(Bitmap bitmap, int resizeHeight) async {
  final width = bitmap.width;
  final height = bitmap.height;
  final int resizeWidth = (resizeHeight * (width / height)).toInt();
  return resize(bitmap, resizeWidth, resizeHeight);
}

Future<Bitmap> resizeWidth(Bitmap bitmap, int resizeWidth) async {
  final width = bitmap.width;
  final height = bitmap.height;
  final int resizeHeight = (resizeWidth * (height / width)).toInt();

  return resize(bitmap, resizeWidth, resizeHeight);
}

Future<Bitmap> resize(Bitmap bitmap, int resizeWidth, int resizeHeight) async {
  final width = bitmap.width;
  final height = bitmap.height;

  final int newBitmapSize = (resizeWidth * resizeHeight) * bitmapPixelLength;

  final Bitmap resized = Bitmap.fromHeadless(
    resizeWidth,
    resizeHeight,
    Uint8List(newBitmapSize),
  );

  resizeCore(
    bitmap.contentByteData,
    resized.contentByteData,
    width,
    height,
    resizeWidth,
    resizeHeight,
  );

  return resized;
}

void resizeCore(
  Uint8List sourceBmp,
  Uint8List destBmp,
  int sourceWidth,
  int sourceHeight,
  int width, [
  int height = -1,
]) {
  assert(width > 0 && height > 0);

  final double proportionY = sourceHeight / height;
  final double proportionX = sourceWidth / width;

  final int lineLength = width * bitmapPixelLength;
  final int sourceLineLength = sourceWidth * bitmapPixelLength;

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
      final int columnStart = column * bitmapPixelLength;
      final int pixelStart = startOfLine + columnStart;
      final int pixelEnd = pixelStart + bitmapPixelLength;

      final int sourceColumnStart = sourceColumns[column] * bitmapPixelLength;
      final int sourcePixelStart = sourceStartOfLine + sourceColumnStart;
      final int sourcePixelEnd = sourcePixelStart + bitmapPixelLength;

      final Uint8List sourcePixel =
          sourceBmp.sublist(sourcePixelStart, sourcePixelEnd);

      destBmp.setRange(pixelStart, pixelEnd, sourcePixel);
    }
  }
}
