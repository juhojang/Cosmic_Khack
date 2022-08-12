import 'package:camera/camera.dart';
import'package:flutter/material.dart';
import 'package:google_ml_kit/google_ml_kit.dart';


class FaceDetectorPage extends StatefulWidget {
  const FaceDetectorPage({Key? key}) : super(key: key);

  @override
  State<FaceDetectorPage> createState() => _FaceDetectorPageState();
}

class _FaceDetectorPageState extends State<FaceDetectorPage> {

  final FaceDetector _faceDetector=FaceDetector(options:FaceDetectorOptions(
    enableContours: true,
    enableClassification: true
  ));

  bool _canProcess=true;
  bool _isBusy=false;
  CustomPaint? _customPaint;
  String? _text;

  @override
  void dispose(){
    _canProcess=false;
    _faceDetector.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Cameraview(title: 'face detector',
        onImage: (inputImage){
      processImage(inputImage);
        },
        customPaint: _customPaint,
        text: _text,
        initialDirection: CameraLensDirection.front);
  }
  Future<void>processImage(final InputImage inputImage)async{
    if(!_canProcess)return;
    if(_isBusy)return;
    _isBusy=true;
    setState(() {
      print(_text);
    });
    final faces=await _faceDetector.processImage(inputImage);
    if(inputImage.inputImageData?.size!=null&&
    inputImage.inputImageData?.imageRotation!=null){
      final painter=FaceDetectorPainter(
          faces, inputImage.inputImageData!.size,
          inputImage.inputImageData!.imageRotation);
      _customPaint=CustomPaint(painter: painter,);
    }else{
      String text='${faces.length}';
      for(final face in faces){
        text+='face: ${face.boundingBox}\n\n';
      }
      _text=text;
      _customPaint=null;
    }
    _isBusy=false;
    print(faces);
    if(mounted){
      setState(() {

      });
    }
  }
}
