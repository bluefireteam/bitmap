import 'dart:typed_data';

import '../bitmap.dart';

Bitmap flipVertical(Bitmap bitmap) {
  final Bitmap copy = bitmap.cloneHeadless();
  final width = bitmap.width;
  final height = bitmap.height;
  final Uint8List copyContent = copy.content;

  verticalFlipCore(copyContent, width, height);

  return copy;
}

void verticalFlipCore(Uint8List bmp, int width, int height) {
  final int lineLength = width * bitmapPixelLength;
  final int halfHeight = height ~/ 2;

  for (int line = 0; line < halfHeight; line++) {
    final int startOfLine = line * lineLength;
    final int startOfOppositeLine = (height - 1 - line) * lineLength;
    for (int column = 0; column < width; column++) {
      final int pixelStart = startOfLine + column * bitmapPixelLength;
      final int pixelEnd = pixelStart + bitmapPixelLength;

      final int oppositePixelStart =
          startOfOppositeLine + column * bitmapPixelLength;
      final int oppositePixelEnd = oppositePixelStart + bitmapPixelLength;

      final Uint8List oppositePixel =
          bmp.sublist(oppositePixelStart, oppositePixelEnd);
      final Uint8List targetPixel = bmp.sublist(pixelStart, pixelEnd);

      bmp.setRange(oppositePixelStart, oppositePixelEnd, targetPixel);
      bmp.setRange(pixelStart, pixelEnd, oppositePixel);
    }
  }
}

Bitmap flipHorizontal(Bitmap bitmap) {
  final Bitmap copy = bitmap.cloneHeadless();
  final width = bitmap.width;
  final height = bitmap.height;
  final Uint8List copyContent = copy.content;

  horizontalFlipCore(copyContent, width, height);

  return copy;
}

void horizontalFlipCore(Uint8List bmp, int width, int height) {
  final int lineLength = width * bitmapPixelLength;
  final int halfLine = lineLength ~/ 2;

  for (int line = 0; line < height; line++) {
    final int startOfLine = line * lineLength;
    for (int relativeColumnStart = 0;
        relativeColumnStart < halfLine;
        relativeColumnStart += bitmapPixelLength) {
      final int pixelStart = startOfLine + relativeColumnStart;
      final int pixelEnd = pixelStart + bitmapPixelLength;

      final int relativeOppositePixelStart =
          lineLength - relativeColumnStart - bitmapPixelLength;
      final int oppositePixelStart = startOfLine + relativeOppositePixelStart;
      final int oppositePixelEnd = oppositePixelStart + bitmapPixelLength;

      final Uint8List oppositePixel =
          bmp.sublist(oppositePixelStart, oppositePixelEnd);
      final Uint8List targetPixel = bmp.sublist(pixelStart, pixelEnd);

      bmp.setRange(oppositePixelStart, oppositePixelEnd, targetPixel);
      bmp.setRange(pixelStart, pixelEnd, oppositePixel);
    }
  }
}
