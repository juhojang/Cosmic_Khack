import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:untitled20/showImage.dart';
import 'package:intl/intl.dart';
import 'package:advance_image_picker/advance_image_picker.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  ErrorWidget.builder = (FlutterErrorDetails details) {
    return ErrorWidget(details.exception);
  };
  runApp(new MyApp());
}
class MyApp extends StatelessWidget {


  @override
  Widget build(BuildContext context) {
    final configs = ImagePickerConfigs();
    configs.appBarTextColor = Colors.white;
    configs.appBarBackgroundColor = Colors.black;
    configs.backgroundColor==Colors.transparent;
    configs.translateFunc = (name, value) => Intl.message(value, name: name);
    configs.adjustFeatureEnabled = false;
    configs.externalImageEditors['external_image_editor_1'] = EditorParams(
        title: 'external_image_editor_1',
        icon: Icons.edit_rounded,
        onEditorEvent: (
            {required BuildContext context,
              required File file,
              required String title,
              int maxWidth = 1080,
              int maxHeight = 1920,
              int compressQuality = 90,
              ImagePickerConfigs? configs}) async =>
            Navigator.of(context).push(MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => ImageEdit(
                    file: file,
                    title: title,
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                    configs: configs))));
    configs.externalImageEditors['external_image_editor_2'] = EditorParams(
        title: 'external_image_editor_2',
        icon: Icons.edit_attributes,
        onEditorEvent: (
            {required BuildContext context,
              required File file,
              required String title,
              int maxWidth = 1080,
              int maxHeight = 1920,
              int compressQuality = 90,
              ImagePickerConfigs? configs}) async =>
            Navigator.of(context).push(MaterialPageRoute(
                fullscreenDialog: true,
                builder: (context) => ImageSticker(
                    file: file,
                    title: title,
                    maxWidth: maxWidth,
                    maxHeight: maxHeight,
                    configs: configs))));

    // Example about label detection & OCR extraction feature.
    // You can use Google ML Kit or TensorflowLite for this purpose
    configs.labelDetectFunc = (String path) async {
      return <DetectObject>[
        DetectObject(label: 'dummy1', confidence: 0.75),
        DetectObject(label: 'dummy2', confidence: 0.75),
        DetectObject(label: 'dummy3', confidence: 0.75)
      ];
    };
    configs.ocrExtractFunc =
        (String path, {bool? isCloudService = false}) async {
      if (isCloudService!) {
        return 'Cloud dummy ocr text';
      } else {
        return 'Dummy ocr text';
      }
    };

    // Example about custom stickers
    configs.customStickerOnly = true;
    configs.customStickers = [
      'assets/icon/cus1.png',
      'assets/icon/cus2.png',
      'assets/icon/cus3.png',
      'assets/icon/cus4.png',
      'assets/icon/cus5.png'
    ];
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
  List<ImageObject> _imgObjs = [];
  File? _image;
  //inal picker = ImagePicker();

  // 비동기 처리를 통해 카메라와 갤러리에서 이미지를 가져온다.
  /*Future getImage(ImageSource imageSource) async {
    final image = await picker.pickImage(source: imageSource);

    setState(() {
      _image = File(image!.path); // 가져온 이미지를 _image에 저장
    });
    Navigator.push(context, MaterialPageRoute(builder: (context) => showImage(_image)),);
  }*/

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
        title: new Text('Blur Blur',style: TextStyle(color:Colors.black,fontWeight: FontWeight.bold,fontSize: 25),),
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
            ToggleButtons(constraints:BoxConstraints(minWidth: 230.0, minHeight: 230.0),
                borderRadius: BorderRadius.circular(180),
                borderWidth: 5,
                disabledColor: Colors.grey,
                splashColor: Colors.green,
                highlightColor: Colors.green,
                focusColor: Colors.green,
                color: Colors.green,
                selectedColor: Colors.green,
                selectedBorderColor: Colors.green,
                hoverColor: Colors.green,
                children:[
              Icon(Icons.lock,size: 130,
              color: isSelected[0]?Colors.green:Colors.black12)],
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
              padding: EdgeInsets.fromLTRB(0, 20, 10, 0),
              child: new Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: <Widget>[
                          IconButton(
                            onPressed: ()async{
                              // Get max 5 images
                              final List<ImageObject>? objects = await Navigator.of(context)
                                  .push(PageRouteBuilder(pageBuilder: (context, animation, __) {
                                return const ImagePicker(mode:0,maxCount:10000);
                              }));

                              if ((objects?.length ?? 0) > 0) {
                                setState(() {
                                  _imgObjs = objects!;
                                });
                              }
                            },
                            icon: Icon(
                                Icons.enhance_photo_translate_outlined,
                                color: const Color(0xFF000000),
                                size: 48.0),
                          ),

                    IconButton(
                      onPressed: ()async{
                        // Get max 5 images
                        final List<ImageObject>? objects = await Navigator.of(context)
                            .push(PageRouteBuilder(pageBuilder: (context, animation, __) {
                          return const ImagePicker(mode:1,maxCount: 10000);
                        }));

                        if ((objects?.length ?? 0) > 0) {
                          setState(() {
                            _imgObjs = objects!;
                          });
                        }
                      },
                      icon: Icon(
                          Icons.photo_outlined,
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
