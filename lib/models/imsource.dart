//import 'package:mpocket/ffi/libmoc.dart' as libmoc;
import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:mpocket/common/global.dart';
import 'package:mpocket/ffi/libmoc.dart' as libmoc;
import 'package:mpocket/models/omusic_playing.dart';
import 'package:mpocket/views/index_usb.dart';


typedef NativePlayInfoCallback = Void Function(Pointer<Utf8>, Int, Pointer<Utf8>, Pointer<Utf8>);
typedef NativeServerClosedCallback = Void Function(Pointer<Utf8>, Int);
typedef NativeReceivingCallback = Void Function(Pointer<Utf8>, Pointer<Utf8>);
typedef NativeReceiveDoneCallback = Void Function(Pointer<Utf8>, Int);
typedef NativeUdiskMountCallback = Void Function(Pointer<Utf8>);

class IMsource extends ChangeNotifier {
  bool setting = false;
  OmusicPlaying? onListenTrack = null;
  late NativeCallable<NativePlayInfoCallback> callback;

  void bindPlayInfo() {
    print("bind PLAYINFO");
    void onResponse(Pointer<Utf8> client, int ok, Pointer<Utf8> errmsgPtr, Pointer<Utf8> responsePtr) {
      if (responsePtr != nullptr) {
        String response = responsePtr.cast<Utf8>().toDartString();
        print('on play INFO response ${response}');
        try {
          if (response != "null") {
            updateListenTrack(OmusicPlaying.fromJson(jsonDecode(response)));  
          }
        } catch (e) {
          //
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
}

class IMbanner extends ChangeNotifier {
  bool _isVisible = false;
  int _busyVisible = 0;
  String receivingFile = "";

  bool get isVisible => _isVisible;
  int get busyVisible => _busyVisible;

  void turnOnBanner() {
    _isVisible = true;
    notifyListeners();  
  }

  void turnOffBanner() {
    _isVisible = false;
    notifyListeners();  
  }

  void bindReceiving() {
    print("bind RECEIVING");
    late final  NativeCallable<NativeReceivingCallback> callback;

    void onResponse(Pointer<Utf8> id, Pointer<Utf8> filename) {
      try {
        String sname = filename.cast<Utf8>().toDartString();
        _busyVisible = 1;
        receivingFile = sname;
        notifyListeners();
      } catch (e) {
        print('xxxxxx FileReceiving filename decode failure');
      }
    }

    callback = NativeCallable<NativeReceivingCallback>.listener(onResponse);
    libmoc.mnetOnReceiving(callback.nativeFunction);
  }

  void bindFileReceived() {
    print("bind FILE RECEIVED");
    late final  NativeCallable<NativeReceivingCallback> callback;

    void onResponse(Pointer<Utf8> id, Pointer<Utf8> filename) {
      try {
        String sname = filename.cast<Utf8>().toDartString();

        _busyVisible = 2;
        receivingFile = sname;
        notifyListeners();
      } catch (e) {
        print('xxxxxx FileReceived filename decode failure');
      }
    }

    callback = NativeCallable<NativeReceivingCallback>.listener(onResponse);
    libmoc.mnetOnFileReceived(callback.nativeFunction);
  }

  void bindReceiveDone() {
    print("bind RECEIVE DONE");
    late final  NativeCallable<NativeReceiveDoneCallback> callback;

    void onResponse(Pointer<Utf8> id, int filecount) {
      print("receive DONE");
      _busyVisible = 3;
      receivingFile = filecount.toString();
      //callback.close();

      setClose();      

      notifyListeners();
    }

    callback = NativeCallable<NativeReceiveDoneCallback>.listener(onResponse);
    libmoc.mnetOnReceiveDone(callback.nativeFunction);
  }

  Future<void> setClose() async {
    await Future.delayed(Duration(seconds: 6), () {
      _busyVisible = 0;
      notifyListeners();
    });
  }

}

class IMonline extends ChangeNotifier {
  int online = 0;

  void onOnline(id) async {
    print("device ${id} ONLINE");
    online = 1;

    await libmoc.mnetStoreList(id);
    await libmoc.mnetStoreSync(id, Global.profile.defaultLibrary.isEmpty ? "默认媒体库" : Global.profile.defaultLibrary);
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

class IMnotify extends ChangeNotifier {
  BuildContext? _context;

  void setContext(BuildContext context) {
    _context = context;
  }

  void showUdiskMount() {
    if (_context == null) return;
    else showDialog(
      context: _context!, 
      builder: (context) {
        return AlertDialog(
          title: Text('U盘已连接'),
          content: Text('现在去同步媒体文件？'),
          actions: [
            TextButton(onPressed: (){Navigator.of(context).pop(); pickUSBFolder(context);}, child: Text('确定')),
            TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text('取消'), style: TextButton.styleFrom(foregroundColor: Colors.grey),)
          ]
        );
      }
    );
  }

  void bindUdiskMount() {
    print("bind USB MOUNT");
    late final NativeCallable<NativeUdiskMountCallback> callback;
    void onResponse(Pointer<Utf8> id) {
      print("usb mounted");
      showUdiskMount();
    }
    callback = NativeCallable<NativeUdiskMountCallback>.listener(onResponse);
    libmoc.mnetOnUdiskMount(callback.nativeFunction);
  }
}