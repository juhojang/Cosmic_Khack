
import 'dart:io' as io;

import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

List<Face> recognisedface=[];

class _MyHomePageState extends State<MyHomePage> {
  bool textScanning=false;
  bool isWorking=false;

  XFile? imageFile;

  String scannedText="";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if(imageFile!=null)
              Stack(
                children:[
                  Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Image.file(io.File(imageFile!.path)),),

              Container(
                width: 1000,
                height: 1000,
                color: Colors.black12,
                child: CustomPaint(
                  painter: BackgroundPainter(),
                ),
              ),
]
              ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          getImage();
          },
        tooltip: 'Increment',
        child: const Icon(Icons.add),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
  void getRecognisedText(XFile image) async{
    final inputImage=InputImage.fromFilePath(image.path);
    final textDetector=GoogleMlKit.vision.textRecognizer();
    RecognizedText recognisedText=await textDetector.processImage(inputImage);
    await textDetector.close();
    scannedText="";
    for (TextBlock block in recognisedText.blocks){
      for(TextLine line in block.lines){
        scannedText=scannedText+line.text+"\n";
      }
    }

    print(scannedText);
    textScanning=false;
    setState(() {

    });
  }

    void getImage() async{
    try{
      final pickedimage=await ImagePicker().pickImage(source: ImageSource.gallery);
      if(pickedimage!=null){
        textScanning= true;
        imageFile=pickedimage;
        setState(() {

        });
        getRecognisedFace(pickedimage);
      }

    }catch(e){
      textScanning= true;
    imageFile=null;
    setState(() {});
    scannedText="error";
    }
  }

  void getRecognisedFace(XFile image) async{
    final inputImage=InputImage.fromFilePath(image.path);
    final FaceDetector=GoogleMlKit.vision.faceDetector();
    recognisedface=await FaceDetector.processImage(inputImage);
    await FaceDetector.close();

    textScanning=false;
    setState(() {

    });
  }

}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var background = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth=5
      ..color = Colors.red
      ..isAntiAlias=true;
for (int i =0;i<recognisedface.length;i++) {
  canvas.drawRect(
      recognisedface[i].boundingBox.topLeft / 2.6 & recognisedface[i]
          .boundingBox.size / 2.6, background);
}


  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}