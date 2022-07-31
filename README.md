# K해커톤 Blur Blur <demo>


### 의존성 명시
**pubspec.yaml** 에
```
  gallery_saver: ^2.3.2
  intl: ^0.17.0
  advance_image_picker: ^0.1.7+1
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
```
