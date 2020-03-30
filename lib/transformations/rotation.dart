import 'dart:typed_data';

import '../bitmap.dart';

Bitmap rotateClockwise(Bitmap bitmap) {
  final Bitmap rotated = Bitmap.fromHeadless(
    bitmap.height, 
    bitmap.width,
    Uint8List(bitmap.width * bitmap.height * bitmapPixelLength),
  );

  rotateClockwiseCore(
    bitmap.content,
    rotated.content,
    bitmap.width,
    bitmap.height,
  );

  return rotated;
}

void rotateClockwiseCore(
  Uint8List sourceBmp,
  Uint8List destBmp,
  int width,
  int height,
) {
  assert(width > 0 && height > 0);
  
  final int lineLength = width * bitmapPixelLength;
  for (int line = 0; line < height; line++) {
    final startOfLine = line * lineLength;
    for (int column = 0; column < width; column++) {
      final int columnStart = column * bitmapPixelLength;
      final int pixelStart = startOfLine + columnStart;
      final int pixelEnd = pixelStart + bitmapPixelLength;
      
      final int rotatedStart = 
          (height * column) * bitmapPixelLength + (height - line - 1) * bitmapPixelLength;
      final int rotatedEnd = rotatedStart + bitmapPixelLength;

      final Uint8List sourcePixel = 
          sourceBmp.sublist(pixelStart, pixelEnd);

      destBmp.setRange(rotatedStart, rotatedEnd, sourcePixel);
    }
  }
}

Bitmap rotateCounterClockwise(Bitmap bitmap) {
  final Bitmap rotated = Bitmap.fromHeadless(
    bitmap.height, 
    bitmap.width, 
    Uint8List(bitmap.width * bitmap.height * bitmapPixelLength),
  );

  rotateCounterClockwiseCore(
    bitmap.content,
    rotated.content,
    bitmap.width,
    bitmap.height,
  );

  return rotated;
}

void rotateCounterClockwiseCore(
  Uint8List sourceBmp,
  Uint8List destBmp,
  int width,
  int height,
) {
  assert(width > 0 && height > 0);
  
  final int lineLength = width * bitmapPixelLength;
  for (int line = 0; line < height; line++) {
    final startOfLine = line * lineLength;
    for (int column = 0; column < width; column++) {
      final int columnStart = column * bitmapPixelLength;
      final int pixelStart = startOfLine + columnStart;
      final int pixelEnd = pixelStart + bitmapPixelLength;
      
      final int rotatedStart = 
          (height * (width - column - 1)) * bitmapPixelLength + line * bitmapPixelLength;
      final int rotatedEnd = rotatedStart + bitmapPixelLength;

      final Uint8List sourcePixel = 
          sourceBmp.sublist(pixelStart, pixelEnd);

      destBmp.setRange(rotatedStart, rotatedEnd, sourcePixel);
    }
  }
}

Bitmap rotate180(Bitmap bitmap) {
  final Bitmap rotated = Bitmap.fromHeadless(
    bitmap.height, 
    bitmap.width,
    Uint8List(bitmap.width * bitmap.height * bitmapPixelLength),
  );

  rotate180Core(
    bitmap.content,
    rotated.content,
    bitmap.width,
    bitmap.height,
  );

  return rotated;
}

void rotate180Core(
  Uint8List sourceBmp,
  Uint8List destBmp,
  int width,
  int height,
) {
  assert(width > 0 && height > 0);
  
  final int lineLength = width * bitmapPixelLength;
  for (int line = 0; line < height; line++) {
    final startOfLine = line * lineLength;
    for (int column = 0; column < width; column++) {
      final int columnStart = column * bitmapPixelLength;
      final int pixelStart = startOfLine + columnStart;
      final int pixelEnd = pixelStart + bitmapPixelLength;
      
      final int rotatedStart = 
          width * (height - line - 1) * bitmapPixelLength + (width - column - 1) * bitmapPixelLength;
      final int rotatedEnd = rotatedStart + bitmapPixelLength;

      final Uint8List sourcePixel = 
          sourceBmp.sublist(pixelStart, pixelEnd);

      destBmp.setRange(rotatedStart, rotatedEnd, sourcePixel);
    }
  }
}