import 'dart:typed_data';

void verticalFlip(Uint8List bmp, int width, int height, int pixelLength) {
  final int lineLength = width * pixelLength;
  final int halfHeight = height ~/ 2;

  for (int line = 0; line < halfHeight; line++) {
    final int startOfLine = line * lineLength;
    final int startOfOppositeLine = (height - 1 - line) * lineLength;
    for (int column = 0; column < width; column++) {
      final int pixelStart = startOfLine + column * pixelLength;
      final int pixelEnd = pixelStart + pixelLength;

      final int oppositePixelStart = startOfOppositeLine + column * pixelLength;
      final int oppositePixelEnd = oppositePixelStart + pixelLength;

      final Uint8List oppositePixel =
          bmp.sublist(oppositePixelStart, oppositePixelEnd);
      final Uint8List targetPixel = bmp.sublist(pixelStart, pixelEnd);

      bmp.setRange(oppositePixelStart, oppositePixelEnd, targetPixel);
      bmp.setRange(pixelStart, pixelEnd, oppositePixel);
    }
  }
}

void horizontalFlip(Uint8List bmp, int width, int height, int pixelLength) {
  final int lineLength = width * pixelLength;
  final int halfLine = lineLength ~/ 2;

  for (int line = 0; line < height; line++) {
    final int startOfLine = line * lineLength;
    for (int relativeColumnStart = 0;
        relativeColumnStart < halfLine;
        relativeColumnStart += pixelLength) {
      final int pixelStart = startOfLine + relativeColumnStart;
      final int pixelEnd = pixelStart + pixelLength;

      final int relativeOppositePixelStart =
          lineLength - relativeColumnStart - pixelLength;
      final int oppositePixelStart = startOfLine + relativeOppositePixelStart;
      final int oppositePixelEnd = oppositePixelStart + pixelLength;

      final Uint8List oppositePixel =
          bmp.sublist(oppositePixelStart, oppositePixelEnd);
      final Uint8List targetPixel = bmp.sublist(pixelStart, pixelEnd);

      bmp.setRange(oppositePixelStart, oppositePixelEnd, targetPixel);
      bmp.setRange(pixelStart, pixelEnd, oppositePixel);
    }
  }
}
