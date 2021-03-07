import 'dart:typed_data';
import '../bitmap.dart';
import 'operation.dart';

class BitmapFlip implements BitmapOperation {
  final _Flip _flip;

  BitmapFlip.vertical() : _flip = _VerticalFlip();
  BitmapFlip.horizontal() : _flip = _HorizontalFlip();

  @override
  Bitmap applyTo(Bitmap bitmap) {
    return _flip.flip(bitmap);
  }
}

abstract class _Flip {
  Bitmap flip(Bitmap bitmap);
}

class _VerticalFlip implements _Flip {
  @override
  Bitmap flip(Bitmap bitmap) {
    final Bitmap copy = bitmap.cloneHeadless();
    final width = bitmap.width;
    final height = bitmap.height;
    final Uint8List copyContent = copy.content;

    _verticalFlipCore(copyContent, width, height);

    return copy;
  }

  void _verticalFlipCore(Uint8List bmp, int width, int height) {
    const pixelLength = RGBA32BitmapHeader.pixelLength;

    final int lineLength = width * pixelLength;
    final int halfHeight = height ~/ 2;

    for (int line = 0; line < halfHeight; line++) {
      final int startOfLine = line * lineLength;
      final int startOfOppositeLine = (height - 1 - line) * lineLength;
      for (int column = 0; column < width; column++) {
        final int pixelStart = startOfLine + column * pixelLength;
        final int pixelEnd = pixelStart + pixelLength;

        final int oppositePixelStart =
            startOfOppositeLine + column * pixelLength;
        final int oppositePixelEnd = oppositePixelStart + pixelLength;

        final Uint8List oppositePixel =
        bmp.sublist(oppositePixelStart, oppositePixelEnd);
        final Uint8List targetPixel = bmp.sublist(pixelStart, pixelEnd);

        bmp.setRange(oppositePixelStart, oppositePixelEnd, targetPixel);
        bmp.setRange(pixelStart, pixelEnd, oppositePixel);
      }
    }
  }
}

class _HorizontalFlip implements _Flip {
  @override
  Bitmap flip(Bitmap bitmap) {
    final Bitmap copy = bitmap.cloneHeadless();
    final width = bitmap.width;
    final height = bitmap.height;
    final Uint8List copyContent = copy.content;

    _horizontalFlipCore(copyContent, width, height);

    return copy;
  }

  void _horizontalFlipCore(Uint8List bmp, int width, int height) {
    const pixelLength = RGBA32BitmapHeader.pixelLength;

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
}

