import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:bitmap/src/bitmap.dart';
import 'package:bitmap/src/ffi.dart';
import 'package:bitmap/src/operation/operation.dart';

// *** FFi C++ bindings ***
const _nativeFunctionName = 'rgb_overlay';

typedef _NativeSideFunction = ffi.Void Function(
  ffi.Pointer<ffi.Uint8>,
  ffi.Int32,
  ffi.Double,
  ffi.Double,
  ffi.Double,
  ffi.Double,
);

typedef _DartSideFunction = void Function(
  ffi.Pointer<ffi.Uint8> startingPointer,
  int bitmapLength,
  double red,
  double green,
  double blue,
  double scale,
);

_DartSideFunction _rgbOverlayFFIImpl = bitmapFFILib
    .lookup<ffi.NativeFunction<_NativeSideFunction>>(_nativeFunctionName)
    .asFunction();

class BitmapRgbOverlay implements BitmapOperation {
  BitmapRgbOverlay(this.red, this.green, this.blue, this.scale);

  final double red;
  final double green;
  final double blue;
  final double scale;

  @override
  Bitmap applyTo(Bitmap bitmap) {
    final copy = bitmap.cloneHeadless();
    _rgbOverlayCore(copy.content, red, green, blue, scale);
    return copy;
  }

  void _rgbOverlayCore(
    Uint8List sourceBmp,
    double red,
    double green,
    double blue,
    double scale,
  ) {
    final size = sourceBmp.length;

    // start native execution
    FFIImpl((startingPointer, pointerList) {
      _rgbOverlayFFIImpl(startingPointer, size, red, green, blue, scale);
    }).execute(sourceBmp);
  }
}
