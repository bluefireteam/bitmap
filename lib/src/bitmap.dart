import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:bitmap/src/operation/operation.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter/rendering.dart';

class Bitmap extends Equatable {
  const Bitmap.fromHeadless(this.width, this.height, this.content);

  Bitmap.fromHeadful(this.width, this.height, Uint8List headedIntList)
      : content = headedIntList.sublist(
          RGBA32BitmapHeader.kRGBA32HeaderSize,
          headedIntList.length,
        );

  Bitmap.blank(
    this.width,
    this.height,
  ) : content = Uint8List.fromList(
          List.filled(width * height * RGBA32BitmapHeader.kPixelLength, 0),
        );

  /// The width in pixels of the image.
  final int width;

  /// The width in pixels of the image.
  final int height;

  /// A [Uint8List] of bytes in a RGBA format.
  final Uint8List content;

  int get size => (width * height) * RGBA32BitmapHeader.kPixelLength;

  // Creates a new instance of bitmap
  Bitmap cloneHeadless() {
    return Bitmap.fromHeadless(
      width,
      height,
      Uint8List.fromList(content),
    );
  }

  static Future<Bitmap> fromProvider(ImageProvider provider) async {
    final completer = Completer<ImageInfo>();
    final stream = provider.resolve(ImageConfiguration.empty);
    final listener = ImageStreamListener(
      (ImageInfo info, bool synchronousCall) {
        if (!completer.isCompleted) {
          completer.complete(info);
        }
      },
    );
    stream.addListener(listener);
    final imageInfo = await completer.future;
    final image = imageInfo.image;
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
    ui.decodeImageFromList(headedContent, imageCompleter.complete);
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
  List<Object?> get props => [width, height, content];
}

class RGBA32BitmapHeader {
  RGBA32BitmapHeader(this.contentSize, int width, int height) {
    headerIntList = Uint8List(fileLength);

    headerIntList.buffer.asByteData()
      ..setUint8(0x0, 0x42)
      ..setUint8(0x1, 0x4d)
      ..setInt32(0x2, fileLength, Endian.little)
      ..setInt32(0xa, kRGBA32HeaderSize, Endian.little)
      ..setUint32(0xe, 108, Endian.little)
      ..setUint32(0x12, width, Endian.little)
      ..setUint32(0x16, -height, Endian.little)
      ..setUint16(0x1a, 1, Endian.little)
      ..setUint32(0x1c, 32, Endian.little) // pixel size
      ..setUint32(0x1e, 3, Endian.little) //BI_BITFIELDS
      ..setUint32(0x22, contentSize, Endian.little)
      ..setUint32(0x36, 0x000000ff, Endian.little)
      ..setUint32(0x3a, 0x0000ff00, Endian.little)
      ..setUint32(0x3e, 0x00ff0000, Endian.little)
      ..setUint32(0x42, 0xff000000, Endian.little);
  }
  static const int kPixelLength = 4;
  static const int kRGBA32HeaderSize = 122;

  int contentSize;

  void applyContent(Uint8List contentIntList) {
    headerIntList.setRange(
      kRGBA32HeaderSize,
      fileLength,
      contentIntList,
    );
  }

  late Uint8List headerIntList;

  int get fileLength => contentSize + kRGBA32HeaderSize;
}
