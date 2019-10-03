import 'dart:ffi' as ffi;
import 'dart:typed_data';

import '../bitmap.dart';
import '../ffi.dart';

/// Changes brightness of [sourceBmp] accordingly to [brightnessRate] .
///
/// [brightnessRate] Can be between -1.0 and 1.0. 0.0 does nothing;
Bitmap brightness(Bitmap bitmap, double brightnessRate) {
  final Bitmap copy = bitmap.cloneHeadless();
  brightnessCore(copy.content, brightnessRate);
  return copy;
}

void brightnessCore(Uint8List sourceBmp, double brightnessRate) {
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
