library bitmap;

import 'dart:typed_data';

import 'package:bitmap/flip.dart';
import 'package:bitmap/resize.dart';
import 'package:bitmap/filters.dart';

class Bitmap {
  Bitmap(this.width, this.height, this.contentByteData, {this.pixelLength = 4});

  Bitmap.blank(this.width, this.height, {this.pixelLength = 4})
      : contentByteData =
            Uint8List.fromList(List.filled(width * height * pixelLength, 0));

  final int pixelLength;
  final int width;
  final int height;
  final Uint8List contentByteData;

  int get size => (width * height) * pixelLength;

  Bitmap copy() {
    return Bitmap(width, height, Uint8List.fromList(contentByteData),
        pixelLength: pixelLength);
  }

  Bitmap shallowCopy([Uint8List contentByteData]) {
    final _contentByteData = contentByteData ?? this.contentByteData;
    return Bitmap(width, height, _contentByteData, pixelLength: pixelLength);
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

  Future<Bitmap> setContrast(double contrastRate) async {
    final Bitmap copy = this.copy();
    setContrastFunction(copy.contentByteData, contrastRate);

    return copy;
  }

  Future<Bitmap> setBrightness(double brightnessRate) async {
    final Bitmap copy = this.copy();
    setBrightnessFunction(copy.contentByteData, brightnessRate);
    return copy;
  }

  Future<Bitmap> adjustColor({
    int blacks,
    int whites,
    double saturation,
    double exposure,
  }) async {
    final Bitmap copy = this.copy();
    adjustColorFunction(
      copy.contentByteData,
      blacks: blacks,
      whites: whites,
      saturation: saturation,
      exposure: exposure,
    );
    return copy;
  }
}

class BitmapFile {
  BitmapFile(this._content) {
    _headerByteData = Uint8List(fileLength);
    _formateHeader();
  }

  BitmapFile.fromIntListWithHeader(int width, int height, Uint8List content) {
    _headerByteData = content;
    _content =
        Bitmap(width, height, content.sublist(_headerSize, content.length));
  }

  void _formateHeader() {
    /// ARGB32 header
    final ByteData bd = headerByteData.buffer.asByteData();
    bd.setUint8(0x0, 0x42);
    bd.setUint8(0x1, 0x4d);
    bd.setInt32(0x2, fileLength, Endian.little);
    bd.setInt32(0xa, _headerSize, Endian.little);

    // info header
    bd.setUint32(0xe, 108, Endian.little);
    bd.setUint32(0x12, content.width, Endian.little);
    bd.setUint32(0x16, -content.height, Endian.little);
    bd.setUint16(0x1a, 1, Endian.little);
    bd.setUint32(0x1c, 32, Endian.little); // pixel size
    bd.setUint32(0x1e, 3, Endian.little); //BI_BITFIELDS
    bd.setUint32(0x22, content.size, Endian.little);
    bd.setUint32(0x36, 0x000000ff, Endian.little);
    bd.setUint32(0x3a, 0x0000ff00, Endian.little);
    bd.setUint32(0x3e, 0x00ff0000, Endian.little);
    bd.setUint32(0x42, 0xff000000, Endian.little);
  }

  static const int _headerSize = 122;

  Uint8List _headerByteData;
  Bitmap _content;

  set contentByteData(Uint8List contentByteData) {
    assert(contentByteData.length == content.size);
    _content = Bitmap(content.width, content.height, contentByteData,
        pixelLength: content.pixelLength);
  }

  Uint8List get headerByteData => _headerByteData;
  int get fileLength => _headerSize + _content.size;
  Bitmap get content => _content;

  Uint8List get bitmapWithHeader {
    return Uint8List.fromList(_headerByteData)
      ..setRange(_headerSize, fileLength, content.contentByteData);
  }
}
