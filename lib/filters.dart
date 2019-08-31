import 'dart:math';
import 'dart:typed_data';

import 'color.dart';

/// This file: rip off of https://github.com/brendan-duncan/image/blob/master/lib/src/filter
/// All credits to Brendan Duncan: https://github.com/brendan-duncan/image

void setContrastFunction(Uint8List sourceBmp, double contrastRate) {
  assert(contrastRate >= 0.0);
  assert(sourceBmp != null);

  final double contrastSquare = contrastRate * contrastRate;
  final Uint8List contrastApplier = Uint8List(256);
  for (int i = 0; i < 256; ++i) {
    contrastApplier[i] =
        ((((((i / 255.0) - 0.5) * contrastSquare) + 0.5) * 255.0).toInt())
            .clamp(0, 255)
            .toInt();
  }
  final size = sourceBmp.length;
  for (int i = 0; i < size; i += 4) {
    sourceBmp[i] = contrastApplier[sourceBmp[i]];
    sourceBmp[i + 1] = contrastApplier[sourceBmp[i + 1]];
    sourceBmp[i + 2] = contrastApplier[sourceBmp[i + 2]];
  }
}

/// Changes brightness of [sourceBmp] accordingly to [brightnessRate] .
///
/// [brightnessRate] Can be between -1.0 and 1.0. 0.0 does nothing;
void setBrightnessFunction(Uint8List sourceBmp, double brightnessRate) {
  assert(brightnessRate >= -1.0 && brightnessRate <= 1.0);
  assert(sourceBmp != null);

  if (brightnessRate == 0.0) return;

  final brightness = brightnessRate * 255;

  final size = sourceBmp.length;
  for (int i = 0; i < size; i += 4) {
    sourceBmp[i] = clamp255(sourceBmp[i] + brightness);
    sourceBmp[i + 1] = clamp255(sourceBmp[i + 1] + brightness);
    sourceBmp[i + 2] = clamp255(sourceBmp[i + 2] + brightness);
  }
}

const DEG_TO_RAD = 0.0174532925;

const lumCoeffR = 0.2125;
const lumCoeffG = 0.7154;
const lumCoeffB = 0.0721;

/// Adjusts a lot of stuff of color
void adjustColorFunction(Uint8List sourceBmp,
    {int blacks, int whites, double saturation, double exposure}) {
  if ((exposure == null || exposure == 0.0) &&
      (blacks == null || blacks == 0) &&
      (whites == null || whites == 0xFFFFFF) &&
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
  double invSaturation = saturation != null ? 1.0 - saturation : 0.0;

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
      double lum = r * lumCoeffR + g * lumCoeffG + b * lumCoeffB;

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
