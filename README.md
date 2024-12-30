# mpocket

A new Flutter project.


### command

> flutter pub add xxx
> flutter packages pub run json_model  OR flutter pub run build_runner build
> flutter pub run build_runner build

> flutter build apk --release (对于依赖库，需要先 cd example/)
> 将生成的库文件拷贝至 C:\Users\DELL\Desktop\avm\mpocket\build\app\intermediates\stripped_native_libs\release\out\lib\ (三种架构都需要拷贝)
> 最后再 flutter install --release （默认删除旧版及内容后，重新安装）

### 更新常用版本
将 android/app/build.gradle applicationId 改为 com.example.mpocket022 ，编译生成的 app-release.apk 便是自用的 apk，
再用 adb install -r build/app/outputs/flutter-apk/app-release.apk 安装，即可保留原有数据，不用重新同步。
同时，为保持同步，请注意将 pubsec.yaml version 改为 0.2.2

> adb logcat

### TODO

1. 默认媒体库在 music_screen 中体现作用
2. 媒体库更新时，界面提示（现在需要等待29秒后，来回切换两次）