import 'dart:ffi' as ffi;
import 'dart:typed_data';

import '../bitmap.dart';
import '../ffi.dart';

const DEG_TO_RAD = 0.0174532925;

const lumCoeffR = 0.2125;
const lumCoeffG = 0.7154;
const lumCoeffB = 0.0721;

Bitmap adjustColor(
  Bitmap bitmap, {
  int blacks,
  int whites,
  double saturation,
  double exposure,
}) {
  final Bitmap copy = bitmap.cloneHeadless();
  adjustColorCore(
    copy.content,
    blacks: blacks,
    whites: whites,
    saturation: saturation,
    exposure: exposure,
  );
  return copy;
}

/// Adjusts a lot of stuff of color
void adjustColorCore(
  Uint8List sourceBmp, {
  int blacks,
  int whites,
  double saturation,
  double exposure,
}) {
  if ((exposure == null || exposure == 0.0) &&
      (blacks == null || blacks == 0) &&
      (whites == null || whites == 0x00FFFFFF) &&
      saturation == null) {
    return;
  }

  final size = sourceBmp.length;

  exposure = exposure ?? 0.0;
  saturation = saturation ?? 1.0;

  final computeBlacks = (blacks != null && blacks != 0) ? 1 : 0;
  final computeWhites = (whites != null && whites != 0x00FFFFFF) ? 1 : 0;

  // start native execution
  FFIImpl((startingPointer, pointerList) {
    _adjustColorFFIImpl(
      startingPointer,
      size,
      blacks,
      whites,
      saturation,
      exposure,
      computeBlacks,
      computeWhites,
    );
  })
    ..execute(sourceBmp);
}

// *** FFi C++ bindings ***
const _nativeFunctionName = "adjust_color";

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
