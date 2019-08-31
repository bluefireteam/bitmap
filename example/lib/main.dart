import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:bitmap/bitmap.dart';

import 'dart:ui' as ui;

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
    if (imageValueNotifier.value != null) imageValueNotifier.flipHImage();
  }

  void flipVImage() {
    if (imageValueNotifier.value != null) imageValueNotifier.flipVImage();
  }

  void contrastImage() {
    if (imageValueNotifier.value != null) imageValueNotifier.contrastImage();
  }

  void brightnessImage() {
    if (imageValueNotifier.value != null) imageValueNotifier.brightnessImage();
  }

  void adjustColorImage() {
    if (imageValueNotifier.value != null) imageValueNotifier.adjustColorImage();
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
                builder: (BuildContext context, ui.Image value, Widget child) {
                  if (value == null) return CircularProgressIndicator();
                  return Column(
                    children: <Widget>[
                      RawImage(
                        image: value,
                      ),
                      Text("ImageSize ${value.width}")
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
  final VoidCallback flipHImage;
  final VoidCallback flipVImage;
  final VoidCallback contrastImage;
  final VoidCallback brightnessImage;
  final VoidCallback adjustColorImage;

  const Buttons(
      {Key key,
      this.flipHImage,
      this.flipVImage,
      this.contrastImage,
      this.brightnessImage,
      this.adjustColorImage})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: <Widget>[
            Row(
              children: <Widget>[
                FlatButton(
                  onPressed: flipHImage,
                  child: Text("Flip horizontal"),
                ),
                FlatButton(
                  onPressed: flipVImage,
                  child: Text("Flip vertical"),
                ),
                FlatButton(
                  onPressed: contrastImage,
                  child: Text("Contrast +"),
                ),
              ],
            ),
            Row(
              children: <Widget>[
                FlatButton(
                  onPressed: brightnessImage,
                  child: Text("Brightness +"),
                ),
                FlatButton(
                  onPressed: adjustColorImage,
                  child: Text("AdjustColor +"),
                ),
              ],
            ),
          ],
        ));
  }
}

class ImageValueNotifier extends ValueNotifier<ui.Image> {
  ImageValueNotifier() : super(null);

  ui.Image initial = null;

  void reset() {
    value = initial;
  }

  void loadImage() {
    const ImageProvider imageProvider = const AssetImage("assets/doggo.jpeg");
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
    completer.future.then((info) {
      ImageInfo imageInfo = info as ImageInfo;
      value = imageInfo.image;
      initial = value;
    });
  }

  void flipHImage() async {
    ByteData byteData = await value.toByteData();
    Uint8List listInt = byteData.buffer.asUint8List();

    ui.Image temp = value;
    value = null;

    Uint8List converted =
        await compute(flipHImageIsolate, [listInt, temp.width, temp.height]);

    ui.decodeImageFromList(converted, (image) {
      value = image;
    });
  }

  void flipVImage() async {
    ByteData byteData = await value.toByteData();
    Uint8List listInt = byteData.buffer.asUint8List();

    ui.Image temp = value;
    value = null;

    Uint8List converted =
        await compute(flipVImageIsolate, [listInt, temp.width, temp.height]);

    ui.decodeImageFromList(converted, (image) {
      value = image;
    });
  }

  void contrastImage() async {
    ByteData byteData = await value.toByteData();
    Uint8List listInt = byteData.buffer.asUint8List();

    ui.Image temp = value;
    value = null;

    final Uint8List converted = await compute(contrastImageIsolate, [
      listInt,
      temp.width,
      temp.height,
    ]);

    ui.decodeImageFromList(converted, (image) {
      value = image;
    });
  }

  void brightnessImage() async {
    final ByteData byteData = await value.toByteData();
    final Uint8List listInt = byteData.buffer.asUint8List();

    ui.Image temp = value;
    value = null;

    final Uint8List converted = await compute(
        brightnessImageIsolate, [listInt, temp.width, temp.height]);

    ui.decodeImageFromList(converted, (image) {
      value = image;
    });
  }

  void adjustColorImage() async {
    final ByteData byteData = await value.toByteData();
    final Uint8List listInt = byteData.buffer.asUint8List();

    ui.Image temp = value;
    value = null;

    final Uint8List converted = await compute(
        adjustColorsImageIsolate, [listInt, temp.width, temp.height]);

    ui.decodeImageFromList(converted, (image) {
      value = image;
    });
  }
}

Future<Uint8List> flipHImageIsolate(List imageData) async {
  Uint8List byteData = imageData[0];
  int width = imageData[1];
  int height = imageData[2];

  final Bitmap bigBitmap = Bitmap(width, height, byteData);

  final Bitmap returnBitmap = await bigBitmap.flipHorizontal();

  return BitmapFile(returnBitmap).bitmapWithHeader;
}

Future<Uint8List> flipVImageIsolate(List imageData) async {
  Uint8List byteData = imageData[0];
  int width = imageData[1];
  int height = imageData[2];

  final Bitmap bigBitmap = Bitmap(width, height, byteData);

  final Bitmap returnBitmap = await bigBitmap.flipVertical();

  return BitmapFile(returnBitmap).bitmapWithHeader;
}

Future<Uint8List> contrastImageIsolate(List imageData) async {
  Uint8List byteData = imageData[0];
  int width = imageData[1];
  int height = imageData[2];

  final Bitmap bigBitmap = Bitmap(width, height, byteData);

  final Bitmap returnBitmap = await bigBitmap.setContrast(1.2);

  return BitmapFile(returnBitmap).bitmapWithHeader;
}

Future<Uint8List> brightnessImageIsolate(List imageData) async {
  Uint8List byteData = imageData[0];
  int width = imageData[1];
  int height = imageData[2];

  final Bitmap bigBitmap = Bitmap(width, height, byteData);

  final Bitmap returnBitmap = await bigBitmap.setBrightness(0.2);

  return BitmapFile(returnBitmap).bitmapWithHeader;
}

Future<Uint8List> adjustColorsImageIsolate(List imageData) async {
  Uint8List byteData = imageData[0];
  int width = imageData[1];
  int height = imageData[2];

  final Bitmap bigBitmap = Bitmap(width, height, byteData);

  final Bitmap returnBitmap = await bigBitmap.adjustColor(
      //blacks: 0x00000000,
      //whites: 0x00FFFFFF,
      //saturation: 5.0, // 0 and 5 mid 1.0
      //exposure:  0.0 // 0 and 0.5 no mid
      );

  return BitmapFile(returnBitmap).bitmapWithHeader;
}
