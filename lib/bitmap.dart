library bitmap;

import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

export 'transformations/adjust_color.dart';
export 'transformations/brightness.dart';
export 'transformations/contrast.dart';
export 'transformations/flip.dart';

const bitmapPixelLength = 4;

class Bitmap {
  Bitmap.fromHeadless(this.width, this.height, this.contentByteData) {
    header = BitmapHeader(size, width, height);
  }
  Bitmap.from(this.width, this.height, Uint8List contentByteData) {
    header = BitmapHeader(size, width, height)
      ..headerByteData = contentByteData;
    this.contentByteData = contentByteData.sublist(
      header.size,
      contentByteData.length,
    );
  }

  Bitmap.blank(
    this.width,
    this.height,
  ) : contentByteData = Uint8List.fromList(
          List.filled(width * height * bitmapPixelLength, 0),
        );

  final int width;
  final int height;
  Uint8List contentByteData;
  BitmapHeader header;

  int get size => (width * height) * bitmapPixelLength;

  Bitmap copyHeadless() {
    return Bitmap.fromHeadless(
      width,
      height,
      Uint8List.fromList(contentByteData),
    );
  }

  static Future<Bitmap> fromProvider(ImageProvider provider) async {
    final Completer completer = Completer<ImageInfo>();
    final ImageStream stream = provider.resolve(const ImageConfiguration());
    final listener =
        ImageStreamListener((ImageInfo info, bool synchronousCall) {
      if (!completer.isCompleted) {
        completer.complete(info);
      }
    });
    stream.addListener(listener);
    final imageInfo = await completer.future;
    final ui.Image image = imageInfo.image;
    final ByteData byteData = await image.toByteData();
    final Uint8List listInt = byteData.buffer.asUint8List();

    return Bitmap.fromHeadless(image.width, image.height, listInt);
  }

  Future<ui.Image> buildImage() async {
    final Completer<ui.Image> imageCompleter = Completer();
    ui.decodeImageFromList(withHeader, (ui.Image img) {
      imageCompleter.complete(img);
    });
    return imageCompleter.future;
  }

  Uint8List get withHeader {
    return Uint8List.fromList(header.headerByteData)
      ..setRange(
        header.size,
        header.fileLength,
        contentByteData,
      );
  }
}

///
class BitmapHeader {
  BitmapHeader(this.contentSize, int width, int height) {
    headerByteData = Uint8List(fileLength);
    _formatHeader(width, height);
  }

  static const int _headerSize = 122;
  int contentSize;
  int get size => _headerSize;

  void _formatHeader(int width, int height) {
    /// ARGB32 header
    final ByteData bd = headerByteData.buffer.asByteData();
    bd.setUint8(0x0, 0x42);
    bd.setUint8(0x1, 0x4d);
    bd.setInt32(0x2, fileLength, Endian.little);
    bd.setInt32(0xa, _headerSize, Endian.little);

    // info header
    bd.setUint32(0xe, 108, Endian.little);
    bd.setUint32(0x12, width, Endian.little);
    bd.setUint32(0x16, -height, Endian.little);
    bd.setUint16(0x1a, 1, Endian.little);
    bd.setUint32(0x1c, 32, Endian.little); // pixel size
    bd.setUint32(0x1e, 3, Endian.little); //BI_BITFIELDS
    bd.setUint32(0x22, contentSize, Endian.little);
    bd.setUint32(0x36, 0x000000ff, Endian.little);
    bd.setUint32(0x3a, 0x0000ff00, Endian.little);
    bd.setUint32(0x3e, 0x00ff0000, Endian.little);
    bd.setUint32(0x42, 0xff000000, Endian.little);
  }

  Uint8List headerByteData;

  int get fileLength => contentSize + size;
}
