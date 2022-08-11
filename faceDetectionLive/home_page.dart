import 'package:flutter/material.dart';
import 'face_detector_page.dart';

class Homepage extends StatefulWidget {
  const Homepage({Key? key}) : super(key: key);

  @override
  State<Homepage> createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("facedetector"),),
      body: _body(),
    );
  }
  Widget _body()=>
    Center(
      child: SizedBox(
        height: 350,
        width: 80,
        child: OutlinedButton(
          style: ButtonStyle(
            side: MaterialStateProperty.all(
              const BorderSide(
                color: Colors.blue,width: 1.0,style: BorderStyle.solid,
              )
            )
          ),
          onPressed: ()=>Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context)=> const FaceDetectorPage(),
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Padding(padding: EdgeInsets.symmetric(horizontal: 12.0),
              child: Icon(
                Icons.arrow_back_ios,
                size: 24,
              ),),
            ],
          ),
        ),
      ),
    );
}
