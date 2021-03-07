import 'dart:typed_data';

import '../bitmap.dart';
import 'operation.dart';

class BitmapRotate implements BitmapOperation {
  final _Rotate _rotate;

  BitmapRotate.rotateClockwise() : _rotate = _RotateClockwise();

  BitmapRotate.rotate180() : _rotate = _Rotate180();

  BitmapRotate.rotateCounterClockwise() : _rotate = _RotateCounterClockwise();

  @override
  Bitmap applyTo(Bitmap bitmap) {
    return _rotate.doRotate(bitmap);
  }
}

abstract class _Rotate {
  Bitmap doRotate(Bitmap bitmap);
}

class _RotateClockwise implements _Rotate {
  @override
  Bitmap doRotate(Bitmap bitmap) {
    final Bitmap rotated = Bitmap.fromHeadless(
      bitmap.height,
      bitmap.width,
      Uint8List(bitmap.width * bitmap.height * RGBA32BitmapHeader.pixelLength),
    );

    _rotateClockwiseCore(
      bitmap.content,
      rotated.content,
      bitmap.width,
      bitmap.height,
    );

    return rotated;
  }

  void _rotateClockwiseCore(
    Uint8List sourceBmp,
    Uint8List destBmp,
    int width,
    int height,
  ) {
    assert(width > 0 && height > 0);

    const pixelLength = RGBA32BitmapHeader.pixelLength;

    final int lineLength = width * pixelLength;
    for (int line = 0; line < height; line++) {
      final startOfLine = line * lineLength;
      for (int column = 0; column < width; column++) {
        final int columnStart = column * pixelLength;
        final int pixelStart = startOfLine + columnStart;
        final int pixelEnd = pixelStart + pixelLength;

        final int rotatedStart =
            (height * column) * pixelLength + (height - line - 1) * pixelLength;
        final int rotatedEnd = rotatedStart + pixelLength;

        final Uint8List sourcePixel = sourceBmp.sublist(pixelStart, pixelEnd);

        destBmp.setRange(rotatedStart, rotatedEnd, sourcePixel);
      }
    }
  }
}

class _RotateCounterClockwise implements _Rotate {
  @override
  Bitmap doRotate(Bitmap bitmap) {
    final Bitmap rotated = Bitmap.fromHeadless(
      bitmap.height,
      bitmap.width,
      Uint8List(bitmap.width * bitmap.height * RGBA32BitmapHeader.pixelLength),
    );

    _rotateCounterClockwiseCore(
      bitmap.content,
      rotated.content,
      bitmap.width,
      bitmap.height,
    );

    return rotated;
  }

  void _rotateCounterClockwiseCore(
    Uint8List sourceBmp,
    Uint8List destBmp,
    int width,
    int height,
  ) {
    assert(width > 0 && height > 0);
    const pixelLength = RGBA32BitmapHeader.pixelLength;

    final int lineLength = width * pixelLength;
    for (int line = 0; line < height; line++) {
      final startOfLine = line * lineLength;
      for (int column = 0; column < width; column++) {
        final int columnStart = column * pixelLength;
        final int pixelStart = startOfLine + columnStart;
        final int pixelEnd = pixelStart + pixelLength;

        final int rotatedStart =
            (height * (width - column - 1)) * pixelLength + line * pixelLength;
        final int rotatedEnd = rotatedStart + pixelLength;

        final Uint8List sourcePixel = sourceBmp.sublist(pixelStart, pixelEnd);

        destBmp.setRange(rotatedStart, rotatedEnd, sourcePixel);
      }
    }
  }
}

class _Rotate180 implements _Rotate {
  @override
  Bitmap doRotate(Bitmap bitmap) {
    final Bitmap rotated = Bitmap.fromHeadless(
      bitmap.height,
      bitmap.width,
      Uint8List(bitmap.width * bitmap.height * RGBA32BitmapHeader.pixelLength),
    );

    _rotate180Core(
      bitmap.content,
      rotated.content,
      bitmap.width,
      bitmap.height,
    );

    return rotated;
  }

  void _rotate180Core(
    Uint8List sourceBmp,
    Uint8List destBmp,
    int width,
    int height,
  ) {
    assert(width > 0 && height > 0);
    const pixelLength = RGBA32BitmapHeader.pixelLength;

    final int lineLength = width * pixelLength;
    for (int line = 0; line < height; line++) {
      final startOfLine = line * lineLength;
      for (int column = 0; column < width; column++) {
        final int columnStart = column * pixelLength;
        final int pixelStart = startOfLine + columnStart;
        final int pixelEnd = pixelStart + pixelLength;

        final int rotatedStart = width * (height - line - 1) * pixelLength +
            (width - column - 1) * pixelLength;
        final int rotatedEnd = rotatedStart + pixelLength;

        final Uint8List sourcePixel = sourceBmp.sublist(pixelStart, pixelEnd);

        destBmp.setRange(rotatedStart, rotatedEnd, sourcePixel);
      }
    }
  }
}
