# K해커톤 Blur Blur <demo>


### 의존성 명시
**pubspec.yaml** 에
```
  gallery_saver: ^2.3.2
  intl: ^0.17.0
  advance_image_picker: ^0.1.7+1
  image_editor_dove: ^0.0.2
  
```
를 추가하세요

### 권한 설정
**android\app\src\main\AndroidManifest.xml** 에
```
<manifest xmlns:android="http://schemas.android.com/apk/res/android"
    package="xxxxxxxx">
    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE"/>
   <application
```
를 추가하세요.

### 수정 버전 패키지 적용방법
패키지를 저희 앱에 맞게 수정하여 사용하였으므로 **오리지널 패키지를 적용할 경우 작동하지 않을 수 있습니다.**  
따라서 수정된 패키지의 적용이 필요합니다.  
각각의 수정할 다트파일의 위치를 알려드리겠습니다.  
```
image_picker : 각자의 flutter 주소\.pub-cache\hosted\pub.dartlang.org\advance_image_picker-0.1.7+1\lib\widgets\picker
media_album : 각자의 flutter 주소\.pub-cache\hosted\pub.dartlang.org\advance_image_picker-0.1.7+1\lib\widgets\picker
image_picker_configs : 각자의 flutter 주소\.pub-cache\hosted\pub.dartlang.org\advance_image_picker-0.1.7+1\lib\configs
camera_controller : 각자의 flutter 주소\.pub-cache\hosted\pub.dartlang.org\camera-0.9.8+1\lib\src
scroll_controller : 각자의 flutter 주소\packages\flutter\lib\src\widgets
sliding_segmented_control : 각자의 flutter 주소\packages\flutter\lib\src\cupertino
image_editor : 각자의 flutter 주소\.pub-cache\hosted\pub.dartlang.org\image_editor_dove-0.0.2\lib
```


## 텍스트 감지 코드 실행법

### 의존성 명시
**pubspec.yaml** 에
```
  google_ml_kit: ^0.12.0
  image_picker: ^0.8.5+3
  camera: ^0.10.0
```
를 추가하세요.

### 파이어베이스 연동
코드를 실행하기 위해서 **파이어베이스 연동**이 필요합니다.  
https://www.youtube.com/watch?v=EXp0gq9kGxI  
다음 동영상을 참고(8:50)하여 연동시켜주세요.  

### app 수준 build.gradle 수정
android>app>src>build.gradle에 들어가서 minSdkVersion을 21로 수정해주세요.  
```
    defaultConfig {
        // TODO: Specify your own unique Application ID (https://developer.android.com/studio/build/application-id.html).
        applicationId "xxxxxxxxxxxxx"
        // You can update the following values to match your application needs.
        // For more information, see: https://docs.flutter.dev/deployment/android#reviewing-the-build-configuration.
        minSdkVersion 21
        targetSdkVersion flutter.targetSdkVersion
        versionCode flutterVersionCode.toInteger()
        versionName flutterVersionName
    }
```

### 한국어 감지 설정
기본 감지설정이 영어로 되어있으므로 한국어로 수정해야 합니다.  
각자의 플러터주소\.pub-cache\hosted\pub.dartlang.org\google_ml_kit-0.12.0\lib\src  
안에있는 vision.dart의 47번째 줄
```
  TextRecognizer textRecognizer({script = TextRecognitionScript.latin}) {
    return TextRecognizer(script: script);
  }
```
에서 latin을 korean으로 수정시켜주세요.
