
import 'dart:io' as io;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:blurrycontainer/blurrycontainer.dart';


List<CameraDescription>cameras=[];
void main() {
  runApp(const MyApp());
}


void availableCamera() async{
  cameras=await availableCameras();
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

int faceNumber=0;
List<Face> recognisedface=[];
List<Face> bluredface=[];
List<TextBlock> blocks=[];
bool eraseAccept=false;
PaintingStyle canvasStyle=PaintingStyle.stroke;

class _MyHomePageState extends State<MyHomePage> {
  bool textScanning=false;
  bool isWorking=false;


  XFile? imageFile;

  String scannedText="";

  Widget blurFace(int i){
    print(bluredface[i].boundingBox);
    return Positioned(
        top: bluredface[i].boundingBox.topRight.dy/2.6,
        left: bluredface[i].boundingBox.topLeft.dx/2.6,
        child: BlurryContainer(
          width: bluredface[i].boundingBox.width/2.6,
          height: bluredface[i].boundingBox.height/2.6,
          child: Container(),
          color: Colors.white.withOpacity(0.10),
          blur: 5,
          ),
        );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if(imageFile!=null)
              Stack(
                children:[
                  Padding(
                  padding: EdgeInsets.fromLTRB(0, 0, 0, 0),
                    child: Image.file(io.File(imageFile!.path),fit:BoxFit.fill,)),
                  for (int i =0;i<bluredface.length;i++) blurFace(i),
              Container(
                width: 1000,
                height: 1000,
                color: Colors.black12,
                  child: Listener(
                    onPointerMove: (event2){
                      Face? targetFace;
                      for (int i =0;i<faceNumber;i++) {
                        if(i<recognisedface.length)
                        {
                          if(event2.localPosition.dx>(recognisedface[i].boundingBox.topLeft.dx/2.6)&&event2.localPosition.dx<(recognisedface[i].boundingBox.bottomRight.dx/2.6))
                          {
                            if(event2.localPosition.dy<(recognisedface[i].boundingBox.bottomRight.dy/2.6)&&event2.localPosition.dy>(recognisedface[i].boundingBox.topLeft.dy/2.6))
                            {
                              targetFace=recognisedface[i];
                              break;
                            }
                          }
                        }
                        else{
                          if(event2.localPosition.dx>(bluredface[i-recognisedface.length].boundingBox.topLeft.dx/2.6)&&event2.localPosition.dx<(bluredface[i-recognisedface.length].boundingBox.bottomRight.dx/2.6))
                          {
                            if(event2.localPosition.dy<(bluredface[i-recognisedface.length].boundingBox.bottomRight.dy/2.6)&&event2.localPosition.dy>(bluredface[i-recognisedface.length].boundingBox.topLeft.dy/2.6))
                            {
                              targetFace=bluredface[i-recognisedface.length];
                              break;
                            }
                          }

                        }
                      }
                      if(targetFace!=null){
                            if(event2.localPosition.dx>(targetFace.boundingBox.topLeft.dx/2.6)&&event2.localPosition.dx<(targetFace.boundingBox.bottomRight.dx/2.6))
                              if(event2.localPosition.dy>(targetFace.boundingBox.bottomRight.dy/2.6)&&event2.localPosition.dy<(targetFace.boundingBox.topLeft.dy/2.6))
                            {
                                eraseAccept=false;
                            }
                            else{
                                eraseAccept=true;
                              }

                        if(eraseAccept)
                          {
                            eraseAccept=false;
                            faceNumber=faceNumber-1;
                            setState(() {
                              recognisedface.remove(targetFace);
                              bluredface.remove(targetFace);
                              print("remove");
                            });

                          }
                      }
                    },
                    onPointerDown: (event){
                       for (int i =0;i<faceNumber;i++) {
                           if(i<recognisedface.length)
                      {
                        if(event.localPosition.dx>(recognisedface[i].boundingBox.topLeft.dx/2.6)&&event.localPosition.dx<(recognisedface[i].boundingBox.bottomRight.dx/2.6))
                        {
                          if(event.localPosition.dy<(recognisedface[i].boundingBox.bottomRight.dy/2.6)&&event.localPosition.dy>(recognisedface[i].boundingBox.topLeft.dy/2.6))
                          {
                            setState(() {
                              bluredface.add(recognisedface[i]);
                              recognisedface.remove(recognisedface[i]);
                            });
                            break;
                          }
                        }
                      }
                           else{
                             if(event.localPosition.dx>(bluredface[i-recognisedface.length].boundingBox.topLeft.dx/2.6)&&event.localPosition.dx<(bluredface[i-recognisedface.length].boundingBox.bottomRight.dx/2.6))
                             {
                               if(event.localPosition.dy<(bluredface[i-recognisedface.length].boundingBox.bottomRight.dy/2.6)&&event.localPosition.dy>(bluredface[i-recognisedface.length].boundingBox.topLeft.dy/2.6))
                               {
                                 setState(() {
                                   recognisedface.add(bluredface[i-recognisedface.length]);
                                   bluredface.remove(bluredface[i-recognisedface.length+1]);
                                 });
                                 break;
                               }
                             }

                           }
    }
                    },
                    child: CustomPaint(
                      painter:BackgroundPainter(),
                ),
                  ),
              ),
]
              ),

          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: ()async{
          cameras=await availableCameras();
          print(cameras);
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context)=> const Homepage(),
            ),
          );
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
    blocks=recognisedText.blocks;

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
    faceNumber=recognisedface.length;
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
      ..strokeWidth=3
      ..color = Colors.greenAccent
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

class BackgroundPainter2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var background = Paint()
      ..style = canvasStyle
      ..strokeWidth=5
      ..color = Colors.red
      ..isAntiAlias=true;
    for (int i =0;i<blocks.length;i++) {
      canvas.drawRect(
          blocks[i].boundingBox.topLeft / 7.4 & blocks[i]
              .boundingBox.size / 7.4, background);
    }


  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}