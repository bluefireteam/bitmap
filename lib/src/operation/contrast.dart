import 'dart:ffi' as ffi;
import 'dart:typed_data';

import '../bitmap.dart';
import '../ffi.dart';
import 'operation.dart';

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

/// Sets a contrast of in image given [contrastFactor].
class BitmapContrast implements BitmapOperation {
  BitmapContrast(this.contrastFactor) : assert(contrastFactor >= 0.0);

  double contrastFactor;

  @override
  Bitmap applyTo(Bitmap bitmap) {
    final Bitmap copy = bitmap.cloneHeadless();
    _contrastCore(copy.content, contrastFactor);
    return copy;
  }

  void _contrastCore(Uint8List sourceBmp, double contrastRate) {
    assert(contrastRate >= 0.0);
    final size = sourceBmp.length;
    FFIImpl((startingPointer, pointerList) {
      _contrastFFIImpl(startingPointer, size, contrastRate);
    }).execute(sourceBmp);
  }
}
