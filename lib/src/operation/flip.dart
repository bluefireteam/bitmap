import 'dart:typed_data';
import 'package:bitmap/src/bitmap.dart';
import 'package:bitmap/src/operation/operation.dart';

class BitmapFlip implements BitmapOperation {
  BitmapFlip.vertical() : _flip = _VerticalFlip();

  BitmapFlip.horizontal() : _flip = _HorizontalFlip();
  final _Flip _flip;

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
    final copy = bitmap.cloneHeadless();
    final width = bitmap.width;
    final height = bitmap.height;
    final copyContent = copy.content;

    _verticalFlipCore(copyContent, width, height);

    return copy;
  }

  void _verticalFlipCore(Uint8List bmp, int width, int height) {
    const pixelLength = RGBA32BitmapHeader.kPixelLength;

    final lineLength = width * pixelLength;
    final halfHeight = height ~/ 2;

    for (var line = 0; line < halfHeight; line++) {
      final startOfLine = line * lineLength;
      final startOfOppositeLine = (height - 1 - line) * lineLength;
      for (var column = 0; column < width; column++) {
        final pixelStart = startOfLine + column * pixelLength;
        final pixelEnd = pixelStart + pixelLength;

        final oppositePixelStart = startOfOppositeLine + column * pixelLength;
        final oppositePixelEnd = oppositePixelStart + pixelLength;

        final oppositePixel = bmp.sublist(
          oppositePixelStart,
          oppositePixelEnd,
        );
        final targetPixel = bmp.sublist(pixelStart, pixelEnd);

        bmp
          ..setRange(oppositePixelStart, oppositePixelEnd, targetPixel)
          ..setRange(pixelStart, pixelEnd, oppositePixel);
      }
    }
  }
}

class _HorizontalFlip implements _Flip {
  @override
  Bitmap flip(Bitmap bitmap) {
    final copy = bitmap.cloneHeadless();
    final width = bitmap.width;
    final height = bitmap.height;
    final copyContent = copy.content;

    _horizontalFlipCore(copyContent, width, height);

    return copy;
  }

  void _horizontalFlipCore(Uint8List bmp, int width, int height) {
    const pixelLength = RGBA32BitmapHeader.kPixelLength;

    final lineLength = width * pixelLength;
    final halfLine = lineLength ~/ 2;

    for (var line = 0; line < height; line++) {
      final startOfLine = line * lineLength;
      for (var relativeColumnStart = 0;
          relativeColumnStart < halfLine;
          relativeColumnStart += pixelLength) {
        final pixelStart = startOfLine + relativeColumnStart;
        final pixelEnd = pixelStart + pixelLength;

        final relativeOppositePixelStart =
            lineLength - relativeColumnStart - pixelLength;
        final oppositePixelStart = startOfLine + relativeOppositePixelStart;
        final oppositePixelEnd = oppositePixelStart + pixelLength;

        final oppositePixel = bmp.sublist(
          oppositePixelStart,
          oppositePixelEnd,
        );
        final targetPixel = bmp.sublist(pixelStart, pixelEnd);

        bmp
          ..setRange(oppositePixelStart, oppositePixelEnd, targetPixel)
          ..setRange(pixelStart, pixelEnd, oppositePixel);
      }
    }
  }
}
