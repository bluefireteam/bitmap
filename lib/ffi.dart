import 'dart:ffi' as ffi;

import 'dart:io';

import 'dart:typed_data' as typed; // For Platform.isX

final ffi.DynamicLibrary bitmapFFILib = Platform.isAndroid
    ? ffi.DynamicLibrary.open("libbitmap.so")
    : ffi.DynamicLibrary.open("bitmap.framework/bitmap");

final int Function(int x, int y) nativeSum = bitmapFFILib
    .lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Int32, ffi.Int32)>>("sum")
    .asFunction();


ffi.Pointer<ffi.Uint8> prepareFFI(typed.Uint8List sourceBmp) {
  ffi.Pointer<ffi.Uint8> startingPointer= ffi.Pointer<ffi.Uint8>
      .allocate(count: sourceBmp.length);
  for (int i = 0; i < sourceBmp.length; i++) {
    startingPointer.elementAt(i).store(sourceBmp[i]);
  }
  return startingPointer;
}

final ffi.Pointer<ffi.Uint8> Function(
    ffi.Pointer<ffi.Uint8> startingPointer,
    int bitmapLength,
    double brightnessAmount,
    ) brightnessFFIImpl = bitmapFFILib.lookup<ffi.NativeFunction<ffi.Pointer<ffi.Uint8> Function(ffi.Pointer<ffi.Uint8>, ffi.Int32, ffi.Double,)>>("brightness").asFunction();

