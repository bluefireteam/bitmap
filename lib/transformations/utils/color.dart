/// Taken from dart image lib:
/// All credits to Brendan Duncan: https://github.com/brendan-duncan/image

int clamp255(double x) => x.clamp(0, 255).toInt();

int getRed(int color) => color & 0xff;

int getGreen(int color) => (color >> 8) & 0xff;

int getBlue(int color) => (color >> 16) & 0xff;

int getAlpha(int color) => (color >> 24) & 0xff;
