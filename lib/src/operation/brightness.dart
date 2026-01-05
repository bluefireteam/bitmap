import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:bitmap/src/bitmap.dart';
import 'package:bitmap/src/ffi.dart';
import 'package:bitmap/src/operation/operation.dart';

// *** FFi C++ bindings ***
const _nativeFunctionName = 'brightness';

typedef _NativeSideFunction = ffi.Void Function(
  ffi.Pointer<ffi.Uint8>,
  ffi.Int32,
  ffi.Int32,
);

typedef _DartSideFunction = void Function(
  ffi.Pointer<ffi.Uint8> startingPointer,
  int bitmapLength,
  int brightnessAmount,
);

_DartSideFunction _brightnessFFIImpl = bitmapFFILib
    .lookup<ffi.NativeFunction<_NativeSideFunction>>(_nativeFunctionName)
    .asFunction();

/// Changes brightness of a [Bitmap] accordingly to [brightnessFactor] .
///
/// [brightnessFactor] Can be between -1.0 and 1.0. 0.0 does nothing;
class BitmapBrightness implements BitmapOperation {
  BitmapBrightness(double brightnessFactor)
      : brightnessFactor = brightnessFactor.clamp(-1.0, 1.0);

  final double brightnessFactor;

  @override
  Bitmap applyTo(Bitmap bitmap) {
    final copy = bitmap.cloneHeadless();
    _brightnessCore(copy.content, brightnessFactor);
    return copy;
  }

  void _brightnessCore(Uint8List sourceBmp, double brightnessFactor) {
    assert(
      brightnessFactor >= -1.0 && brightnessFactor <= 1.0,
      'brightnessFactor must be between -1.0 and 1.0, it is $brightnessFactor',
    );

    if (brightnessFactor == 0.0) {
      return;
    }

    final brightnessAmount = (brightnessFactor * 255).floor();
    final size = sourceBmp.length;

    // start native execution
    FFIImpl((startingPointer, pointerList) {
      _brightnessFFIImpl(startingPointer, size, brightnessAmount);
    }).execute(sourceBmp);
  }
}
