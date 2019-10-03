import 'dart:ffi' as ffi;

import '../bitmap.dart';
import '../ffi.dart';

Bitmap contrast(Bitmap bitmap, double contrastRate) {
  assert(contrastRate >= 0.0);
  final Bitmap copy = bitmap.cloneHeadless();
  final size = copy.content.length;
  FFIImpl((startingPointer, pointerList){
    _contrastFFIImpl(startingPointer, size, contrastRate);
  })..execute(copy.content);
  return copy;
}

// *** FFi C++ bindings ***
const _nativeFunctionName = "contrast";

typedef _NativeSideFunction = ffi.Pointer<ffi.Uint8> Function(
    ffi.Pointer<ffi.Uint8>,
    ffi.Int32,
    ffi.Double,
);

typedef _DartSideFunction = ffi.Pointer<ffi.Uint8> Function(
    ffi.Pointer<ffi.Uint8> startingPointer,
    int bitmapLength,
    double contrastRate,
);

_DartSideFunction _contrastFFIImpl = bitmapFFILib
    .lookup<ffi.NativeFunction<_NativeSideFunction>>(_nativeFunctionName)
    .asFunction();