import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

double translateX(final double x, final InputImageRotation rotation,
final Size size, final Size absoluteImageSize){
  switch(rotation){
    case InputImageRotation.rotation90deg:
      return x*size.width/absoluteImageSize.height;

    case InputImageRotation.rotation270deg:
      return size.width-x*size.width/absoluteImageSize.height;

    default:
      return x*size.width/absoluteImageSize.width;
  }
}


double translateY(
    final double y, final InputImageRotation rotation, final Size size,final Size absoluteImageSize){
  switch(rotation){
    case InputImageRotation.rotation90deg:
    case InputImageRotation.rotation270deg:
      return y*size.height/absoluteImageSize.height;
    default:
      return y*size.height/absoluteImageSize.height;
  }
}