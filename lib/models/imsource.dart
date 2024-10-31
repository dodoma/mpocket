//import 'package:mpocket/ffi/libmoc.dart' as libmoc;
import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:mpocket/common/global.dart';
import 'package:mpocket/ffi/libmoc.dart' as libmoc;
import 'package:mpocket/models/omusic_playing.dart';

typedef NativePlayInfoCallback = Void Function(Pointer<Utf8>, Int, Pointer<Utf8>, Pointer<Utf8>);
typedef NativeServerClosedCallback = Void Function(Pointer<Utf8>, Int);

class IMsource extends ChangeNotifier {
  bool setting = false;
  bool showPlaying = false;
  OmusicPlaying? onListenTrack = null;
  late NativeCallable<NativePlayInfoCallback> callback;

  void bindPlayInfo() {
    print("bind PLAYINFO");
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
    libmoc.mnetPlayInfo(Global.profile.msourceID, callback.nativeFunction);
  }

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
}

class IMonline extends ChangeNotifier {
  int online = 0;

  void onOnline(id) async {
    print("device ${id} ONLINE");
    online = 1;

    await libmoc.mnetStoreList(id);
    await libmoc.mnetStoreSync(id, "默认媒体库");
  }

  void bindOffline() {
    late final NativeCallable<NativeServerClosedCallback> callback;

    void onResponse(Pointer<Utf8> id, int type) {
      String sid = id.cast<Utf8>().toDartString();
      print("flutter: server ${sid} ${type} closed");
      
      callback.close();
      bindOnline();

      online = 0;
      notifyListeners();      
    }
    callback = NativeCallable<NativeServerClosedCallback>.listener(onResponse);
    libmoc.mnetOnServerClosed(callback.nativeFunction);
    libmoc.mnetOnConnectionLost(callback.nativeFunction);
  }

  void bindOnline() {
    late final NativeCallable<NativeServerClosedCallback> callback;

    void onResponse(Pointer<Utf8> id, int type) {
      String sid = id.cast<Utf8>().toDartString();
      print("flutter: server ${sid} ${type} connected");
      
      callback.close();
      bindOffline();

      onOnline(sid);
      online = 1;
      notifyListeners();
    }
    callback = NativeCallable<NativeServerClosedCallback>.listener(onResponse);
    libmoc.mnetOnServerConnectted(callback.nativeFunction);
  }

}