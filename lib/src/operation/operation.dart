import '../bitmap.dart';

export 'adjust_color.dart';
export 'brightness.dart';
export 'contrast.dart';
export 'crop.dart';
export 'flip.dart';
export 'resize.dart';
export 'rotation.dart';

abstract class BitmapOperation {
  Bitmap applyTo(Bitmap bitmap);
}
