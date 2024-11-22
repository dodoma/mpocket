// ignore_for_file: always_specify_types
// ignore_for_file: camel_case_types
// ignore_for_file: non_constant_identifier_names

// AUTO GENERATED FILE, DO NOT EDIT.
//
// Generated by `package:ffigen`.
// ignore_for_file: type=lint
import 'dart:ffi' as ffi;

import 'package:ffi/ffi.dart';

/// Bindings for `src/libmoc.h`.
///
/// Regenerate bindings with `dart run ffigen --config ffigen.yaml`.
///
class LibmocBindings {
  /// Holds the symbol lookup function.
  final ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
  _lookup;

  /// The symbols are looked up in [dynamicLibrary].
  LibmocBindings(ffi.DynamicLibrary dynamicLibrary)
  : _lookup = dynamicLibrary.lookup;

  /// The symbols are looked up with [lookup].
  LibmocBindings.fromLookup(
    ffi.Pointer<T> Function<T extends ffi.NativeType>(String symbolName)
    lookup)
  : _lookup = lookup;

  /// A very short-lived native function.
  ///
  /// For very short-lived functions, it is fine to call them on the main isolate.
  /// They will block the Dart execution while running the native function, so
  /// only do this for native functions which are guaranteed to be short-lived.
  int sum(
    int a,
    int b,
  ) {
    return _sum(
      a,
      b,
    );
  }

