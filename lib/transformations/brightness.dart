import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:bitmap/ffi.dart';

import '../bitmap.dart';

/// Changes brightness of [sourceBmp] accordingly to [brightnessRate] .
///
/// [brightnessRate] Can be between -1.0 and 1.0. 0.0 does nothing;
Bitmap brightness(Bitmap bitmap, double brightnessRate) {
  final Bitmap copy = bitmap.cloneHeadless();
  _brightnessCore(copy.content, brightnessRate);
  return copy;
}

void _brightnessCore(Uint8List sourceBmp, double brightnessRate) {
  assert(brightnessRate >= -1.0 && brightnessRate <= 1.0);
  assert(sourceBmp != null);

  if (brightnessRate == 0.0) {
    return;
  }

  final brightnessAmount = (brightnessRate * 255).floor();
  final size = sourceBmp.length;

  // start native execution
  FFIImpl((startingPointer, pointerList) {
    _brightnessFFIImpl(startingPointer, size, brightnessAmount);
  })
    ..execute(sourceBmp);
}

// *** FFi C++ bindings ***
const _nativeFunctionName = "brightness";

typedef _BrightnessFunction = ffi.Pointer<ffi.Uint8> Function(
  ffi.Pointer<ffi.Uint8> startingPointer,
  int bitmapLength,
  int brightnessAmount,
);

typedef _BrightnessNative = ffi.Pointer<ffi.Uint8> Function(
  ffi.Pointer<ffi.Uint8>,
  ffi.Int32,
  ffi.Int32,
);

_BrightnessFunction _brightnessFFIImpl = bitmapFFILib
    .lookup<ffi.NativeFunction<_BrightnessNative>>(_nativeFunctionName)
    .asFunction();
