import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:selfie_ocr_mtpl/selfie_ocr_mtpl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:async';
import 'package:xml/xml.dart';

void main() => runApp(
      MaterialApp(
        debugShowCheckedModeBanner: false,
        home: MyApp(),
      ),
    );

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _selectedImage;
  double height, width;
  String qrString = 'QR Not Scanned Yet';

  @override
  Widget build(BuildContext context) {
    height = MediaQuery.of(context).size.height;
    width = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Center(child: Text('Take Selfie Dummy')),
      ),
      body: Center(
          child: Column(
        children: [
          ElevatedButton(
            onPressed: () async {
              _selectedImage = await takeSelfie();
              _showBottomSheet();
            },
            child: Text("Click Selfie"),
          ),
          Column(
            children: [
              ElevatedButton(
                onPressed: () => scanQr(),
                child: Text("Aadhaar Qr Scan"),
              ),
              Text(
                qrString,
                style: TextStyle(color: Colors.black, fontSize: 20),
              )
            ],
          ),
        ],
      )),
    );
  }

  Future<void> scanQr() async {
    String qrScan = await FlutterBarcodeScanner.scanBarcode(
        '#ff6666', 'Cancel', true, ScanMode.QR);
    final document = XmlDocument.parse(qrScan);
    final detailNode = document.children.last;

    Map<String, String> details = {};
    detailNode.attributes.forEach((element) {
      details[element.name.toString()] = element.value;
    });

    details.entries.forEach((element) {
      print(element.key + ":   " + element.value);
    });
    this.qrString = details.entries.fold(
        "",
        (previousValue, element) =>
            previousValue + "\n" + element.key + ":   " + element.value);
    // this.qrString = details["uid"];
    setState(() {});

    print(details["uid"]);
  }

  void _showBottomSheet() {
    if (_selectedImage == null) return;
    showCupertinoModalPopup(
        context: context,
        builder: (context) => Material(
            borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
            child: _buildChoosenImage(context)));
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
            File(_selectedImage),
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
            onTap: () async {
              // Navigator.of(context).pop();
              _selectedImage = await takeSelfie();
              _showBottomSheet();
            },
            child: Padding(
              padding: EdgeInsets.all(9),
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(6)),
                height: 46,
                child: Center(
                    child: Text(
                  'Retake Photo',
                  style: TextStyle(
                      color: Colors.indigo[900], fontWeight: FontWeight.bold),
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
                    borderRadius: BorderRadius.circular(6)),
                height: 46,
                child: Center(
                    child: Text('Confirm',
                        style: TextStyle(
                            color: Colors.white, fontWeight: FontWeight.bold))),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<String> takeSelfie() async {
    String filePath = await FlutterTestSelfiecapture.detectLiveliness(
      "Hold your phone straight in front of your face\n make sure it fits well with face mask.",
      "Blink to take the photo\n don't forget to smile!",
    );
    print("file path - $filePath");
    String directory = (await getTemporaryDirectory()).path;
    String fileNameSuffix = DateTime.now().millisecondsSinceEpoch.toString();
    String faceImagePath = "$directory/face_cropped_img_$fileNameSuffix.png";
    print("faceImagePath $faceImagePath");
    final lines = await FlutterTestSelfiecapture.ocrFromDocumentImage(
        imagePath: filePath,
        destFaceImagePath: faceImagePath,
        xOffset: 30,
        yOffset: 50);
    if (lines != null) {
      print(lines);
      final resultData = lines;
      List<dynamic> items = resultData["ExtractedData"];
      print("ImagePath == ${resultData["FaceImagePath"]}");

      // if (lines != null) {
      //   final resultData = lines;
      //   List<dynamic> items = resultData["ExtractedData"];
      //   print("ImagePath == ${resultData["ImagePath"]}");
      //   print("itemsLength == ${items[0]}");
      // }

      return resultData["FaceImagePath"];
    }
    return null;
  }
}