  late final _sumPtr =
  _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Int, ffi.Int)>>('sum');
  late final _sum = _sumPtr.asFunction<int Function(int, int)>();

  /// A longer lived native function, which occupies the thread calling it.
  ///
  /// Do not call these kind of native functions in the main isolate. They will
  /// block Dart execution. This will cause dropped frames in Flutter applications.
  /// Instead, call these native functions on a separate isolate.
  int sum_long_running(
    int a,
    int b,
  ) {
    return _sum_long_running(
      a,
      b,
    );
  }
  late final _sum_long_runningPtr =
  _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Int, ffi.Int)>>(
    'sum_long_running');
  late final _sum_long_running =
  _sum_long_runningPtr.asFunction<int Function(int, int)>();


  // discovery
  ffi.Pointer<ffi.Int8> mnet_discovery(
  ) {
    return _mnet_discovery (
    );
  }
  late final _mnet_discoveryPtr =
  _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Int8> Function()>>(
    'mnetDiscovery');
  late final _mnet_discovery =
  _mnet_discoveryPtr.asFunction<ffi.Pointer<ffi.Int8> Function()>();

  // discover2
  ffi.Pointer<ffi.Int8> mnet_discover2(
  ) {
    return _mnet_discover2 (
    );
  }
  late final _mnet_discover2Ptr =
  _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Int8> Function()>>(
    'mnet_discover2');
  late final _mnet_discover2 =
  _mnet_discover2Ptr.asFunction<ffi.Pointer<ffi.Int8> Function()>();

  // file_test
  ffi.Pointer<ffi.Int8> mfile_test(
    ffi.Pointer<ffi.Int8> dirname
  ) {
    return _mfile_test (
      dirname
    );
  }
  late final _mfile_testPtr =
  _lookup<ffi.NativeFunction<ffi.Pointer<ffi.Int8> Function(ffi.Pointer<ffi.Int8>)>>(
    'mfile_test');
  late final _mfile_test =
  _mfile_testPtr.asFunction<ffi.Pointer<ffi.Int8> Function(ffi.Pointer<ffi.Int8>)>();

  int mnetStart(ffi.Pointer<Utf8> dir) {return _mnetStart(dir);}
  late final _mnetStartPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<Utf8>)>>('mnetStart');
  late final _mnetStart = _mnetStartPtr.asFunction<int Function(ffi.Pointer<Utf8>)>();

  int wifiSet(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8> ap, ffi.Pointer<Utf8>pass, ffi.Pointer<Utf8>name, ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Int)>>callback) {return _wifiSet(ID, ap, pass, name, callback);}
  late final _wifiSetPtr = _lookup<
    ffi.NativeFunction<ffi.Int 
      Function(ffi.Pointer<Utf8>, ffi.Pointer<Utf8>, ffi.Pointer<Utf8>, ffi.Pointer<Utf8>, 
               ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Int)>>)
    >>('mnetWifiSet');
  late final _wifiSet = _wifiSetPtr.asFunction<
    int Function(
      ffi.Pointer<Utf8>, ffi.Pointer<Utf8>, ffi.Pointer<Utf8>, ffi.Pointer<Utf8>,
      ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Int)>>)
  >();

  int mnetPlayInfo(ffi.Pointer<Utf8>ID, ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Int, ffi.Pointer<Utf8>, ffi.Pointer<Utf8>)>>callback) {
    return _mnetPlayInfo(ID, callback);
  }
  late final _mnetPlayInfoPtr = _lookup<
    ffi.NativeFunction<ffi.Int 
      Function(ffi.Pointer<Utf8>ID, ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Int, ffi.Pointer<Utf8>, ffi.Pointer<Utf8>)>>)
    >>('mnetPlayInfo');
  late final _mnetPlayInfo = _mnetPlayInfoPtr.asFunction<
    int Function(
      ffi.Pointer<Utf8>ID, ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Int, ffi.Pointer<Utf8>, ffi.Pointer<Utf8>)>>)
      >();

  int mnetOnStep(ffi.Pointer<Utf8>ID, ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Int, ffi.Pointer<Utf8>, ffi.Pointer<Utf8>)>>callback) {
    return _mnetOnStep(ID, callback);
  }
  late final _mnetOnStepPtr = _lookup<
    ffi.NativeFunction<ffi.Int 
      Function(ffi.Pointer<Utf8>ID, ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Int, ffi.Pointer<Utf8>, ffi.Pointer<Utf8>)>>)
    >>('mnetOnStep');
  late final _mnetOnStep = _mnetOnStepPtr.asFunction<
    int Function(
      ffi.Pointer<Utf8>ID, ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Int, ffi.Pointer<Utf8>, ffi.Pointer<Utf8>)>>)
      >();

  int mnetOnServerConnectted(ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Int)>>callback) {
    return _mnetOnServerConnectted(callback);
  }
  late final _mnetOnServerConnecttedPtr = _lookup<
    ffi.NativeFunction<ffi.Int 
      Function(ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Int)>>)
    >>('mnetOnServerConnectted');
  late final _mnetOnServerConnectted = _mnetOnServerConnecttedPtr.asFunction<
    int Function(
      ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Int)>>)
      >();

  int mnetOnServerClosed(ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Int)>>callback) {
    return _mnetOnServerClosed(callback);
  }
  late final _mnetOnServerClosedPtr = _lookup<
    ffi.NativeFunction<ffi.Int 
      Function(ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Int)>>)
    >>('mnetOnServerClosed');
  late final _mnetOnServerClosed = _mnetOnServerClosedPtr.asFunction<
    int Function(
      ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Int)>>)
      >();

  int mnetOnConnectionLost(ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Int)>>callback) {
    return _mnetOnConnectionLost(callback);
  }
  late final _mnetOnConnectionLostPtr = _lookup<
    ffi.NativeFunction<ffi.Int 
      Function(ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Int)>>)
    >>('mnetOnConnectionLost');
  late final _mnetOnConnectionLost = _mnetOnConnectionLostPtr.asFunction<
    int Function(
      ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Int)>>)
      >();

  int mnetOnReceiving(ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Pointer<Utf8>)>>callback) {
    return _mnetOnReceiving(callback);
  }
  late final _mnetOnReceivingPtr = _lookup<
    ffi.NativeFunction<ffi.Int 
      Function(ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Pointer<Utf8>)>>)
    >>('mnetOnReceiving');
  late final _mnetOnReceiving = _mnetOnReceivingPtr.asFunction<
    int Function(
      ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Pointer<Utf8>)>>)
      >();

  int mnetOnFileReceived(ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Pointer<Utf8>)>>callback) {
    return _mnetOnFileReceived(callback);
  }
  late final _mnetOnFileReceivedPtr = _lookup<
    ffi.NativeFunction<ffi.Int 
      Function(ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Pointer<Utf8>)>>)
    >>('mnetOnFileReceived');
  late final _mnetOnFileReceived = _mnetOnFileReceivedPtr.asFunction<
    int Function(
      ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Pointer<Utf8>)>>)
      >();

  int mnetOnReceiveDone(ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Int)>>callback) {
    return _mnetOnReceiveDone(callback);
  }
  late final _mnetOnReceiveDonePtr = _lookup<
    ffi.NativeFunction<ffi.Int 
      Function(ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Int)>>)
    >>('mnetOnReceiveDone');
  late final _mnetOnReceiveDone = _mnetOnReceiveDonePtr.asFunction<
    int Function(
      ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>, ffi.Int)>>)
      >();

  int mnetOnUdiskMount(ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>)>>callback) {return _mnetOnUdiskMount(callback);}
  late final _mnetOnUdiskMountPtr = _lookup<
    ffi.NativeFunction<ffi.Int 
      Function(ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>)>>)
    >>('mnetOnUdiskMount');
  late final _mnetOnUdiskMount = _mnetOnUdiskMountPtr.asFunction<
    int Function(
      ffi.Pointer<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>)>>)
      >();



  int mnetSetShuffle(ffi.Pointer<Utf8>ID, int shuffle) {return _mnetSetShuffle(ID, shuffle);}
  late final _mnetSetShufflePtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<Utf8>ID, ffi.Int8 shuffle)>>('mnetSetShuffle');
  late final _mnetSetShuffle = _mnetSetShufflePtr.asFunction<int Function(ffi.Pointer<Utf8>ID, int shuffle)>();

  int mnetSetVolume(ffi.Pointer<Utf8>ID, double volume) {return _mnetSetVolume(ID, volume);}
  late final _mnetSetVolumePtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<Utf8>ID, ffi.Double volume)>>('mnetSetVolume');
  late final _mnetSetVolume = _mnetSetVolumePtr.asFunction<int Function(ffi.Pointer<Utf8>ID, double volume)>();

  int mnetStoreSwitch(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name) {return _mnetStoreSwitch(ID, name);}
  late final _mnetStoreSwitchPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name)>>('mnetStoreSwitch');
  late final _mnetStoreSwitch = _mnetStoreSwitchPtr.asFunction<int Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name)>();

  int mnetPlay(ffi.Pointer<Utf8>ID) {return _mnetPlay(ID);}
  late final _mnetPlayPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<Utf8>ID)>>('mnetPlay');
  late final _mnetPlay = _mnetPlayPtr.asFunction<int Function(ffi.Pointer<Utf8>ID)>();

  int mnetPlayID(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>trackid) {return _mnetPlayID(ID, trackid);}
  late final _mnetPlayIDPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>trackid)>>('mnetPlayID');
  late final _mnetPlayID = _mnetPlayIDPtr.asFunction<int Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>trackid)>();

  int mnetPlayArtist(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>artist) {return _mnetPlayArtist(ID, artist);}
  late final _mnetPlayArtistPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>artist)>>('mnetPlayArtist');
  late final _mnetPlayArtist = _mnetPlayArtistPtr.asFunction<int Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>artist)>();

  int mnetPlayAlbum(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name, ffi.Pointer<Utf8> title) {return _mnetPlayAlbum(ID, name, title);}
  late final _mnetPlayAlbumPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name, ffi.Pointer<Utf8>title)>>('mnetPlayAlbum');
  late final _mnetPlayAlbum = _mnetPlayAlbumPtr.asFunction<int Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name, ffi.Pointer<Utf8>title)>();


  int mnetPause(ffi.Pointer<Utf8>ID) {return _mnetPause(ID);}
  late final _mnetPausePtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<Utf8>ID)>>('mnetPause');
  late final _mnetPause = _mnetPausePtr.asFunction<int Function(ffi.Pointer<Utf8>ID)>();

  int mnetResume(ffi.Pointer<Utf8>ID) {return _mnetResume(ID);}
  late final _mnetResumePtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<Utf8>ID)>>('mnetResume');
  late final _mnetResume = _mnetResumePtr.asFunction<int Function(ffi.Pointer<Utf8>ID)>();

  int mnetNext(ffi.Pointer<Utf8>ID) {return _mnetNext(ID);}
  late final _mnetNextPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<Utf8>ID)>>('mnetNext');
  late final _mnetNext = _mnetNextPtr.asFunction<int Function(ffi.Pointer<Utf8>ID)>();

  int mnetPrevious(ffi.Pointer<Utf8>ID) {return _mnetPrevious(ID);}
  late final _mnetPreviousPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<Utf8>ID)>>('mnetPrevious');
  late final _mnetPrevious = _mnetPreviousPtr.asFunction<int Function(ffi.Pointer<Utf8>ID)>();

  int mnetDragTO(ffi.Pointer<Utf8>ID, double percent) {return _mnetDragTO(ID, percent);}
  late final _mnetDragTOPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<Utf8>ID, ffi.Double percent)>>('mnetDragTO');
  late final _mnetDragTO = _mnetDragTOPtr.asFunction<int Function(ffi.Pointer<Utf8>ID, double percent)>();

  int mnetStoreList(ffi.Pointer<Utf8>ID) {return _mnetStoreList(ID);}
  late final _mnetStoreListPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<Utf8>ID)>>('mnetStoreList');
  late final _mnetStoreList = _mnetStoreListPtr.asFunction<int Function(ffi.Pointer<Utf8>ID)>();

  int mnetStoreSync(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>Libname) {return _mnetStoreSync(ID, Libname);}
  late final _mnetStoreSyncPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>Libname)>>('mnetStoreSync');
  late final _mnetStoreSync = _mnetStoreSyncPtr.asFunction<int Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>Libname)>();



  void omusicStoreSelect(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>Libname) {return _omusicStoreSelect(ID, Libname);}
  late final omusicStoreSelectPtr = _lookup<ffi.NativeFunction<ffi.Void Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>Libname)>>('omusicStoreSelect');
  late final _omusicStoreSelect = omusicStoreSelectPtr.asFunction<void Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>Libname)>();

  ffi.Pointer<Utf8> omusicStoreList(ffi.Pointer<Utf8>ID) {return _omusicStoreList(ID);}
  late final omusicStoreListPtr = _lookup<ffi.NativeFunction<ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>ID)>>('omusicStoreList');
  late final _omusicStoreList = omusicStoreListPtr.asFunction<ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>ID)>();

  ffi.Pointer<Utf8> omusicHome(ffi.Pointer<Utf8>ID) {return _omusicHome(ID);}
  late final omusicHomePtr = _lookup<ffi.NativeFunction<ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>ID)>>('omusicHome');
  late final _omusicHome = omusicHomePtr.asFunction<ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>ID)>();

  ffi.Pointer<Utf8> omusicArtist(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name) {return _omusicArtist(ID, name);}
  late final omusicArtistPtr = _lookup<ffi.NativeFunction<ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name)>>('omusicArtist');
  late final _omusicArtist = omusicArtistPtr.asFunction<ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name)>();

  ffi.Pointer<Utf8> omusicArtistIDS(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name) {return _omusicArtistIDS(ID, name);}
  late final omusicArtistIDSPtr = _lookup<ffi.NativeFunction<ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name)>>('omusicArtistIDS');
  late final _omusicArtistIDS = omusicArtistIDSPtr.asFunction<ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name)>();

  ffi.Pointer<Utf8> omusicAlbumIDS(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name, ffi.Pointer<Utf8>title) {return _omusicAlbumIDS(ID, name, title);}
  late final omusicAlbumIDSPtr = _lookup<ffi.NativeFunction<ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name, ffi.Pointer<Utf8>title)>>('omusicAlbumIDS');
  late final _omusicAlbumIDS = omusicAlbumIDSPtr.asFunction<ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name, ffi.Pointer<Utf8>title)>();

  ffi.Pointer<Utf8> omusicLocation(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>trackid) {return _omusicLocation(ID, trackid);}
  late final omusicLocationPtr = _lookup<ffi.NativeFunction<ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>trackid)>>('omusicLocation');
  late final _omusicLocation = omusicLocationPtr.asFunction<ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>trackid)>();

  ffi.Pointer<Utf8> omusicLibraryID(ffi.Pointer<Utf8>ID) {return _omusicLibraryID(ID);}
  late final omusicLibraryIDPtr = _lookup<ffi.NativeFunction<ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>ID)>>('omusicLibraryID');
  late final _omusicLibraryID = omusicLibraryIDPtr.asFunction<ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>ID)>();

  ffi.Pointer<Utf8> omusicAlbum(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name, ffi.Pointer<Utf8>title) {return _omusicAlbum(ID, name, title);}
  late final omusicAlbumPtr = _lookup<ffi.NativeFunction<ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name, ffi.Pointer<Utf8>title)>>('omusicAlbum');
  late final _omusicAlbum = omusicAlbumPtr.asFunction<ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name, ffi.Pointer<Utf8>title)>();

  int omusicSyncArtist(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name) {return _omusicSyncArtist(ID, name);}
  late final omusicSyncArtistPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name)>>('omusicSyncArtist');
  late final _omusicSyncArtist = omusicSyncArtistPtr.asFunction<int Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name)>();

  int omusicClearArtist(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name) {return _omusicClearArtist(ID, name);}
  late final omusicClearArtistPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name)>>('omusicClearArtist');
  late final _omusicClearArtist = omusicClearArtistPtr.asFunction<int Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name)>();

  int omusicSyncAlbum(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name, ffi.Pointer<Utf8>title) {return _omusicSyncAlbum(ID, name, title);}
  late final omusicSyncAlbumPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name, ffi.Pointer<Utf8>title)>>('omusicSyncAlbum');
  late final _omusicSyncAlbum = omusicSyncAlbumPtr.asFunction<int Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name, ffi.Pointer<Utf8>title)>();

  int omusicClearAlbum(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name, ffi.Pointer<Utf8>title) {return _omusicClearAlbum(ID, name, title);}
  late final omusicClearAlbumPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name, ffi.Pointer<Utf8>title)>>('omusicClearAlbum');
  late final _omusicClearAlbum = omusicClearAlbumPtr.asFunction<int Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name, ffi.Pointer<Utf8>title)>();

  int omusicDeleteAlbum(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name, ffi.Pointer<Utf8>title) {return _omusicDeleteAlbum(ID, name, title);}
  late final omusicDeleteAlbumPtr = _lookup<ffi.NativeFunction<ffi.Int Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name, ffi.Pointer<Utf8>title)>>('omusicDeleteAlbum');
  late final _omusicDeleteAlbum = omusicDeleteAlbumPtr.asFunction<int Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name, ffi.Pointer<Utf8>title)>();

  ffi.Pointer<Utf8> msourceHome(ffi.Pointer<Utf8>ID) {return _msourceHome(ID);}
  late final msourceHomePtr = _lookup<ffi.NativeFunction<ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>ID)>>('msourceHome');
  late final _msourceHome = msourceHomePtr.asFunction<ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>ID)>();

  ffi.Pointer<Utf8> msourceLibraryCreate(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name) {return _msourceLibraryCreate(ID, name);}
  late final msourceLibraryCreatePtr = _lookup<ffi.NativeFunction<ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name)>>('msourceLibraryCreate');
  late final _msourceLibraryCreate = msourceLibraryCreatePtr.asFunction<ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>name)>();

  ffi.Pointer<Utf8> msourceLibraryRename(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>nameold, ffi.Pointer<Utf8>namenew) {return _msourceLibraryRename(ID, nameold, namenew);}
  late final msourceLibraryRenamePtr = _lookup<ffi.NativeFunction<ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>nameold, ffi.Pointer<Utf8>namenew)>>('msourceLibraryRename');
  late final _msourceLibraryRename = msourceLibraryRenamePtr.asFunction<ffi.Pointer<Utf8> Function(ffi.Pointer<Utf8>ID, ffi.Pointer<Utf8>nameold, ffi.Pointer<Utf8>namenew)>();
}
