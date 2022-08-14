import 'dart:io';
import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:advance_image_picker/widgets/picker/image_picker.dart';
import 'package:blurrycontainer/blurrycontainer.dart';

import 'dart:ui' as ui;

import 'extension/num_extension.dart';
import 'package:path_provider/path_provider.dart';
import 'package:screenshot/screenshot.dart';
import 'package:google_ml_kit/google_ml_kit.dart';
import 'package:blurrycontainer/blurrycontainer.dart';

import 'model/float_text_model.dart';
import 'widget/drawing_board.dart';
import 'widget/editor_panel_controller.dart';
import 'widget/float_text_widget.dart';
import 'widget/image_editor_delegate.dart';
import 'widget/text_editor_page.dart';


int faceNumber=0;
int ocrNumber=0;
List<Face> recognisedface=[];
List<Face> bluredface=[];
List<TextBlock> blocks=[];
bool eraseAccept=false;
bool textScanning=false;
bool isWorking=false;
int autoMosc=0;
List<TextElement> bluredOCR=[];



class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    var background = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth=3
      ..color = Colors.greenAccent
      ..isAntiAlias=true;
    for (int i =0;i<recognisedface.length;i++) {
      canvas.drawRect(
          recognisedface[i].boundingBox.topLeft/1.75+Offset(0,65) & recognisedface[i]
              .boundingBox.size/1.7, background);
    }
  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

class BackgroundPainter2 extends CustomPainter {
  BackgroundPainter2(this.elements);

  final List<TextElement> elements;
  @override
  void paint(Canvas canvas, Size size) {
    var background = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth=1
      ..color = Colors.greenAccent
      ..isAntiAlias=true;


    for(int i=0;i<elements.length;i++)
    {
      canvas.drawRect(
          elements[i].boundingBox.topLeft/1.75+Offset(0,65) & elements[i].boundingBox.size/1.7,background);
      print(elements[i]);
    }


  }
  @override
  bool shouldRepaint(CustomPainter oldDelegate) => true;
}

///The editor's result.
class EditorImageResult {
  ///image width
  final int imgWidth;

  ///image height
  final int imgHeight;

  ///new file after edit
  final File newFile;

  EditorImageResult(this.imgWidth, this.imgHeight, this.newFile);
}


class ImageEditor extends StatefulWidget {

  const ImageEditor({Key? key, required this.originImage, this.savePath}) : super(key: key);

  ///origin image
  /// * input for edit
  final File originImage;

  ///edited-file's save path.
  /// * if null will save in temporary file.
  final Directory? savePath;

  ///[uiDelegate] is determine the editor's ui style.
  ///You can extends [ImageEditorDelegate] and custome it by youself.
  static ImageEditorDelegate uiDelegate = DefaultImageEditorDelegate();

  @override
  State<StatefulWidget> createState() {
    return ImageEditorState();
  }
}

