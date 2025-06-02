import 'dart:async';

import 'package:bitmap/bitmap_flutter.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
      home: MyHomePage(
        title: "Pans",
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({
    Key? key,
    required this.title,
  }) : super(key: key);

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

  void rotateClockwiseImage() {
    if (imageValueNotifier.value != null) {
      imageValueNotifier.rotateClockwiseImage();
    }
  }

  void rotateCounterClockwiseImage() {
    if (imageValueNotifier.value != null) {
      imageValueNotifier.rotateCounterClockwiseImage();
    }
  }

  void rotate180Image() {
    if (imageValueNotifier.value != null) {
      imageValueNotifier.rotate180Image();
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

  void batchOperations() {
    if (imageValueNotifier.value != null) {
      imageValueNotifier.batchOperations();
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
          child: ValueListenableBuilder<Bitmap?>(
            valueListenable: imageValueNotifier,
            builder: (BuildContext context, Bitmap? bitmap, Widget? child) {
              if (bitmap == null) {
                return const CircularProgressIndicator();
              }
              return Column(
                children: <Widget>[
                  SafeArea(
                    top: true,
                    child: Image.memory(
                      bitmap.buildHeaded(),
                    ),
                  ),
                  const Text("Tap image to reset"),
                  Text("ImageSize ${bitmap.width}"),
                ],
              );
            },
          ),
        ),
      ),
      floatingActionButton: Buttons(
        flipHImage: flipHImage,
        flipVImage: flipVImage,
        rotateClockwiseImage: rotateClockwiseImage,
        rotateCounterClockwiseImage: rotateCounterClockwiseImage,
        rotate180Image: rotate180Image,
        contrastImage: contrastImage,
        brightnessImage: brightnessImage,
        adjustColorImage: adjustColorImage,
        batchOperations: batchOperations,
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}

class Buttons extends StatelessWidget {
  const Buttons({
    super.key,
    required this.flipHImage,
    required this.flipVImage,
    required this.rotateClockwiseImage,
    required this.rotateCounterClockwiseImage,
    required this.rotate180Image,
    required this.contrastImage,
    required this.brightnessImage,
    required this.adjustColorImage,
    required this.batchOperations,
  });

  final VoidCallback flipHImage;
  final VoidCallback flipVImage;
  final VoidCallback rotateClockwiseImage;
  final VoidCallback rotateCounterClockwiseImage;
  final VoidCallback rotate180Image;
  final VoidCallback contrastImage;
  final VoidCallback brightnessImage;
  final VoidCallback adjustColorImage;
  final VoidCallback batchOperations;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: <Widget>[
          Row(
            children: <Widget>[
              TextButton(
                onPressed: flipHImage,
                child: const Text(
                  "Flip horizontal",
                  style: TextStyle(fontSize: 10),
                ),
              ),
              TextButton(
                onPressed: flipVImage,
                child: const Text(
                  "Flip vertical",
                  style: TextStyle(fontSize: 10),
                ),
              ),
              TextButton(
                onPressed: contrastImage,
                child: const Text(
                  "Contrast +",
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              TextButton(
                onPressed: brightnessImage,
                child: const Text(
                  "Brightness +",
                  style: TextStyle(fontSize: 10),
                ),
              ),
              TextButton(
                onPressed: adjustColorImage,
                child: const Text(
                  "AdjustColor +",
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              TextButton(
                onPressed: rotateClockwiseImage,
                child: const Text(
                  "Rotate Clock +",
                  style: TextStyle(fontSize: 10),
                ),
              ),
              TextButton(
                onPressed: rotateCounterClockwiseImage,
                child: const Text(
                  "Rotate Clock -",
                  style: TextStyle(fontSize: 10),
                ),
              ),
              TextButton(
                onPressed: rotate180Image,
                child: const Text(
                  "Rotate 180",
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
          Row(
            children: <Widget>[
              TextButton(
                onPressed: batchOperations,
                child: const Text(
                  "Batch operations (saturation + crop)",
                  style: TextStyle(fontSize: 10),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// stores headless contents
class ImageValueNotifier extends ValueNotifier<Bitmap?> {
  ImageValueNotifier() : super(null);

  late Bitmap initial;

  void reset() {
    value = initial;
  }

  Future<void> loadImage() async {
    const ImageProvider imageProvider = const AssetImage("assets/street.jpg");

    value = await Bitmap.fromProvider(imageProvider);
    initial = value!;
  }

  Future<void> flipHImage() async {
    final temp = value!;
    value = null;

    final converted = await compute(
      flipHImageIsolate,
      [temp.content, temp.width, temp.height],
    );

    value = Bitmap.fromHeadless(temp.width, temp.height, converted);
  }

  Future<void> flipVImage() async {
    final temp = value!;
    value = null;

    final converted = await compute(
      flipVImageIsolate,
      [temp.content, temp.width, temp.height],
    );

    value = Bitmap.fromHeadless(temp.width, temp.height, converted);
  }

  Future<void> rotateClockwiseImage() async {
    final temp = value!;
    value = null;

    final converted = await compute(
      rotateClockwiseImageIsolate,
      [temp.content, temp.width, temp.height],
    );

    value = Bitmap.fromHeadless(temp.height, temp.width, converted);
  }

  Future<void> rotateCounterClockwiseImage() async {
    final temp = value!;
    value = null;

    final converted = await compute(
      rotateCounterClockwiseImageIsolate,
      [temp.content, temp.width, temp.height],
    );

    value = Bitmap.fromHeadless(temp.height, temp.width, converted);
  }

  Future<void> rotate180Image() async {
    final temp = value!;
    value = null;

    final converted = await compute(
      rotate180ImageIsolate,
      [temp.content, temp.width, temp.height],
    );

    value = Bitmap.fromHeadless(temp.width, temp.height, converted);
  }

  Future<void> contrastImage() async {
    final temp = value!;
    value = null;

    final converted = await compute(
      contrastImageIsolate,
      [temp.content, temp.width, temp.height],
    );

    value = Bitmap.fromHeadless(temp.width, temp.height, converted);
  }

  Future<void> brightnessImage() async {
    final temp = value!;
    value = null;

    final converted = await compute(
      brightnessImageIsolate,
      [temp.content, temp.width, temp.height],
    );

    value = Bitmap.fromHeadless(temp.width, temp.height, converted);
  }

  Future<void> adjustColorImage() async {
    final temp = value!;
    value = null;

    final converted = await compute(
      adjustColorsImageIsolate,
      [temp.content, temp.width, temp.height],
    );

    value = Bitmap.fromHeadless(temp.width, temp.height, converted);
  }

  Future<void> batchOperations() async {
    final temp = value!;
    value = null;

    final converted = await compute(
      batchOperationsImageIsolate,
      [temp.content, temp.width, temp.height],
    );

    value = Bitmap.fromHeadless(temp.width - 20, temp.height - 20, converted);
  }
}

Future<Uint8List> flipHImageIsolate(List<dynamic> imageData) async {
  final byteData = imageData[0] as Uint8List;
  final width = imageData[1] as int;
  final height = imageData[2] as int;

  final bigBitmap = Bitmap.fromHeadless(width, height, byteData);
  final returnBitmap = bigBitmap.apply(BitmapFlip.horizontal());

  return returnBitmap.content;
}

Future<Uint8List> flipVImageIsolate(List<dynamic> imageData) async {
  final byteData = imageData[0] as Uint8List;
  final width = imageData[1] as int;
  final height = imageData[2] as int;


  final bigBitmap = Bitmap.fromHeadless(width, height, byteData);

  final returnBitmap = bigBitmap.apply(BitmapFlip.vertical());

  return returnBitmap.content;
}

Future<Uint8List> rotateClockwiseImageIsolate(List<dynamic> imageData) async {
  final byteData = imageData[0] as Uint8List;
  final width = imageData[1] as int;
  final height = imageData[2] as int;

  final bigBitmap = Bitmap.fromHeadless(width, height, byteData);

  final returnBitmap = bigBitmap.apply(BitmapRotate.rotateClockwise());

  return returnBitmap.content;
}

Future<Uint8List> rotateCounterClockwiseImageIsolate(List<dynamic> imageData) async {
  final byteData = imageData[0] as Uint8List;
  final width = imageData[1] as int;
  final height = imageData[2] as int;

  final bigBitmap = Bitmap.fromHeadless(width, height, byteData);

  final returnBitmap = bigBitmap.apply(BitmapRotate.rotateCounterClockwise());

  return returnBitmap.content;
}

Future<Uint8List> rotate180ImageIsolate(List<dynamic> imageData) async {
    final byteData = imageData[0] as Uint8List;
  final width = imageData[1] as int;
  final height = imageData[2] as int;

  final bigBitmap = Bitmap.fromHeadless(width, height, byteData);

  final returnBitmap = bigBitmap.apply(BitmapRotate.rotate180());

  return returnBitmap.content;
}

Future<Uint8List> contrastImageIsolate(List<dynamic> imageData) async {
  final byteData = imageData[0] as Uint8List;
  final width = imageData[1] as int;
  final height = imageData[2] as int;

  final bigBitmap = Bitmap.fromHeadless(width, height, byteData);

  final returnBitmap = bigBitmap.apply(BitmapContrast(1.2));

  return returnBitmap.content;
}

Future<Uint8List> brightnessImageIsolate(List<dynamic> imageData) async {
  final byteData = imageData[0] as Uint8List;
  final width = imageData[1] as int;
  final height = imageData[2] as int;

  final bigBitmap = Bitmap.fromHeadless(width, height, byteData);

  final returnBitmap = bigBitmap.apply(BitmapBrightness(0.1));

  return returnBitmap.content;
}

Future<Uint8List> adjustColorsImageIsolate(List<dynamic> imageData) async {
  final byteData = imageData[0] as Uint8List;
  final width = imageData[1] as int;
  final height = imageData[2] as int;

  final bigBitmap = Bitmap.fromHeadless(width, height, byteData);

  final returnBitmap = bigBitmap.apply(
    BitmapAdjustColor(
      blacks: 0x00000000,
      saturation: 1.9, // 0 and 5 mid 1.0
    ),
  );

  return returnBitmap.content;
}

Future<Uint8List> batchOperationsImageIsolate(List<dynamic> imageData) async {
  final byteData = imageData[0] as Uint8List;
  final width = imageData[1] as int;
  final height = imageData[2] as int;

  final bigBitmap = Bitmap.fromHeadless(width, height, byteData);

  final returnBitmap = bigBitmap.applyBatch([
    BitmapAdjustColor(
      saturation: 1.9,
    ),
    BitmapCrop.fromLTWH(
      left: 10,
      top: 10,
      width: width - 20,
      height: height - 20,
    ),
  ]);

  return returnBitmap.content;
}
