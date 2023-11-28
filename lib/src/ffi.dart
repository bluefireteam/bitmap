import 'dart:ffi' as ffi;

import 'dart:io';

import 'dart:typed_data' as typed; // For Platform.isX
import 'package:ffi/ffi.dart' as ext_ffi;

final ffi.DynamicLibrary bitmapFFILib = Platform.isAndroid
    ? ffi.DynamicLibrary.open('libbitmap.so')
    : ffi.DynamicLibrary.process();

typedef BitmapFFIExecution = void Function(
  ffi.Pointer<ffi.Uint8> startingPointer,
  typed.Uint8List pointerList,
);

class FFIImpl {
  FFIImpl(this.ffiExecution);

  final BitmapFFIExecution ffiExecution;

  void execute(typed.Uint8List sourceBmp) {
    final startingPointer = ext_ffi.calloc<ffi.Uint8>(
      sourceBmp.length,
    );
    final pointerList = startingPointer.asTypedList(sourceBmp.length)
      ..setAll(0, sourceBmp);
    ffiExecution(startingPointer, pointerList);
    sourceBmp.setAll(0, pointerList);

    ext_ffi.calloc.free(startingPointer);
  }
}
