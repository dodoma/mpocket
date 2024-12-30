//import 'package:mpocket/ffi/libmoc.dart' as libmoc;
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:audio_metadata_extractor/audio_metadata_extractor.dart';
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:mpocket/common/global.dart';
import 'package:mpocket/ffi/libmoc.dart' as libmoc;

class IMlocal extends ChangeNotifier {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final random = Random();
  Duration duration = Duration.zero;
  Duration position = Duration.zero;
  bool shuffle = true;
  double volume = 0.6;

  IMlocal() {
    _audioPlayer.setVolume(volume);
    
    _audioPlayer.durationStream.listen((Duration? d) {
      if (d != null) {
        duration = d;
        notifyListeners();
      }
    });
  
    _audioPlayer.positionStream.listen((Duration d) {
      position = d;
      notifyListeners();
    });

    _audioPlayer.processingStateStream.listen((state) async {
      if (state == ProcessingState.completed) {
        print("play done. next");

        String id = idNext();
        String url = await getURLbyID(id);
        if (url.isNotEmpty) {
          print("Play ${url}");
          await _audioPlayer.setFilePath(url);
          _audioPlayer.play();
        } else {
          // 播放完成后，默认会播放媒体库
          String idxx = libmoc.omusicLibraryID(Global.profile.msourceID);
          if (idxx.isNotEmpty) {
            url = await getURLbyID(idxx);
            if (url.isNotEmpty) {
              print("Play ${url}");
              await _audioPlayer.setFilePath(url);
              _audioPlayer.play();
            }
          } else {
            print("nothing to do");
          }
        }
      }
    });
  }
  
  @override
  void dispose() {
    _audioPlayer.dispose();
    super.dispose();
  }

  String? onListenURL = null;
  String? onListenCover = null;
  AudioMetadata? onListenTrack = null;
  List<String> trackIDS = [];
  List<String> listendTracks = [];

  Future<void> playSingle(BuildContext context, String id, bool addhistory) async {
    String url = libmoc.omusicLocation(Global.profile.msourceID, id);
    if (url.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('获取文件资源失败'),
          duration: Duration(seconds: 3)
        )
      );
    } else if (url == "ENOENT") {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('该文件没缓存至手机?'),
          duration: Duration(seconds: 3)
        )
      );
    } else {      
      if (addhistory && !listendTracks.contains(id)) listendTracks.add(id);

      await _audioPlayer.stop();

      onListenURL = url;
      onListenCover = Global.profile.storeDir + "assets/cover/" + id;
      onListenTrack = await AudioMetadata.extract(File(url));

      await _audioPlayer.setFilePath(url);
      _audioPlayer.play(); //不能等待play()完成, 否则会完成后再通知UI, 报错 "Looking up a deactivated widget's ancestor is unsafe."

      notifyListeners();
    }
  }

  Future<String> getURLbyID(String id) async {
    if (id.isEmpty) return "";

    String url = libmoc.omusicLocation(Global.profile.msourceID, id);
    if (url.isEmpty) {
      print("url empty");
    } else if (url == "ENOENT") {
      print("url empty");
    } else {
      onListenURL = url;
      onListenCover = Global.profile.storeDir + "assets/cover/" + id;
      onListenTrack = await AudioMetadata.extract(File(url));

      notifyListeners();

      return url;
    }

    return "";
  }

  Future<void> playAlbum(BuildContext context, String artist, String title) async {
    String idxx = libmoc.omusicAlbumIDS(Global.profile.msourceID, artist, title);
    List<String> ids = List<String>.from(jsonDecode(idxx));
    if (ids.length > 0) {
      int index = 0;  
      if (shuffle) index = random.nextInt(trackIDS.length);
      String id = ids.removeAt(index);
      trackIDS = ids;
      await playSingle(context, id, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${title} 没缓存至手机?'),
          duration: Duration(seconds: 3)
        )
      );
    }
  }

  Future<void> playArtist(BuildContext context, String artist) async {
    String idxx = libmoc.omusicArtistIDS(Global.profile.msourceID, artist);
    List<String> ids = List<String>.from(jsonDecode(idxx));
    if (ids.length > 0) {
      int index = 0;  
      if (shuffle) index = random.nextInt(trackIDS.length);
      String id = ids.removeAt(index);
      trackIDS = ids;
      await playSingle(context, id, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${artist} 没缓存至手机?'),
          duration: Duration(seconds: 3)
        )
      );
    }
  }

  Future<void> playLibrary(BuildContext context) async {
    String idxx = libmoc.omusicLibraryID(Global.profile.msourceID);
    if (idxx.isNotEmpty) {
      await playSingle(context, idxx, true);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('请先缓存至歌曲到手机'),
          duration: Duration(seconds: 3)
        )
      );
    }
  }

  Future<void> playNext(BuildContext context) async {
    if (trackIDS.length > 0) {
      int index = 0;  
      if (shuffle) index = random.nextInt(trackIDS.length);
      String id = trackIDS.removeAt(index);
      await playSingle(context, id, true);
    } else {
        // 播放完成后，默认会播放媒体库
        await playLibrary(context);
    }
  }

  Future<void> playPrevious(BuildContext context) async {
    if (listendTracks.length > 0) {
      String previd = listendTracks.removeLast();
      await playSingle(context, previd, false);
    }
  }

  Future<void> pause() async {
    await _audioPlayer.pause();  
  }

  Future<void> resume() async {
    _audioPlayer.play();  
  }

  Future<void> setVolume(v) async {
    if (v >= 0.0 && v <= 1.0) {
      volume = v;
      await _audioPlayer.setVolume(v);
    }
  }

  void setShuffle(v) {
    shuffle = v;  
  }

  Future<void> dragTo(v) async {
    if (v > 0.0 && v < 1.0) {
      num seconds = duration.inSeconds * v;
      position = Duration(seconds: seconds.toInt());
      await _audioPlayer.seek(position);
    }
  }

  String idNext() {
    if (trackIDS.length > 0) {
      int index = 0;  
      if (shuffle) index = random.nextInt(trackIDS.length);
      String id = trackIDS.removeAt(index);
      return id;
    }
    return "";
  }
}