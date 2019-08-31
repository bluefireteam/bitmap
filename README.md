# WIP: Flutter Bitmap



A minimalist package to help you manipulate bitmaps. It is focused on bitmap transformations.

The package standard format is ARGB32.

For now, things like format encoding, exif and multi-frame images are not the concern of this package.

For a full features image lib, check [`image`](https://pub.dartlang.org/packages/image).



## Supported operations

- flip vertical
- flip horizontal
- resize (nearest interpolation)

### Also We,ve added some filters based on the `image` package.
- Contraste
- Brightness
- Saturation
- Exposure
