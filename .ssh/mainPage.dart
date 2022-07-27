import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:image_picker/image_picker.dart';
import 'package:untitled20/showImage.dart';

void main() {
  runApp(new MyApp());
}
class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Generated App',
      theme: new ThemeData(
        primaryColor: Colors.white,
      ),
      home: new MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key ?key}) : super(key: key);
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  File? _image;
  final picker = ImagePicker();

  // 비동기 처리를 통해 카메라와 갤러리에서 이미지를 가져온다.
  Future getImage(ImageSource imageSource) async {
    final image = await picker.pickImage(source: imageSource);

    setState(() {
      _image = File(image!.path); // 가져온 이미지를 _image에 저장
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) => showImage(_image)),);
  }

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  var isSwitched=false;
  List<bool> isSelected = [false];
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        backgroundColor: Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding:EdgeInsets.fromLTRB(0, 29, 0, 0),
              child: ListTile(
                leading: Icon(
                  Icons.menu,
                  color: Colors.black,
                ),
                title:Text('설정',style: TextStyle(fontSize: 18),),
              ),
            ),
            ListTile(
              title:Text('자동실행',style: TextStyle(fontSize: 20.0),),
            ),
            ListTile(
              title:Padding(
                padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
                  child: Text('부팅 시 자동실행')),
              trailing: Switch(
                value: isSwitched,
                onChanged: (value){
                  setState(() {
                    isSwitched=value;
                  });
                },
                activeColor: Colors.green,
              ),
            ),
            ListTile(
              title:Text('버전명시',style: TextStyle(fontSize: 20.0),),
            ),
            Padding(
              padding: EdgeInsets.fromLTRB(15, 0, 0, 0),
              child: ListTile(
                title:Text('버전 : v0.0.1'),
              ),
            ),
          ],
        ),
      ),
      appBar: new AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        title: new Text('개인정보보호앱',style: TextStyle(color:Colors.black),),
        leading: IconButton(
          icon: Icon(Icons.menu),
          color: Colors.black,
          onPressed: (){
            _scaffoldKey.currentState?.openDrawer();
          },
        ),
      ),
      body:
      new Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(padding: EdgeInsets.fromLTRB(0, 150, 0, 0)),
            ToggleButtons(
                borderRadius: BorderRadius.circular(180),
                borderWidth: 30,
                disabledColor: Colors.grey,
                selectedColor: Colors.green,
                selectedBorderColor: Colors.green,
                children:[
              Icon(Icons.lock,size: 200,)],
                onPressed:(int index){setState(() {
              isSelected[index] = !isSelected[index];
            });},
                isSelected: isSelected),
            Padding(padding: EdgeInsets.fromLTRB(0, 20, 0, 0)),
            Switch(

              value: isSelected[0],
              onChanged: (value){
                setState(() {
                  isSelected[0]=value;
                });
              },
              activeColor: Colors.green,
            ),
            Padding(padding: EdgeInsets.fromLTRB(0, 40, 0, 0)),
            new Text(
              "n 개의 이미지에 개인정보가 감지되었습니다.",
              style: new TextStyle(fontSize:20.0,
                  color: const Color(0xFF000000),
                  fontWeight: FontWeight.w200,
                  fontFamily: "Roboto"),
            ),
            Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 0)),

            new Text(
              "n 개의 동영상에 개인정보가 감지되었습니다.",
              style: new TextStyle(fontSize:20.0,
                  color: const Color(0xFF000000),
                  fontWeight: FontWeight.w200,
                  fontFamily: "Roboto"),
            ),
            Padding(padding: EdgeInsets.fromLTRB(0, 120, 0, 0)),
            Padding(
              padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                          IconButton(
                            onPressed: (){
                              ImagePicker().getImage(source: ImageSource.camera).then((value){
                                if(value!=null&&value.path!=null){
                                  print("저장경로 : ${value.path}");

                                  GallerySaver.saveImage(value.path).then((value){
                                    print("사진이 저장되었습니다");
                                  });
                                }
                              });


    //getImage(source:ImageSource.camera);
                            },
                            icon: Icon(
                                Icons.add_a_photo,
                                color: const Color(0xFF000000),
                                size: 48.0),
                          ),

                    IconButton(
                      onPressed: (){
                        getImage(ImageSource.gallery);
                      },
                      icon: Icon(
                          Icons.photo,
                          color: const Color(0xFF000000),
                          size: 48.0),
                    ),
                        ]

                    ),
            )
          ]
      ),

    );
  }
}
