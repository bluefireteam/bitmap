import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';

import 'operation/operation.dart';

class Bitmap {
  Bitmap.fromHeadless(this.width, this.height, this.content);

  Bitmap.fromHeadful(this.width, this.height, Uint8List headedIntList)
      : content = headedIntList.sublist(
          RGBA32BitmapHeader.RGBA32HeaderSize,
          headedIntList.length,
        );

  Bitmap.blank(
    this.width,
    this.height,
  ) : content = Uint8List.fromList(
          List.filled(width * height * RGBA32BitmapHeader.pixelLength, 0),
        );

  /// The width in pixels of the image.
  final int width;

  /// The width in pixels of the image.
  final int height;

  /// A [Uint8List] of bytes in a RGBA format.
  final Uint8List content;

  int get size => (width * height) * RGBA32BitmapHeader.pixelLength;

  // Creates a new instance of bitmap
  Bitmap cloneHeadless() {
    return Bitmap.fromHeadless(
      width,
      height,
      Uint8List.fromList(content),
    );
  }

  static Future<Bitmap> fromProvider(ImageProvider provider) async {
    final Completer completer = Completer<ImageInfo>();
    final stream = provider.resolve(const ImageConfiguration());
    final listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        if (!completer.isCompleted) {
          completer.complete(info);
        }
      },
    );
    stream.addListener(listener);
    final imageInfo = await completer.future;
    final ui.Image image = imageInfo.image;
    final byteData = await image.toByteData();
    if (byteData == null) {
      throw StateError("Couldn't serialize image into bytes");
    }

    final listInt = byteData.buffer.asUint8List();

    return Bitmap.fromHeadless(image.width, image.height, listInt);
  }

  Future<ui.Image> buildImage() async {
    final imageCompleter = Completer<ui.Image>();
    final headedContent = buildHeaded();
    ui.decodeImageFromList(headedContent, (ui.Image img) {
      imageCompleter.complete(img);
    });
    return imageCompleter.future;
  }

  Uint8List buildHeaded() {
    final header = RGBA32BitmapHeader(size, width, height)
      ..applyContent(content);
    return header.headerIntList;
  }

  Bitmap apply(BitmapOperation operation) {
    return operation.applyTo(this);
  }

  Bitmap applyBatch(List<BitmapOperation> operations) {
    var result = this;
    for (final operation in operations) {
      result = operation.applyTo(result);
    }
    return result;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Bitmap &&
          runtimeType == other.runtimeType &&
          width == other.width &&
          height == other.height &&
          content == other.content;

  @override
  int get hashCode => width.hashCode ^ height.hashCode ^ content.hashCode;
}

class RGBA32BitmapHeader {
  static const int pixelLength = 4;
  static const int RGBA32HeaderSize = 122;

  RGBA32BitmapHeader(this.contentSize, int width, int height) {
    headerIntList = Uint8List(fileLength);

    final bd = headerIntList.buffer.asByteData();
    bd.setUint8(0x0, 0x42);
    bd.setUint8(0x1, 0x4d);
    bd.setInt32(0x2, fileLength, Endian.little);
    bd.setInt32(0xa, RGBA32HeaderSize, Endian.little);
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

  int contentSize;

  void applyContent(Uint8List contentIntList) {
    headerIntList.setRange(
      RGBA32HeaderSize,
      fileLength,
      contentIntList,
    );
  }

  late Uint8List headerIntList;

  int get fileLength => contentSize + RGBA32HeaderSize;
}
