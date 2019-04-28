library bitmap;

import 'dart:typed_data';

import 'package:bitmap/flip.dart';
import 'package:bitmap/resize.dart';

class Bitmap {
  Bitmap(this.width, this.height, this.contentByteData, {this.pixelLength = 4});

  final int pixelLength;
  final int width;
  final int height;
  final Uint8List contentByteData;

  int get size => (width * height) * pixelLength;

  Bitmap copy() {
    return Bitmap(width, height, Uint8List.fromList(contentByteData),
        pixelLength: pixelLength);
  }

  Future<Bitmap> flipVertical() async {
    final Bitmap copy = this.copy();
    final Uint8List copyContent = copy.contentByteData;

    verticalFlip(copyContent, width, height, pixelLength);

    return copy;
  }

  Future<Bitmap> flipHorizontal() async {
    final Bitmap copy = this.copy();
    final Uint8List copyContent = copy.contentByteData;

    horizontalFlip(copyContent, width, height, pixelLength);

    return copy;
  }

  Future<Bitmap> resize(int resizeWidth, int resizeHeight) async {
    final int newBitmapSize = (resizeWidth * resizeHeight) * pixelLength;

    final Bitmap resized = Bitmap(
        resizeWidth, resizeHeight, Uint8List(newBitmapSize),
        pixelLength: pixelLength);

    resizeBitmap(contentByteData, resized.contentByteData, pixelLength, width,
        height, resizeWidth, resizeHeight);

    return resized;
  }

  Future<Bitmap> resizeHeight(int resizeHeight) async {
    final int resizeWidth = (resizeHeight * (width / height)).toInt();
    return resize(resizeWidth, resizeHeight);
  }

  Future<Bitmap> resizeWidth(int resizeWidth) async {
    final int resizeHeight = (resizeWidth * (height / width)).toInt();

    return resize(resizeWidth, resizeHeight);
  }
}
