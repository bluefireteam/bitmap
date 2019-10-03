import 'dart:ffi' as ffi;
import 'dart:typed_data';

import '../bitmap.dart';
import '../ffi.dart';

Bitmap contrast(Bitmap bitmap, double contrastRate) {
  assert(contrastRate >= 0.0);
  final Bitmap copy = bitmap.cloneHeadless();
  contrastCore(copy.content, contrastRate);
  return copy;
}

void contrastCore(Uint8List sourceBmp, double contrastRate) {
  assert(contrastRate >= 0.0);
  assert(sourceBmp != null);
  final size = sourceBmp.length;
  FFIImpl((startingPointer, pointerList) {
    _contrastFFIImpl(startingPointer, size, contrastRate);
  })
    ..execute(sourceBmp);
}

// *** FFi C++ bindings ***
const _nativeFunctionName = "contrast";

typedef _NativeSideFunction = ffi.Void Function(
  ffi.Pointer<ffi.Uint8>,
  ffi.Int32,
  ffi.Double,
);

typedef _DartSideFunction = void Function(
  ffi.Pointer<ffi.Uint8> startingPointer,
  int bitmapLength,
  double contrastRate,
);

_DartSideFunction _contrastFFIImpl = bitmapFFILib
    .lookup<ffi.NativeFunction<_NativeSideFunction>>(_nativeFunctionName)
    .asFunction();
