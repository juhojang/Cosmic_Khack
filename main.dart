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
      home: new MyHomePage(isSelected: [false]),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key ?key, required this.isSelected}) : super(key: key);
  List<bool> isSelected = [false];
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<ImageObject> _imgObjs = [];
  File? _image;

  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  var isSwitched=false;
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      key: _scaffoldKey,
      drawer: Drawer(
        backgroundColor: widget.isSelected[0]?Colors.greenAccent.shade200:Colors.white,
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding:EdgeInsets.fromLTRB(0, 29, 0, 0),
              child: Container(
                child: ListTile(
                  leading: Icon(
                    Icons.menu,
                    color: widget.isSelected[0]? Colors.white: Colors.black,
                  ),
                  title:Text('설 정',style: TextStyle(fontSize: 20),),
                ),
                decoration: BoxDecoration(
                  color: Colors.greenAccent.shade100,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.green.withOpacity(0.5),
                      spreadRadius: 5,
                      blurRadius: 7,
                      offset: Offset(0,3)
                    )
                  ],
                  borderRadius: BorderRadius.all(Radius.circular(50))
                ),
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
      body:
      Stack(
        children: [
          AnimatedContainer(
            width: widget.isSelected[0]? 1000: 1000,
            height: widget.isSelected[0]? 1000: 1000,
            color: widget.isSelected[0]? Colors.greenAccent: Colors.white,
            duration: Duration(seconds: 2),
            curve: Curves.fastLinearToSlowEaseIn,
          ),
          AnimatedContainer(
            width: widget.isSelected[0]? 300: 300,
            height: widget.isSelected[0]? 130: 130,
            color: widget.isSelected[0]? Colors.greenAccent: Colors.white,
            duration: Duration(seconds: 2),
            curve: Curves.fastLinearToSlowEaseIn,
            child: Row(
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(10,0,0,0),
                  child: IconButton(
                    icon: Icon(Icons.menu),
                    color: widget.isSelected[0]?Colors.white:Colors.black,
                    onPressed: (){
                      _scaffoldKey.currentState?.openDrawer();
                    },
                  ),
                ),
                Text("  B l u r   B l u r",style: TextStyle(fontStyle: FontStyle.normal,fontSize: 25,color:widget.isSelected[0]?Colors.white:Colors.black),)
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(10, 100, 0, 0),
            child: AnimatedContainer(
              width: widget.isSelected[0]? 390: 0,
              height: widget.isSelected[0]? 2: 2,
              color: widget.isSelected[0]? Colors.white: Colors.white,
              duration: Duration(seconds: 2),
              curve: Curves.fastLinearToSlowEaseIn,
            ),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.start,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(padding: EdgeInsets.fromLTRB(0, 230, 0, 0)),
              ToggleButtons(constraints:BoxConstraints(minWidth: 230.0, minHeight: 230.0),
                  borderRadius: BorderRadius.circular(180),
                  borderWidth: 5,
                  disabledColor: Colors.grey,
                  splashColor: Colors.green,
                  highlightColor: Colors.green,
                  focusColor: Colors.green,
                  color: Colors.green,
                  selectedColor: Colors.green,
                  selectedBorderColor: Colors.white,
                  hoverColor: Colors.green,
                  children:[
                Icon(widget.isSelected[0]?Icons.shield:Icons.heart_broken,size: 130,
                color: widget.isSelected[0]?Colors.white:Colors.black12)],
                  onPressed:(int index){setState(() {
                    widget.isSelected[index] = !widget.isSelected[index];
              });},
                  isSelected: widget.isSelected),
              Padding(padding: EdgeInsets.fromLTRB(0, 40, 0, 0)),
              Switch(
                value: widget.isSelected[0],
                onChanged: (value){
                  setState(() {
                    widget.isSelected[0]=value;
                  });
                },
                activeColor: Colors.green,
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 40, 0, 0)),
              widget.isSelected[0]?AnimatedOpacity(
                child: new Text(
                  "감지가 활성 상태입니다.",
                  style: new TextStyle(fontSize:25.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                      fontFamily: "Roboto"),
                ),
                opacity: 1,
                duration: Duration(seconds:1),
              ):AnimatedOpacity(
                child: Text(
                  "감지가 비활성 상태입니다.",
                  style: new TextStyle(fontSize:25.0,
                      color: const Color(0xFF000000),
                      fontWeight: FontWeight.w500,
                      fontFamily: "Roboto"),
                ),
                opacity: 0.3,
                duration: Duration(seconds: 1),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 30, 0, 0)),
              widget.isSelected[0]?AnimatedOpacity(
                child: new Text(
                  "n 개의 사진에 개인정보가 감지되었습니다.",
                  style: new TextStyle(fontSize:20.0,
                      color: Colors.white,
                      fontWeight: FontWeight.w200,
                      fontFamily: "Roboto"),
                ),
                opacity: 1,
                duration: Duration(seconds: 1),
              ):AnimatedOpacity(
                child: Text(
                  "활성화하여 개인정보를 보호하세요.",
                  style: new TextStyle(fontSize:20.0,
                      color: const Color(0xFF000000),
                      fontWeight: FontWeight.w200,
                      fontFamily: "Roboto"),
                ),
                opacity: 0.3,
                duration: Duration(seconds: 1),
              ),
              Padding(padding: EdgeInsets.fromLTRB(0, 100, 0, 0)),
              Padding(
                padding: EdgeInsets.fromLTRB(0, 20, 10, 0),
                child: new Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      widget.isSelected[0]?AnimatedOpacity(
                        child: IconButton(
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
                                    color: Colors.white,
                                    size: 48.0),
                              ),
                        opacity: 1,
                        duration: Duration(seconds: 1),
                      ):AnimatedOpacity(
                              child: IconButton(
                        onPressed: (){},
                        icon: Icon(
                              Icons.enhance_photo_translate_outlined,
                              color: Colors.white,
                              size: 48.0),
                      ),
                        opacity: 0.1,
                        duration: Duration(seconds:1),
                            ),

                      widget.isSelected[0]?AnimatedOpacity(
                        child: IconButton(
                          onPressed: ()async{
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
                              color: Colors.white,
                              size: 48.0),
                        ),
                        duration: Duration(seconds: 1),
                        opacity: 1,
                      ):AnimatedOpacity(
                        child: IconButton(
                          onPressed: (){},
                          icon: Icon(
                              Icons.photo_outlined,
                              color: Colors.white,
                              size: 48.0),
                        ),
                        opacity: 0.1,
                        duration: Duration(seconds: 1),
                      ),
                          ]

                      ),
              )
            ]
        )
        ],
      ),

    );
  }
}