class ImageEditorState extends State<ImageEditor>
    with SignatureBinding, ScreenShotBinding, TextCanvasBinding, RotateCanvasBinding, LittleWidgetBinding, WindowUiBinding {
  final EditorPanelController _panelController = EditorPanelController();

  double get headerHeight => windowStatusBarHeight;

  double get bottomBarHeight => 85 + windowBottomBarHeight;

  ///Edit area height.
  double get canvasHeight => screenHeight - bottomBarHeight - headerHeight;

  ///Operation panel button's horizontal space.
  Widget get controlBtnSpacing => 5.hGap;

  List<TextElement> _elements =[];

  List<EntityType> filter=[EntityType.address,EntityType.email,EntityType.trackingNumber,EntityType.paymentCard,EntityType.phone,EntityType.unknown,EntityType.money,EntityType.dateTime];

  String scannedText="";

  bool done=false;


  void getRecognisedFace(File image) async{
    final inputImage=InputImage.fromFilePath(image.path);

    final FaceDetector=GoogleMlKit.vision.faceDetector();
    recognisedface=await FaceDetector.processImage(inputImage);
    faceNumber=recognisedface.length;
    await FaceDetector.close();

    final textDetector=GoogleMlKit.vision.textRecognizer();
    RecognizedText recognisedText=await textDetector.processImage(inputImage);

    scannedText="";

    for (TextBlock block in recognisedText.blocks){
      for(TextLine line in block.lines){
        scannedText=scannedText+line.text;
      }
    }

    List<EntityAnnotation> informationresult = await EntityExtractor(language: EntityExtractorLanguage.korean,).annotateText(scannedText,entityTypesFilter:filter );
    await textDetector.close();


    String email_pattern =
        r"^(([\w!-_\.])*@([\w!-_\.])*\.[\w]{2,3})$";

    String phoneNumber_pattern =
        r"^(?:(010-\d{4})|(01[1|6|7|8|9]-\d{3,4}))-(\d{4})$";

    String Name_pattern =
     r'^[가-힣]{2,4}$';

    String zoominbunho =
        r'^(?:[0-9]{2}(?:0[1-9]|1[0-2])(?:0[1-9]|[1,2][0-9]|3[0,1]))-[1-4][0-9]{6}$';

    String Zibunzooso =
        r'^(([가-힣A-Za-z·\d~\-\.]+(읍|동)\s)[\d-]+)|(([가-힣A-Za-z·\d~\-\.]+(읍|동)\s)[\d][^시]+)$';

    String doromyoung =
        r'^((([가-힣]+(\d{1,5}|\d{1,5}(,|.)\d{1,5}|)+(읍|면|동|가|리))(^구|)((\d{1,5}(~|-)\d{1,5}|\d{1,5})(가|리|)|))([](산(\d{1,5}(~|-)\d{1,5}|\d{1,5}))|)|(([가-힣]|(\d{1,5}(~|-)\d{1,5})|\d{1,5})+(로|길)))$';

    String woonjunmyunhu = r'^(\d{2}-\d{2}-\d{6}-\d{2})$';

    String tongjang = r"^(\d{2,6}[ -]-?\d{2,6}[ -]-?\d{2,6}[ -]-?\d{2,6})$";

    String card = r'^(\\d{4})-?(\\d{4})-?(\\d{4})-?(\\d{3,4})$';

    RegExp regEx = RegExp(phoneNumber_pattern);
    RegExp regEx2 = RegExp(email_pattern);
    RegExp regEx3 = RegExp(Name_pattern);
    RegExp regEx4 = RegExp(zoominbunho);
    RegExp regEx5 = RegExp(Zibunzooso);
    RegExp regEx6 = RegExp(doromyoung);
    RegExp regEx7 = RegExp(woonjunmyunhu);
    RegExp regEx8 = RegExp(tongjang);
    RegExp regEx9 = RegExp(card);




    for (TextBlock block in recognisedText.blocks) {
      for (TextLine line in block.lines) {
        for(int i=0;i<informationresult.length;i++)
        {
          if (RegExp(informationresult[i].text).hasMatch(line.text)) {
            for (TextElement element in line.elements) {
              _elements.add(element);
            }
            done=true;
        }
        }

        if(done)
          {
            done=false;
            continue;
          }


        if (regEx.hasMatch(line.text)) {
          for (TextElement element in line.elements) {
            _elements.add(element);
          }
        }

        else if (regEx2.hasMatch(line.text)) {
          for (TextElement element in line.elements) {
            _elements.add(element);
          }

        }
        else if (regEx3.hasMatch(line.text)) {
          for (TextElement element in line.elements) {
            _elements.add(element);
          }
        }

        else if (regEx4.hasMatch(line.text)) {
          for (TextElement element in line.elements) {
            _elements.add(element);
          }
        }
        else if (regEx5.hasMatch(line.text)) {
          for (TextElement element in line.elements) {
            _elements.add(element);
          }
        }
        else if (regEx6.hasMatch(line.text)) {

          for (TextElement element in line.elements) {
            _elements.add(element);
          }
        }
        else if (regEx7.hasMatch(line.text)) {

          for (TextElement element in line.elements) {
            _elements.add(element);
          }
        }
        else if (regEx8.hasMatch(line.text)) {

          for (TextElement element in line.elements) {
            _elements.add(element);
          }
        }
        else if (regEx9.hasMatch(line.text)) {
          for (TextElement element in line.elements) {
            _elements.add(element);
          }
        }
      }
    }

    ocrNumber=_elements.length;
    print(_elements);
    textScanning=false;
    setState(() {

    });
  }

  Widget blurFace(int i){
    return Positioned(
      top: bluredface[i].boundingBox.topRight.dy/1.75+65,
      left: bluredface[i].boundingBox.topLeft.dx/1.75,
      child: BlurryContainer(
        width: bluredface[i].boundingBox.width/1.7,
        height: bluredface[i].boundingBox.height/1.7,
        child: Container(),
        color: Colors.white.withOpacity(0.10),
        blur: 5,
      ),
    );
  }
  Widget blurOCR(int i){
    return Positioned(
      top: bluredOCR[i].boundingBox.topRight.dy/1.75+65,
      left: bluredOCR[i].boundingBox.topLeft.dx/1.75,
      child: BlurryContainer(
        width: bluredOCR[i].boundingBox.width/1.7,
        height: bluredOCR[i].boundingBox.height/1.7,
        child: Container(),
        color: Colors.white.withOpacity(0.10),
        blur: 5,
      ),
    );
  }

  ///Save the edited-image to [widget.savePath] or [getTemporaryDirectory()].
  void SaveImage() {
    _panelController.takeShot.value = true;
    screenshotController.capture(pixelRatio: 1).then((value) async {
      final paths = widget.savePath ?? await getTemporaryDirectory();
      print(paths);
      final file = await File('${paths.path}/' + DateTime.now().toString() + '.jpg').create();
      file.writeAsBytes(value ?? []);
      decodeImg().then((value) {
        if (value == null) {
          Navigator.pop(context);
        } else {
          GallerySaver.saveImage(file.path);
          Navigator.push(
              context,
              MaterialPageRoute(builder:(context)=>ImagePicker(mode:1,maxCount: 10000)));

        }
      }).catchError((e) {
        Navigator.pop(context);
      });
    });
  }

  Future<ui.Image?> decodeImg() async {
    return await decodeImageFromList(widget.originImage.readAsBytesSync());
  }

  static ImageEditorState? of(BuildContext context) {
    return context.findAncestorStateOfType<ImageEditorState>();
  }


  @override
  void initState() {
    super.initState();
    initPainter();
    _panelController.switchOperateType(OperateType.brush);
    getRecognisedFace(widget.originImage);
    bluredface=[];
    bluredOCR=[];
    autoMosc=0;
  }


  @override
  Widget build(BuildContext context) {

    print(recognisedface);
    _panelController.screenSize ??= windowSize;
    return Material(
      color: Colors.white,
      child: Listener(
        onPointerMove: (v) {
          _panelController.pointerMoving(v);
        },
        child: Screenshot(
          controller: screenshotController,
          child: Stack(
            children: [
              Positioned.fromRect(
                  rect: Rect.fromLTWH(0, headerHeight, screenWidth, canvasHeight),
                  child: RotatedBox(
                    quarterTurns: rotateValue,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        _buildImage(),
                      ],
                    ),
                  )),

              for (int i =0;i<bluredface.length;i++) blurFace(i),
              for (int i =0;i<bluredOCR.length;i++) blurOCR(i),
              Container(
                  width: 1000,
                  height: 1000,
                  color: Colors.transparent,
                  child: Listener(
                    onPointerMove: (event2){
                      print("working");
                      Face? targetFace;
                      TextElement? targetOCR;

                      for (int i =0;i<faceNumber;i++) {
                        if(i<recognisedface.length)
                        {
                          if(event2.localPosition.dx>(recognisedface[i].boundingBox.topLeft.dx/1.75)&&event2.localPosition.dx<(recognisedface[i].boundingBox.bottomRight.dx/1.75))
                          {
                            if(event2.localPosition.dy<(recognisedface[i].boundingBox.bottomRight.dy/1.75+65)&&event2.localPosition.dy>(recognisedface[i].boundingBox.topLeft.dy/1.75+65))
                            {
                              targetFace=recognisedface[i];
                              break;
                            }
                          }
                        }
                        else{
                          if(event2.localPosition.dx>(bluredface[i-recognisedface.length].boundingBox.topLeft.dx/1.75)&&event2.localPosition.dx<(bluredface[i-recognisedface.length].boundingBox.bottomRight.dx/1.75))
                          {
                            if(event2.localPosition.dy<(bluredface[i-recognisedface.length].boundingBox.bottomRight.dy/1.75+65)&&event2.localPosition.dy>(bluredface[i-recognisedface.length].boundingBox.topLeft.dy/1.75+65))
                            {
                              targetFace=bluredface[i-recognisedface.length];
                              break;
                            }
                          }

                        }
                      }
                      for (int i =0;i<ocrNumber;i++) {
                        if(i<_elements.length)
                        {
                          if(event2.localPosition.dx>(_elements[i].boundingBox.topLeft.dx/1.75)&&event2.localPosition.dx<(_elements[i].boundingBox.bottomRight.dx/1.75))
                          {
                            if(event2.localPosition.dy<(_elements[i].boundingBox.bottomRight.dy/1.75+65)&&event2.localPosition.dy>(_elements[i].boundingBox.topLeft.dy/1.75+65))
                            {
                              targetOCR=_elements[i];
                              break;
                            }
                          }
                        }
                        else{
                          if(event2.localPosition.dx>(bluredOCR[i-_elements.length].boundingBox.topLeft.dx/1.75)&&event2.localPosition.dx<(bluredOCR[i-_elements.length].boundingBox.bottomRight.dx/1.75))
                          {
                            if(event2.localPosition.dy<(bluredOCR[i-_elements.length].boundingBox.bottomRight.dy/1.75+65)&&event2.localPosition.dy>(bluredOCR[i-_elements.length].boundingBox.topLeft.dy/1.75+65))
                            {
                              targetOCR=bluredOCR[i-_elements.length];
                              break;
                            }
                          }

                        }
                      }
                      if(targetFace!=null){
                        if(event2.localPosition.dx>(targetFace.boundingBox.topLeft.dx/1.75)&&event2.localPosition.dx<(targetFace.boundingBox.bottomRight.dx/1.75))
                          if(event2.localPosition.dy>(targetFace.boundingBox.bottomRight.dy/1.75+65)&&event2.localPosition.dy<(targetFace.boundingBox.topLeft.dy/1.75+65))
                          {
                            eraseAccept=false;
                          }
                          else{
                            eraseAccept=true;
                          }

                        if(eraseAccept)
                        {
                          eraseAccept=false;
                          faceNumber=faceNumber-1;
                          setState(() {
                            recognisedface.remove(targetFace);
                            bluredface.remove(targetFace);
                            print("remove");
                          });

                        }
                      }
                      if(targetOCR!=null){
                        if(event2.localPosition.dx>(targetOCR.boundingBox.topLeft.dx/1.75)&&event2.localPosition.dx<(targetOCR.boundingBox.bottomRight.dx/1.75))
                          if(event2.localPosition.dy>(targetOCR.boundingBox.bottomRight.dy/1.75+65)&&event2.localPosition.dy<(targetOCR.boundingBox.topLeft.dy/1.75+65))
                          {
                            eraseAccept=false;
                          }
                          else{
                            eraseAccept=true;
                          }

                        if(eraseAccept)
                        {
                          eraseAccept=false;
                          ocrNumber=ocrNumber-1;
                          setState(() {
                            _elements.remove(targetOCR);
                            bluredOCR.remove(targetOCR);
                            print("remove");
                          });

                        }
                      }
                    },
                    onPointerDown: (event){
                      for (int i =0;i<faceNumber;i++) {
                        if(i<recognisedface.length)
                        {
                          if(event.localPosition.dx>(recognisedface[i].boundingBox.topLeft.dx/1.75)&&event.localPosition.dx<(recognisedface[i].boundingBox.bottomRight.dx/1.75))
                          {
                            if(event.localPosition.dy<(recognisedface[i].boundingBox.bottomRight.dy/1.75+65)&&event.localPosition.dy>(recognisedface[i].boundingBox.topLeft.dy/1.75+65))
                            {
                              setState(() {
                                bluredface.add(recognisedface[i]);
                                recognisedface.remove(recognisedface[i]);
                              });
                              break;
                            }
                          }
                        }
                        else{
                          if(event.localPosition.dx>(bluredface[i-recognisedface.length].boundingBox.topLeft.dx/1.75)&&event.localPosition.dx<(bluredface[i-recognisedface.length].boundingBox.bottomRight.dx/1.75))
                          {
                            if(event.localPosition.dy<(bluredface[i-recognisedface.length].boundingBox.bottomRight.dy/1.75+65)&&event.localPosition.dy>(bluredface[i-recognisedface.length].boundingBox.topLeft.dy/1.75+65))
                            {
                              setState(() {
                                recognisedface.add(bluredface[i-recognisedface.length]);
                                bluredface.remove(bluredface[i-recognisedface.length+1]);
                              });
                              break;
                            }
                          }

                        }
                      }
                      for (int i =0;i<ocrNumber;i++) {
                        if(i<_elements.length)
                        {
                          if(event.localPosition.dx>(_elements[i].boundingBox.topLeft.dx/1.75)&&event.localPosition.dx<(_elements[i].boundingBox.bottomRight.dx/1.75))
                          {
                            if(event.localPosition.dy<(_elements[i].boundingBox.bottomRight.dy/1.75+65)&&event.localPosition.dy>(_elements[i].boundingBox.topLeft.dy/1.75+65))
                            {
                              setState(() {
                                bluredOCR.add(_elements[i]);
                                _elements.remove(_elements[i]);
                              });
                              break;
                            }
                          }
                        }
                        else{
                          if(event.localPosition.dx>(bluredOCR[i-_elements.length].boundingBox.topLeft.dx/1.75)&&event.localPosition.dx<(bluredOCR[i-_elements.length].boundingBox.bottomRight.dx/1.75))
                          {
                            if(event.localPosition.dy<(bluredOCR[i-_elements.length].boundingBox.bottomRight.dy/1.75+65)&&event.localPosition.dy>(bluredOCR[i-_elements.length].boundingBox.topLeft.dy/1.75+65))
                            {
                              setState(() {
                                _elements.add(bluredOCR[i-_elements.length]);
                                bluredOCR.remove(bluredOCR[i-_elements.length+1]);
                              });
                              break;
                            }
                          }

                        }
                      }
                    },

                    child: Stack(children:[
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          _buildBrushCanvas(),
                          //buildTextCanvas(),
                        ],
                      ),
                      CustomPaint(
                        painter:BackgroundPainter(),
                      ),
                      CustomPaint(
                        painter:BackgroundPainter2(_elements),
                      )
                    ]),
                  )
              ),

              ValueListenableBuilder<bool>(
                  valueListenable: _panelController.showAppBar,
                  builder: (ctx, value, child) {
                    return AnimatedPositioned(
                        top: value ? 0 : -headerHeight,
                        left: 0, right: 0,
                        child: ValueListenableBuilder<bool>(
                            valueListenable: _panelController.takeShot,
                            builder: (ctx, value, child) {
                              return Opacity(
                                opacity: value ? 0 : 1,
                                child: AppBar(
                                  elevation: 0,
                                  iconTheme: IconThemeData(color: Colors.white, size: 16),
                                  leading: backWidget(),
                                  backgroundColor: Colors.transparent,
                                  actions: [
                                    doneButtonWidget(onPressed: SaveImage),
                                  ],
                                ),
                              );
                            }),
                        duration: _panelController.panelDuration);
                  }),
              ValueListenableBuilder<bool>(
                  valueListenable: _panelController.showBottomBar,
                  builder: (ctx, value, child) {
                    return AnimatedPositioned(
                        bottom: value ? 0 : -bottomBarHeight,
                        child: SizedBox(
                          width: screenWidth,
                          child: ValueListenableBuilder<bool>(
                              valueListenable: _panelController.takeShot,
                              builder: (ctx, value, child) {
                                return Opacity(
                                  opacity: value ? 0 : 1,
                                  child: _buildControlBar(),
                                );
                              }),
                        ),
                        duration: _panelController.panelDuration);
                  }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildControlBar() {
    return Container(
      color: Colors.transparent,
      width: screenWidth,
      height: bottomBarHeight,
      padding: EdgeInsets.only(left: 16, right: 16, bottom: windowBottomBarHeight),
      child: Row(
        children: [
          Expanded(
            child: Row(
              children: [
                Padding(
                  padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                  child : _buildButton(OperateType.mosaic, '수동 모자이크', onPressed: () {
                    if(painterController.drawStyle!=DrawStyle.mosaic)
                    {
                      setState(() {
                        switchPainterMode(DrawStyle.mosaic);
                      });
                    }
                    else{
                      setState(() {
                        switchPainterMode(DrawStyle.non);
                      });
                    }
                  }
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: Row(
              children: [ Padding(
                padding: EdgeInsets.fromLTRB(30, 0, 0, 0),
                child : _buildButton(OperateType.autoMasaic, '자동 모자이크', onPressed: () {
                  autoMosc=autoMosc+1;
                  print(autoMosc);
                  if(autoMosc%2==1)
                  {
                    for(int i=0;i<faceNumber;i++) {
                      bluredface.add(recognisedface[0]);
                      recognisedface.remove(recognisedface[0]);
                    }
                    for(int i=0;i<ocrNumber;i++) {
                      bluredOCR.add(_elements[0]);
                      _elements.remove(_elements[0]);
                    }
                    setState(() {
                    });
                  }
                  else{
                    for(int i=0;i<faceNumber;i++) {
                      recognisedface.add(bluredface[0]);
                      bluredface.remove(bluredface[0]);
                    }
                    for(int i=0;i<ocrNumber;i++) {
                      _elements.add(bluredOCR[0]);
                      bluredOCR.remove(bluredOCR[0]);
                    }
                    setState(() {
                    });
                  }
                }
                ),
              ),
              ],
            ),
          ),
          Expanded(
            child: ValueListenableBuilder<OperateType>(
              valueListenable: _panelController.operateType,
              builder: (ctx, value, child) {
                return Opacity(
                  opacity: _panelController.show2ndPanel() ? 1 : 1,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                          padding: EdgeInsets.fromLTRB(0, 0, 10, 0),
                          child:
                          IconButton(onPressed:undo,
                            icon: Icon(Icons.arrow_back_ios),color: Colors.greenAccent,))

                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImage() {
    return Transform(
      alignment: Alignment.center,
      transform: Matrix4.rotationY(flipValue),
      child: Container(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        alignment: Alignment.center,
        child: Image.file(widget.originImage,fit: BoxFit.fitWidth,height: double.infinity,width: double.infinity,),
      ),
    );
  }

  Widget _buildTrashCan() {
    return ValueListenableBuilder<Color>(
        valueListenable: _panelController.trashColor,
        builder: (ctx, value, child) {
          final bool isActive = value.value == EditorPanelController.defaultTrashColor.value;
          return Container(
            width: _panelController.tcSize.width,
            height: _panelController.tcSize.height,
            decoration: BoxDecoration(
                color: value,
                borderRadius: BorderRadius.all(Radius.circular(8))
            ),
            child: Column(
              children: [
                12.vGap,
                Icon(Icons.delete_outline, size: 32, color: Colors.white,),
                4.vGap,
                Text(isActive ? 'move here for delete' : 'release to delete',
                  style: TextStyle(color: Colors.white, fontSize: 12),)
              ],
            ),
          );
        });
  }

  Widget _buildButton(OperateType type, String txt, {VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: () {
        if(_panelController.isCurrentOperateType(type))
        {
          _panelController.switchOperateType(OperateType.brush);
        }
        else{
          _panelController.switchOperateType(type);
        }
        onPressed?.call();
      },
      child: ValueListenableBuilder(
        valueListenable: _panelController.operateType,
        builder: (ctx, value, child) {
          return SizedBox(
            width: 71,
            height: 41,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                getOperateTypeRes(type, choosen: _panelController.isCurrentOperateType(type)),
                Text(
                  txt,
                  style: TextStyle(
                      color: _panelController.isCurrentOperateType(type)
                          ? Colors.greenAccent : Colors.grey, fontSize: 11),
                )
              ],
            ),
          );
        },
      ),
    );
  }


}

///Little widget binding is for unified manage the widgets that has common style.
/// * If you wanna custom this part, see [ImageEditorDelegate]
mixin LittleWidgetBinding<T extends StatefulWidget> on State<T> {

  ///go back widget
  Widget backWidget({VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed ?? () {
        Navigator.pop(context);
      },
      child: ImageEditor.uiDelegate.buildBackWidget(),
    );
  }

  ///operation button in control bar
  Widget getOperateTypeRes(OperateType type, {required bool choosen}) {
    return ImageEditor.uiDelegate.buildOperateWidget(type, choosen: choosen);
  }

  ///action done widget
  Widget doneButtonWidget({VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: ImageEditor.uiDelegate.buildDoneWidget(),
    );
  }

  ///undo action
  Widget unDoWidget({VoidCallback? onPressed}) {
    return GestureDetector(
      onTap: onPressed,
      child: ImageEditor.uiDelegate.buildUndoWidget(),
    );
  }

  ///Ignore pointer evenet by [OperateType]
  Widget ignoreWidgetByType(OperateType type, Widget child) {
    return ValueListenableBuilder(
        valueListenable: realState?._panelController.operateType ?? ValueNotifier(OperateType.non),
        builder: (ctx, type, c) {
          return IgnorePointer(
            ignoring: type != OperateType.brush && type != OperateType.mosaic,
            child: child,
          );
        });
  }

  ///reset button
  Widget resetWidget({VoidCallback? onTap}) {
    return Padding(
      padding: EdgeInsets.only(top: 6, bottom: 6 , right: 16),
      child: ValueListenableBuilder<OperateType>(
        valueListenable: realState?._panelController.operateType ?? ValueNotifier(OperateType.non),
        builder: (ctx, value, child) {
          return Offstage(
            offstage: value != OperateType.rotated,
            child: GestureDetector(
              onTap: onTap,
              child: ImageEditor.uiDelegate.resetWidget,
            ),);
        },
      ),
    );
  }

}

///This binding can make editor to roatate canvas
/// * for now, the paint-path,will change his relative position of canvas
/// * when canvas rotated. because the paint-path area it's full canvas and
/// * origin image is not maybe. if force to keep the relative path, will reduce
/// * the paint-path area.
mixin RotateCanvasBinding<T extends StatefulWidget> on State<T> {

  ///canvas rotate value
  /// * 90 angle each time.
  int rotateValue = 0;

  ///canvas flip value
  /// * 180 angle each time.
  double flipValue = 0;

  ///flip canvas
  void flipCanvas() {
    flipValue = flipValue == 0 ? math.pi : 0;
    setState(() {});
  }

  ///routate canvas
  /// * will effect image, text, drawing board
  void rotateCanvasPlate() {
    rotateValue++;
    setState(() {});
  }

  ///reset canvas
  void resetCanvasPlate() {
    rotateValue = 0;
    setState(() {

    });
  }

}

///text painting
mixin TextCanvasBinding<T extends StatefulWidget> on State<T> {
  late StateSetter textSetter;

  final List<FloatTextModel> textModels = [];

  void addText(FloatTextModel model) {
    textModels.add(model);
    refreshTextCanvas();
  }

  ///delete a text from canvas
  void deleteTextWidget(FloatTextModel target) {
    textModels.remove(target);
    refreshTextCanvas();
  }

  void toTextEditorPage() {
    realState?._panelController.hidePanel();
    Navigator.of(context)
        .push(PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, Animation<double> animation, Animation<double> secondaryAnimation) {
          return TextEditorPage();
        }))
        .then((value) {
      realState?._panelController.showPanel();
      if (value is FloatTextModel) {
        addText(value);
      }
    });
  }

  void refreshTextCanvas() {
    textSetter.call(() {});
  }

  Widget buildTextCanvas() {
    return StatefulBuilder(builder: (tCtx, setter) {
      textSetter = setter;
      return Stack(
        alignment: Alignment.center,
        children: textModels
            .map<Widget>((e) => Positioned(
          child: _wrapWithGesture(
              FloatTextWidget(
                textModel: e,
              ),
              e),
          left: e.left,
          top: e.top,
        ))
            .toList(),
      );
    });
  }

  Widget _wrapWithGesture(Widget child, FloatTextModel model) {
    void pointerDetach(DragEndDetails? details) {
      if (details != null) {
        //touch event up
        realState?._panelController.releaseText(details, model, () {
          deleteTextWidget(model);
        });
      } else {
        //touch event cancel
        realState?._panelController.doIdle();
      }
      model.isSelected = false;
      refreshTextCanvas();
      realState?._panelController.showPanel();
    }

    return GestureDetector(
      child: child,
      onPanStart: (_) {
        realState?._panelController.moveText(model);
      },
      onPanUpdate: (details) {
        model.isSelected = true;
        model.left += details.delta.dx;
        model.top += details.delta.dy;
        refreshTextCanvas();
        realState?._panelController.hidePanel();
      },
      onPanEnd: (d) {
        pointerDetach(d);
      },
      onPanCancel: () {
        pointerDetach(null);
      },
    );
  }
}

///drawing board
mixin SignatureBinding<T extends StatefulWidget> on State<T> {

  DrawStyle get lastDrawStyle => painterController.drawStyle;

  ///Canvas layer for each draw action action.
  /// * e.g. First draw some path with white color, than change the color and draw some path again.
  /// * After this [pathRecord] will save 2 layes in it.
  final List<Widget> pathRecord = [];

  late StateSetter canvasSetter;

  ///painter stroke width.
  double pStrockWidth = 5;

  ///painter color
  Color pColor = Colors.transparent;

  ///painter controller
  late SignatureController painterController;

  @override
  void initState() {
    super.initState();
    pColor = Color(realState?._panelController.colorSelected.value ?? Colors.yellow.value);
  }

  ///switch painter's style
  /// * e.g. color、mosaic
  void switchPainterMode(DrawStyle style) {
    if(lastDrawStyle == style) return;
    changePainterColor(pColor);
    painterController.drawStyle = style;
  }

  ///change painter's color
  void changePainterColor(Color color) async {
    pColor = color;
    realState?._panelController.selectColor(color);
    pathRecord.insert(
        0,
        RepaintBoundary(
          child: CustomPaint(
              painter: SignaturePainter(painterController),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                    minWidth: double.infinity, minHeight: double.infinity, maxWidth: double.infinity, maxHeight: double.infinity),
              )),
        ));
    //savePath();
    initPainter();
    _refreshBrushCanvas();
  }

  void _refreshBrushCanvas() {
    pathRecord.removeLast();
    //add new layer.
    pathRecord.add(Signature(
      controller: painterController,
      backgroundColor: Colors.transparent,
    ));
    _refreshCanvas();
  }

  ///undo last drawing.
  void undo() {
    painterController.undo();
  }

  ///refresh canvas.
  void _refreshCanvas() {
    canvasSetter(() {});
  }

  void initPainter() {
    painterController = SignatureController(penStrokeWidth: pStrockWidth, penColor: pColor);
  }

  Widget _buildBrushCanvas() {
    if (pathRecord.isEmpty) {
      pathRecord.add(Signature(
        controller: painterController,
        backgroundColor: Colors.transparent,
      ));
    }
    return StatefulBuilder(builder: (ctx, canvasSetter) {
      this.canvasSetter = canvasSetter;
      return realState?.ignoreWidgetByType(OperateType.brush, Stack(
        children: pathRecord,
      )) ?? SizedBox();
    });
  }

  @override
  void dispose() {
    pathRecord.clear();
    super.dispose();
  }
}

mixin ScreenShotBinding<T extends StatefulWidget> on State<T> {
  final ScreenshotController screenshotController = ScreenshotController();
}

///information about window
mixin WindowUiBinding<T extends StatefulWidget> on State<T> {

  Size get windowSize => MediaQuery.of(context).size;

  double get windowStatusBarHeight => ui.window.padding.top;

  double get windowBottomBarHeight => ui.window.padding.bottom;

  double get screenWidth => windowSize.width;

  double get screenHeight => windowSize.height;

}

extension _BaseImageEditorState on State {
  ImageEditorState? get realState {
    if (this is ImageEditorState) {
      return this as ImageEditorState;
    }
    return null;
  }
}

///the color selected.
typedef OnColorSelected = void Function(Color color);

class CircleColorWidget extends StatefulWidget {
  final Color color;

  final ValueNotifier<int> valueListenable;

  final OnColorSelected onColorSelected;

  const CircleColorWidget({Key? key, required this.color, required this.valueListenable, required this.onColorSelected}) : super(key: key);

  @override
  State<StatefulWidget> createState() {
    return CircleColorWidgetState();
  }
}

class CircleColorWidgetState extends State<CircleColorWidget> {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onColorSelected(widget.color);
      },
      child: ValueListenableBuilder<int>(
        valueListenable: widget.valueListenable,
        builder: (ctx, value, child) {
          final double size = value == widget.color.value ? 25 : 21;
          return Container(
            width: size,
            height: size,
            decoration: BoxDecoration(
              border: Border.all(color: Colors.white, width: value == widget.color.value ? 4 : 2),
              shape: BoxShape.circle,
              color: widget.color,
            ),
          );
        },
      ),
    );
  }


}


