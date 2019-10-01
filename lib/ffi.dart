import 'dart:ffi' as ffi;

import 'dart:io'; // For Platform.isX

final ffi.DynamicLibrary bitmapFFILib = Platform.isAndroid
    ? ffi.DynamicLibrary.open("libbitmap.so")
    : ffi.DynamicLibrary.open("bitmap.framework/bitmap");

final int Function(int x, int y) nativeSum = bitmapFFILib
    .lookup<ffi.NativeFunction<ffi.Int32 Function(ffi.Int32, ffi.Int32)>>("sum")
    .asFunction();
