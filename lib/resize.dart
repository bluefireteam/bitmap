import 'dart:typed_data';

void resizeBitmap(Uint8List sourceBmp, Uint8List destBmp, int pixelLength,
    int sourceWidth, int sourceHeight, int width,
    [int height = -1]) {
  assert(width > 0 && height > 0);

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
