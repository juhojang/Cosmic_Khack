import 'dart:io';

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

class _MyHomePageState extends State<MyHomePage> {
  bool textScanning=false;
  bool isWorking=false;

  XFile? imageFile;

  String scannedText="";


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        // Here we take the value from the MyHomePage object that was created by
        // the App.build method, and use it to set our appbar title.
        title: Text(widget.title),
      ),
      body: Center(
        // Center is a layout widget. It takes a single child and positions it
        // in the middle of the parent.
        child: Column(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            if(textScanning)
              CircularProgressIndicator(),
            if(!textScanning&&imageFile==null)
            Container(
              width: 300,
              height: 300,
              color: Colors.black12,
            ),
            Text(scannedText),

            if(imageFile!=null)
              Image.file(File(imageFile!.path)),
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
        getRecognisedText(pickedimage);
      }

    }catch(e){
      textScanning= true;
    imageFile=null;
    setState(() {});
    scannedText="error";
    }
  }
}