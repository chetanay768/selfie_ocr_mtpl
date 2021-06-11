import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selfie_ocr_mtpl/selfie_ocr_mtpl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/services.dart';
import 'dart:async';

void main() => runApp(MaterialApp(home: MyApp()));

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  File _selectedImage;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Take Selfie Dummy')),
      ),
      body: Center(
          child: ElevatedButton(
        onPressed: () {
          callOCRDetection();
          FlutterTestSelfiecapture.detectLiveliness(
              "Hold your phone straight in front of your face\n make sure it fits well with face mask.",
              "Blink to take the photo\n don't forget to smile!");
        },
        child: Text("Click Selfie"),
      )),
    );
  }

  Widget _buildChoosenImage(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(9),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Align(
              child: Image.file(
            _selectedImage,
            width: 122,
            height: 145,
          )),
          SizedBox(height: 6),
          Text(
            "Looking good!",
            style: TextStyle(
                color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12),
          Text(
            "This picture should work fine, but you want to take another if you want.",
            style: TextStyle(color: Colors.black54),
          ),
          SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              Navigator.of(context).pop();
              callOCRDetection();
              FlutterTestSelfiecapture.detectLiveliness(
                  "Hold your phone straight in front of your face\n make sure it fits well with face mask.",
                  "Blink to take the photo\n don't forget to smile!");
            },
            child: Padding(
              padding: EdgeInsets.all(9),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(6)
                ),
                height: 46,
                child: Center(
                    child: Text(
                  'Retake Photo',
                  style: TextStyle(color: Colors.indigo[900], fontWeight: FontWeight.bold),
                )),
              ),
            ),
          ),
          GestureDetector(
            onTap: () {},
            child: Padding(
              padding: EdgeInsets.all(9),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.indigo[900],
                  borderRadius: BorderRadius.circular(6)
                ),
                height: 46,
                child: Center(
                    child: Text('Confirm',
                        style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold
                        ))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void callOCRDetection() async {
    String directory = (await getTemporaryDirectory()).path;
    String faceImagePath = "$directory/face_cropped_img.png";
    final lines = await FlutterTestSelfiecapture.ocrFromDocumentImage(
        imagePath: "/storage/emulated/0/temp_photo.jpg",
        destFaceImagePath: faceImagePath,
        xOffset: 30,
        yOffset: 50);

    this._selectedImage = File("/storage/emulated/0/temp_photo.jpg");

    await showCupertinoModalPopup(
        context: context,
        builder: (context) => Material(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: _buildChoosenImage(context)));
    // if (lines != null) {
    //   final resultData = lines;
    //   List<dynamic> items = resultData["ExtractedData"];
    //   print("ImagePath == ${resultData["ImagePath"]}");
    //   print("itemsLength == ${items[0]}");
    // }
  }
}
