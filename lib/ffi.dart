import 'dart:ffi' as ffi;

import 'dart:io';

import 'dart:typed_data' as typed; // For Platform.isX
import 'package:ffi/ffi.dart' as ext_ffi;

final ffi.DynamicLibrary bitmapFFILib = Platform.isAndroid
    ? ffi.DynamicLibrary.open("libbitmap.so")
    : ffi.DynamicLibrary.open("bitmap.framework/bitmap");

typedef BitmapFFIExecution = void Function(
  ffi.Pointer<ffi.Uint8> startingPointer,
  typed.Uint8List pointerList,
);

class FFIImpl {
  FFIImpl(this.ffiExecution);
  final BitmapFFIExecution ffiExecution;

  void execute(typed.Uint8List sourceBmp) {
    final ffi.Pointer<ffi.Uint8> startingPointer =
        ext_ffi.malloc<ffi.Uint8>(sourceBmp.length);
    // ignore: avoid_as

    final pointerList = startingPointer.asTypedList(sourceBmp.length);
    pointerList.setAll(0, sourceBmp);
    ffiExecution(startingPointer, pointerList);
    sourceBmp.setAll(0, pointerList);

    ext_ffi.malloc.free(startingPointer);
  }
}
