//import 'package:mpocket/ffi/libmoc.dart' as libmoc;
import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:mpocket/common/global.dart';
import 'package:mpocket/ffi/libmoc.dart' as libmoc;
import 'package:mpocket/models/omusic_playing.dart';



typedef NativePlayInfoCallback = Void Function(Pointer<Utf8>, Int, Pointer<Utf8>, Pointer<Utf8>);

class IMsource extends ChangeNotifier {
  String deviceID = "";
  bool setting = false;
  bool showPlaying = false;
  bool binded = false;
  OmusicPlaying? onListenTrack = null;

  void updateListenTrack(OmusicPlaying track) {
    onListenTrack = track;
    onListenTrack!.cover = Global.profile.storeDir + "assets/cover/" + track.id;
    notifyListeners();
  }

  void turnOffPlaying() {
    showPlaying = false;
    notifyListeners();
  }

  void turnOnPlaying() {
    showPlaying = true;
    notifyListeners();
  }

  void deviceOnline (String id) async {
    deviceID = id;
    
    await libmoc.mnetStoreList(deviceID);
    await libmoc.mnetStoreSync(deviceID, "默认媒体库");

    if (!binded) {
      binded = true;
      bindPlayInfo();
    }
  }

  void bindPlayInfo() {
    print("bind PLAYINFO");
    late final NativeCallable<NativePlayInfoCallback> callback;
    void onResponse(Pointer<Utf8> client, int ok, Pointer<Utf8> errmsgPtr, Pointer<Utf8> responsePtr) {
      if (responsePtr != nullptr) {
        String response = responsePtr.cast<Utf8>().toDartString();
        print('on play INFO response ${response}');
        if (response != "null") {
          updateListenTrack(OmusicPlaying.fromJson(jsonDecode(response)));  
          turnOnPlaying();
        }
      }
      //callback.close();
    }
    callback = NativeCallable<NativePlayInfoCallback>.listener(onResponse);
    libmoc.mnetPlayInfo(deviceID, callback.nativeFunction);
  }
}
