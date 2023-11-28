import 'dart:typed_data';

import 'package:bitmap/src/bitmap.dart';
import 'package:bitmap/src/operation/operation.dart';

/// A [BitmapOperation] which rotates a [Bitmap].
class BitmapRotate implements BitmapOperation {
  /// Creates a [BitmapRotate] which rotates a [Bitmap] clockwise.
  BitmapRotate.rotateClockwise() : _rotate = _RotateClockwise();

  /// Creates a [BitmapRotate] which rotates a [Bitmap] 180 degrees.
  BitmapRotate.rotate180() : _rotate = _Rotate180();

  /// Creates a [BitmapRotate] which rotates a [Bitmap] counter-clockwise.
  BitmapRotate.rotateCounterClockwise() : _rotate = _RotateCounterClockwise();

  final _Rotate _rotate;

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
    final rotated = Bitmap.fromHeadless(
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

    final lineLength = width * pixelLength;
    for (var line = 0; line < height; line++) {
      final startOfLine = line * lineLength;
      for (var column = 0; column < width; column++) {
        final columnStart = column * pixelLength;
        final pixelStart = startOfLine + columnStart;
        final pixelEnd = pixelStart + pixelLength;

        final rotatedStart =
            (height * column) * pixelLength + (height - line - 1) * pixelLength;
        final rotatedEnd = rotatedStart + pixelLength;

        final sourcePixel = sourceBmp.sublist(pixelStart, pixelEnd);

        destBmp.setRange(rotatedStart, rotatedEnd, sourcePixel);
      }
    }
  }
}

class _RotateCounterClockwise implements _Rotate {
  @override
  Bitmap doRotate(Bitmap bitmap) {
    final rotated = Bitmap.fromHeadless(
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

    final lineLength = width * pixelLength;
    for (var line = 0; line < height; line++) {
      final startOfLine = line * lineLength;
      for (var column = 0; column < width; column++) {
        final columnStart = column * pixelLength;
        final pixelStart = startOfLine + columnStart;
        final pixelEnd = pixelStart + pixelLength;

        final rotatedStart =
            (height * (width - column - 1)) * pixelLength + line * pixelLength;
        final rotatedEnd = rotatedStart + pixelLength;

        final sourcePixel = sourceBmp.sublist(pixelStart, pixelEnd);

        destBmp.setRange(rotatedStart, rotatedEnd, sourcePixel);
      }
    }
  }
}

class _Rotate180 implements _Rotate {
  @override
  Bitmap doRotate(Bitmap bitmap) {
    final rotated = Bitmap.fromHeadless(
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

    final lineLength = width * pixelLength;
    for (var line = 0; line < height; line++) {
      final startOfLine = line * lineLength;
      for (var column = 0; column < width; column++) {
        final columnStart = column * pixelLength;
        final pixelStart = startOfLine + columnStart;
        final pixelEnd = pixelStart + pixelLength;

        final rotatedStart = width * (height - line - 1) * pixelLength +
            (width - column - 1) * pixelLength;
        final rotatedEnd = rotatedStart + pixelLength;

        final sourcePixel = sourceBmp.sublist(pixelStart, pixelEnd);

        destBmp.setRange(rotatedStart, rotatedEnd, sourcePixel);
      }
    }
  }
}
