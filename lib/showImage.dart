import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:untitled20/main.dart';


class showImage extends StatefulWidget {
  final File? _image;
  const showImage(this._image);

  @override
  State<showImage> createState() => _showImageState();
}

class _showImageState extends State<showImage> {


  Widget showImage() {
    return Container(
        color: const Color(0xffd0cece),
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.width,
        child: Center(
            child: widget._image == null
                ? Text('No image selected.')
                : Image.file(File(widget._image!.path))));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: showImage(),
    );
  }
}
