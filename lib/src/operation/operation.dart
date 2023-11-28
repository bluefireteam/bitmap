import 'package:bitmap/src/bitmap.dart';

export 'adjust_color.dart';
export 'brightness.dart';
export 'contrast.dart';
export 'crop.dart';
export 'flip.dart';
export 'resize.dart';
export 'rgb_overlay.dart';
export 'rotation.dart';

abstract interface class BitmapOperation {
  Bitmap applyTo(Bitmap bitmap);
}
