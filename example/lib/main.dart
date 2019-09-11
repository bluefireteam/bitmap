import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bitmap/bitmap.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Image',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);

  final String title;

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  ImageValueNotifier imageValueNotifier = ImageValueNotifier();

  @override
  void initState() {
    super.initState();
    imageValueNotifier.loadImage();
  }

  void flipHImage() {
    if (imageValueNotifier.value != null) {
      imageValueNotifier.flipHImage();
    }
  }

  void flipVImage() {
    if (imageValueNotifier.value != null) {
      imageValueNotifier.flipVImage();
    }
  }

  void contrastImage() {
    if (imageValueNotifier.value != null) {
      imageValueNotifier.contrastImage();
    }
  }

  void brightnessImage() {
    if (imageValueNotifier.value != null) {
      imageValueNotifier.brightnessImage();
    }
  }

  void adjustColorImage() {
    if (imageValueNotifier.value != null) {
      imageValueNotifier.adjustColorImage();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          imageValueNotifier.reset();
        },
        child: Center(
            child: ValueListenableBuilder(
                valueListenable: imageValueNotifier ?? ImageValueNotifier(),
                builder: (BuildContext context, Uint8List value, Widget child) {
                  if (value == null) {
                    return const CircularProgressIndicator();
                  }
                  return Column(
                    children: <Widget>[
                      Image.memory(
                        Bitmap.fromHeadless(
                          imageValueNotifier.width,
                          imageValueNotifier.height,
                          value,
                        ).headedContent,
                      ),
                      Text("ImageSize ${imageValueNotifier.width}")
                    ],
                  );
                })),
      ),
      floatingActionButton: Buttons(
        flipHImage: flipHImage,
        flipVImage: flipVImage,
        contrastImage: contrastImage,
        brightnessImage: brightnessImage,
        adjustColorImage: adjustColorImage,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Buttons extends StatelessWidget {
  const Buttons({
    Key key,
    this.flipHImage,
    this.flipVImage,
    this.contrastImage,
    this.brightnessImage,
    this.adjustColorImage,
  }) : super(key: key);

  final VoidCallback flipHImage;
  final VoidCallback flipVImage;
  final VoidCallback contrastImage;
  final VoidCallback brightnessImage;
  final VoidCallback adjustColorImage;

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Row(
              children: <Widget>[
                FlatButton(
                  onPressed: flipHImage,
                  child: const Text("Flip horizontal"),
                ),
                FlatButton(
                  onPressed: flipVImage,
                  child: const Text("Flip vertical"),
                ),
                FlatButton(
                  onPressed: contrastImage,
                  child: const Text("Contrast +"),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                FlatButton(
                  onPressed: brightnessImage,
                  child: const Text("Brightness +"),
                ),
                FlatButton(
                  onPressed: adjustColorImage,
                  child: const Text("AdjustColor +"),
                ),
              ],
            ),
          ],
        ));
  }
}

// stores headless contents
class ImageValueNotifier extends ValueNotifier<Uint8List> {
  ImageValueNotifier() : super(null);

  Uint8List initial;

  int width = 0;
  int height = 0;

  void reset() {
    value = initial;
  }

  void loadImage() async {
    const ImageProvider imageProvider = const AssetImage("assets/street.jpg");
    final Completer completer = Completer<ImageInfo>();
    final ImageStream stream =
        imageProvider.resolve(const ImageConfiguration());
    final listener =
        ImageStreamListener((ImageInfo info, bool synchronousCall) {
      if (!completer.isCompleted) {
        completer.complete(info);
      }
    });
    stream.addListener(listener);
    final imageInfo = await completer.future;
    final ui.Image image = imageInfo.image;
    width = image.width;
    height = image.height;
    final ByteData byteData = await image.toByteData();
    final Uint8List listInt = byteData.buffer.asUint8List();
    value = listInt;
    initial = listInt;
  }

  void flipHImage() async {
    final temp = value;
    value = null;

    final Uint8List converted =
        await compute(flipHImageIsolate, [temp, width, height]);

    value = converted;
  }

  void flipVImage() async {
    final temp = value;
    value = null;

    final converted = await compute(flipVImageIsolate, [temp, width, height]);

    value = converted;
  }

  void contrastImage() async {
    final temp = value;
    value = null;

    final Uint8List converted =
        await compute(contrastImageIsolate, [temp, width, height]);

    value = converted;
  }

  void brightnessImage() async {
    final temp = value;
    value = null;

    final start = DateTime.now();
    final Uint8List converted = await compute(
      brightnessImageIsolate,
      [temp, width, height],
    );
    final end = DateTime.now();

    print(end.difference(start));

    value = converted;
  }

  void adjustColorImage() async {
    final temp = value;
    value = null;

    final Uint8List converted =
        await compute(adjustColorsImageIsolate, [temp, width, height]);

    value = converted;
  }
}

Future<Uint8List> flipHImageIsolate(List imageData) async {
  final Uint8List byteData = imageData[0];
  final int width = imageData[1];
  final int height = imageData[2];

  final bigBitmap = Bitmap.fromHeadless(width, height, byteData);
  final returnBitmap = flipHorizontal(bigBitmap);

  return returnBitmap.content;
}

Future<Uint8List> flipVImageIsolate(List imageData) async {
  final Uint8List byteData = imageData[0];
  final int width = imageData[1];
  final int height = imageData[2];

  final Bitmap bigBitmap = Bitmap.fromHeadless(width, height, byteData);

  final Bitmap returnBitmap = flipVertical(bigBitmap);

  return returnBitmap.content;
}

Future<Uint8List> contrastImageIsolate(List imageData) async {
  final Uint8List byteData = imageData[0];
  final int width = imageData[1];
  final int height = imageData[2];

  final Bitmap bigBitmap = Bitmap.fromHeadless(width, height, byteData);

  final returnBitmap = contrast(bigBitmap, 1.2);

  return returnBitmap.content;
}

Future<Uint8List> brightnessImageIsolate(List imageData) async {
  final Uint8List byteData = imageData[0];
  final int width = imageData[1];
  final int height = imageData[2];

  final Bitmap bigBitmap = Bitmap.fromHeadless(width, height, byteData);

  final Bitmap returnBitmap = brightness(bigBitmap, 0.2);

  return returnBitmap.content;
}

Future<Uint8List> adjustColorsImageIsolate(List imageData) async {
  final Uint8List byteData = imageData[0];
  final int width = imageData[1];
  final int height = imageData[2];

  final Bitmap bigBitmap = Bitmap.fromHeadless(width, height, byteData);

  final Bitmap returnBitmap = adjustColor(
    bigBitmap,
    blacks: 0x00000000,
    whites: 0x00FFFFFF,
    saturation: 5.0, // 0 and 5 mid 1.0
    exposure: 0.0, // 0 and 0.5 no mid
  );

  return returnBitmap.content;
}
