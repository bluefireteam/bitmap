import 'dart:ffi' as ffi;
import 'dart:typed_data';

import 'package:bitmap/src/bitmap.dart';
import 'package:bitmap/src/ffi.dart';
import 'package:bitmap/src/operation/operation.dart';

// *** FFi C++ bindings ***
const _nativeFunctionName = 'adjust_color';

typedef _NativeSideFunction = ffi.Void Function(
  ffi.Pointer<ffi.Uint8>,
  ffi.Int32,
  ffi.Uint64,
  ffi.Uint64,
  ffi.Double,
  ffi.Double,
  ffi.Int32,
  ffi.Int32,
);

typedef _DartSideFunction = void Function(
  ffi.Pointer<ffi.Uint8> startingPointer,
  int bitmapLength,
  int blacks,
  int whites,
  double saturation,
  double exposure,
  int computeBlacks,
  int computeWhites,
);

_DartSideFunction _adjustColorFFIImpl = bitmapFFILib
    .lookup<ffi.NativeFunction<_NativeSideFunction>>(_nativeFunctionName)
    .asFunction();

/// Adjusts a lot of stuff of color
class BitmapAdjustColor implements BitmapOperation {
  BitmapAdjustColor({
    this.blacks,
    this.whites,
    this.exposure,
    this.saturation,
  });

  static const kDegToRad = 0.0174532925;
  static const kLumCoeffR = 0.2125;
  static const kLumCoeffG = 0.7154;
  static const kLumCoeffB = 0.0721;

  /// Enhancement factor of the dark parts of an image
  int? blacks;

  /// Enhancement factor of the light parts of an image
  int? whites;

  /// Defines the saturation to be adjusted in an image
  double? saturation;

  /// Enhancement factor of the dark parts of an image
  double? exposure;

  @override
  Bitmap applyTo(Bitmap bitmap) {
    final copy = bitmap.cloneHeadless();
    _adjustColorCore(
      copy.content,
    );
    return copy;
  }

  void _adjustColorCore(Uint8List sourceBmp) {
    if ((exposure == null || exposure == 0.0) &&
        (blacks == null || blacks == 0) &&
        (whites == null || whites == 0x00FFFFFF) &&
        saturation == null) {
      return;
    }

    final size = sourceBmp.length;

    final exposureNonNull = exposure ?? 0.0;
    final saturationNonNull = saturation ?? 1.0;

    final computeBlacks = (blacks != null && blacks != 0) ? 1 : 0;
    final computeWhites = (whites != null && whites != 0x00FFFFFF) ? 1 : 0;

    final blacksNonNull = blacks ?? 0;
    final whitesNonNull = whites ?? 0;

    // start native execution
    FFIImpl((startingPointer, pointerList) {
      _adjustColorFFIImpl(
        startingPointer,
        size,
        blacksNonNull,
        whitesNonNull,
        saturationNonNull,
        exposureNonNull,
        computeBlacks,
        computeWhites,
      );
    }).execute(sourceBmp);
  }
}
