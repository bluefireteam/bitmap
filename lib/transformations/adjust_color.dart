import 'dart:math';
import 'dart:typed_data';

import '../bitmap.dart';
import 'utils/color.dart';

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
  final Bitmap copy = bitmap.copyHeadless();
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

  double br, bg, bb;
  double wr, wg, wb;

  /// prep exposure
  if (exposure != null && exposure != 0.0) {
    exposure = pow(2, exposure);
  }

  /// prep saturation
  final invSaturation = saturation != null ? 1.0 - saturation : 0.0;

  /// prep Blacks whits mids
  if ((blacks != null && blacks != 0) || whites != null) {
    br = blacks != null ? blacks / 255.0 : 0.0;
    bg = blacks != null ? blacks / 255.0 : 0.0;
    bb = blacks != null ? blacks / 255.0 : 0.0;

    wr = whites != null ? whites / 255.0 : 1.0;
    wg = whites != null ? whites / 255.0 : 1.0;
    wb = whites != null ? whites / 255.0 : 1.0;
  }
  final size = sourceBmp.length;

  for (int i = 0; i < size; i += 4) {
    double r = sourceBmp[i] / 255.0;
    double g = sourceBmp[i + 1] / 255.0;
    double b = sourceBmp[i + 2] / 255.0;

    /// blacks
    if (br != null) {
      r = (r + br) * wr;
      g = (g + bg) * wg;
      b = (b + bb) * wb;
    }

    /// saturation
    if (saturation != null) {
      final lum = r * lumCoeffR + g * lumCoeffG + b * lumCoeffB;

      r = lum * invSaturation + r * saturation;
      g = lum * invSaturation + g * saturation;
      b = lum * invSaturation + b * saturation;
    }

    /// exposure
    if (exposure != null && exposure != 0.0) {
      r = r * exposure;
      g = g * exposure;
      b = b * exposure;
    }

    sourceBmp[i] = clamp255(r * 255.0);
    sourceBmp[i + 1] = clamp255(g * 255.0);
    sourceBmp[i + 2] = clamp255(b * 255.0);
  }
}
