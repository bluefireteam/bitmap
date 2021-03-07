import 'dart:ffi' as ffi;
import 'dart:typed_data';

import '../bitmap.dart';
import '../ffi.dart';
import 'operation.dart';

// *** FFi C++ bindings ***
const _nativeFunctionName = "brightness";

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

/// Changes brightness of [sourceBmp] accordingly to [brightnessRate] .
///
/// [brightnessRate] Can be between -1.0 and 1.0. 0.0 does nothing;
class BitmapBrightness implements BitmapOperation {
  BitmapBrightness(double brightnessFactor)
      : brightnessFactor = brightnessFactor.clamp(-1.0, 1.0);

  final double brightnessFactor;

  @override
  Bitmap applyTo(Bitmap bitmap) {
    final Bitmap copy = bitmap.cloneHeadless();
    _brightnessCore(copy.content, brightnessFactor);
    return copy;
  }

  void _brightnessCore(Uint8List sourceBmp, double brightnessRate) {
    assert(brightnessRate >= -1.0 && brightnessRate <= 1.0);

    if (brightnessRate == 0.0) {
      return;
    }

    final brightnessAmount = (brightnessRate * 255).floor();
    final size = sourceBmp.length;

    // start native execution
    FFIImpl((startingPointer, pointerList) {
      _brightnessFFIImpl(startingPointer, size, brightnessAmount);
    }).execute(sourceBmp);
  }
}
