import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bitmap/bitmap.dart';
import 'package:bitmap/transformations.dart';


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
          child: ValueListenableBuilder<Bitmap>(
            valueListenable: imageValueNotifier ?? ImageValueNotifier(),
            builder: (BuildContext context, Bitmap bitmap, Widget child) {
              if (bitmap == null) {
                return const CircularProgressIndicator();
              }
              return Column(
                children: <Widget>[
                  Image.memory(
                    bitmap.buildHeaded(),
                  ),
                  Text("ImageSize ${bitmap.width}")
                ],
              );
            },
          ),
        ),
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
                  child: const Text("Flip horizontal", style: TextStyle(fontSize: 10),),
                ),
                FlatButton(
                  onPressed: flipVImage,
                  child: const Text("Flip vertical", style: TextStyle(fontSize: 10),),
                ),
                FlatButton(
                  onPressed: contrastImage,
                  child: const Text("Contrast +", style: TextStyle(fontSize: 10),),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                FlatButton(
                  onPressed: brightnessImage,
                  child: const Text("Brightness +", style: TextStyle(fontSize: 10),),
                ),
                FlatButton(
                  onPressed: adjustColorImage,
                  child: const Text("AdjustColor +", style: TextStyle(fontSize: 10),),
                ),
              ],
            ),
          ],
        ));
  }
}

// stores headless contents
class ImageValueNotifier extends ValueNotifier<Bitmap> {
  ImageValueNotifier() : super(null);

  Bitmap initial;

  void reset() {
    value = initial;
  }

  void loadImage() async {
    const ImageProvider imageProvider = const AssetImage("assets/street.jpg");

    value = await Bitmap.fromProvider(imageProvider);
    initial = value;
  }

  void flipHImage() async {
    final temp = value;
    value = null;

    final Uint8List converted = await compute(
      flipHImageIsolate,
      [temp.content, temp.width, temp.height],
    );

    value = Bitmap.fromHeadless(temp.width, temp.height, converted);
  }

  void flipVImage() async {
    final temp = value;
    value = null;

    final converted = await compute(
      flipVImageIsolate,
      [temp.content, temp.width, temp.height],
    );

    value = Bitmap.fromHeadless(temp.width, temp.height, converted);
  }

  void contrastImage() async {
    final temp = value;
    value = null;

    final Uint8List converted = await compute(
      contrastImageIsolate,
      [temp.content, temp.width, temp.height],
    );

    value = Bitmap.fromHeadless(temp.width, temp.height, converted);
  }

  void brightnessImage() async {
    final temp = value;
    value = null;

    final start = DateTime.now();
    final Uint8List converted = await compute(
      brightnessImageIsolate,
      [temp.content, temp.width, temp.height],
    );
    final end = DateTime.now();

    print(end.difference(start));

    value = Bitmap.fromHeadless(temp.width, temp.height, converted);
  }

  void adjustColorImage() async {
    final temp = value;
    value = null;

    final Uint8List converted = await compute(
      adjustColorsImageIsolate,
      [temp.content, temp.width, temp.height],
    );

    value = Bitmap.fromHeadless(temp.width, temp.height, converted);
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

  final Bitmap returnBitmap = brightness(bigBitmap, 0.1);

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
