import 'package:flutter/material.dart';

void main() {
  runApp(showImage());
}

class showImage extends StatefulWidget {

  @override
  State<showImage> createState() => _showImageState();
}

class _showImageState extends State<showImage> {


  Widget showImage() {
    return Container(
      color: const Color(0xffd0cece),
      width: 100,
      height: 100,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: showImage(),
      ),
    );
  }
}

