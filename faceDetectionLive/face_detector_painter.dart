import 'dart:math';

import 'package:flutter/material.dart';
import 'coordinates_painter.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';


class FaceDetectorPainter extends CustomPainter{
  final List<Face>faces;
  final Size absoluteImageSize;
  final InputImageRotation rotation;

  FaceDetectorPainter(this.faces,this.absoluteImageSize,this.rotation);

  
  @override
  void paint(final Canvas canvas,final Size size){
    final Paint paint=Paint()
        ..style=PaintingStyle.stroke
        ..strokeWidth=1.0
        ..color=Colors.blue;
    for(final Face face in faces){
      canvas.drawRect(face.boundingBox.topLeft/1.75+Offset(0,65) & face
          .boundingBox.size/1.7,paint);
    }
  }

  @override
  bool shouldRepaint(final FaceDetectorPainter oldDelegate){
    return oldDelegate.absoluteImageSize!=absoluteImageSize||oldDelegate.faces!=faces;
  }
}