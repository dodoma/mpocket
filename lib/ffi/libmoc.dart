import 'dart:async';
import 'dart:ffi';
import 'dart:io';
import 'dart:isolate';

import 'package:ffi/ffi.dart';

import 'libmoc_bindings_generated.dart';

/// A very short-lived native function.
///
/// For very short-lived functions, it is fine to call them on the main isolate.
/// They will block the Dart execution while running the native function, so
/// only do this for native functions which are guaranteed to be short-lived.
int sum(int a, int b) => _bindings.sum(a, b);
String fileTest(String dir) => _bindings.mfile_test(dir.toNativeUtf8().cast<Int8>()).cast<Utf8>().toDartString();

void omusicStoreSelect(String ID, String Libname) =>_bindings.omusicStoreSelect(ID.toNativeUtf8(), Libname.toNativeUtf8());

String omusicStoreList(String ID) {
  final Pointer<Utf8> result = _bindings.omusicStoreList(ID.toNativeUtf8());
  String outputs = "{}";
  if (result.address != nullptr.address) {
    outputs = result.cast<Utf8>().toDartString();
    calloc.free(result);
  }
  return outputs;
}

//String mnetOmusicHome(String ID) => _bindings.omusicHome(ID.toNativeUtf8()).cast<Utf8>().toDartString();
String omusicHome(String ID) {
  final Pointer<Utf8> result = _bindings.omusicHome(ID.toNativeUtf8());
  String outputs = "";
  if (result.address != nullptr.address) {
    outputs = result.cast<Utf8>().toDartString();
    calloc.free(result);
  }
  return outputs;
}

String omusicArtist(String ID, String name) {
  final Pointer<Utf8> result = _bindings.omusicArtist(ID.toNativeUtf8(), name.toNativeUtf8());
  String outputs = "";
  if (result.address != nullptr.address) {
    outputs = result.cast<Utf8>().toDartString();
    calloc.free(result);
  }
  return outputs;
}

String omusicLocation(String ID, String trackid) {
  final Pointer<Utf8> result = _bindings.omusicLocation(ID.toNativeUtf8(), trackid.toNativeUtf8());
  String outputs = "";
  if (result.address != nullptr.address) {
    outputs = result.cast<Utf8>().toDartString();
    if(outputs == "") outputs = "ENOENT";
  }
  return outputs;
}

String omusicLibraryID(String ID) {
  final Pointer<Utf8> result = _bindings.omusicLibraryID(ID.toNativeUtf8());
  String outputs = "";
  if (result.address != nullptr.address) {
    outputs = result.cast<Utf8>().toDartString();
  }
  return outputs;
}

String omusicAlbum(String ID, String name, String title) {
  final Pointer<Utf8> result = _bindings.omusicAlbum(ID.toNativeUtf8(), name.toNativeUtf8(), title.toNativeUtf8());
  String outputs = "";
  if (result.address != nullptr.address) {
    outputs = result.cast<Utf8>().toDartString();
    calloc.free(result);
  }
  return outputs;
}

String omusicArtistIDS(String ID, String name) {
  final Pointer<Utf8> result = _bindings.omusicArtistIDS(ID.toNativeUtf8(), name.toNativeUtf8());
  String outputs = "[]";
  if (result.address != nullptr.address) {
    outputs = result.cast<Utf8>().toDartString();
    calloc.free(result);
  }
  return outputs;
}

String omusicAlbumIDS(String ID, String name, String title) {
  final Pointer<Utf8> result = _bindings.omusicAlbumIDS(ID.toNativeUtf8(), name.toNativeUtf8(), title.toNativeUtf8());
  String outputs = "[]";
  if (result.address != nullptr.address) {
    outputs = result.cast<Utf8>().toDartString();
    calloc.free(result);
  }
  return outputs;
}

String msourceHome(String ID) {
  final Pointer<Utf8> result = _bindings.msourceHome(ID.toNativeUtf8());
  String outputs = "";
  if (result.address != nullptr.address) {
    outputs = result.cast<Utf8>().toDartString();
  }
  return outputs;
}

String msourceDirectoryInfo(String ID, String pathname) {
  final Pointer<Utf8> result = _bindings.msourceDirectoryInfo(ID.toNativeUtf8(), pathname.toNativeUtf8());
  String outputs = "";
  if (result.address != nullptr.address) {
    outputs = result.cast<Utf8>().toDartString();
  }
  return outputs;
}
String msourceLibraryCreate(String ID, String name) {
  final Pointer<Utf8> result = _bindings.msourceLibraryCreate(ID.toNativeUtf8(), name.toNativeUtf8());
  String outputs = "";
  if (result.address != nullptr.address) {
    outputs = result.cast<Utf8>().toDartString();
  }
  return outputs;
}

String msourceLibraryRename(String ID, String nameold, String namenew) {
  final Pointer<Utf8> result = _bindings.msourceLibraryRename(ID.toNativeUtf8(), nameold.toNativeUtf8(), namenew.toNativeUtf8());
  String outputs = "";
  if (result.address != nullptr.address) {
    outputs = result.cast<Utf8>().toDartString();
  }
  return outputs;
}

String msourceLibrarySetDefault(String ID, String name) {
  final Pointer<Utf8> result = _bindings.msourceLibrarySetDefault(ID.toNativeUtf8(), name.toNativeUtf8());
  String outputs = "";
  if (result.address != nullptr.address) {
    outputs = result.cast<Utf8>().toDartString();
  }
  return outputs;
}

String msourceLibraryDelete(String ID, String name, bool force) {
  final Pointer<Utf8> result = _bindings.msourceLibraryDelete(ID.toNativeUtf8(), name.toNativeUtf8(), force);
  String outputs = "";
  if (result.address != nullptr.address) {
    outputs = result.cast<Utf8>().toDartString();
  }
  return outputs;
}

String msourceLibraryMerge(String ID, String libsrc, String libdst) {
  final Pointer<Utf8> result = _bindings.msourceLibraryMerge(ID.toNativeUtf8(), libsrc.toNativeUtf8(), libdst.toNativeUtf8());
  String outputs = "";
  if (result.address != nullptr.address) {
    outputs = result.cast<Utf8>().toDartString();
  }
  return outputs;
}

int msourceMediaCopy(String ID, String mediapath, String storename, bool recursive) => _bindings.msourceMediaCopy(ID.toNativeUtf8(), mediapath.toNativeUtf8(), storename.toNativeUtf8(), recursive);

int mocInit(String dir) => _bindings.mnetStart(dir.toNativeUtf8());
int wifiSet(String ID, String ap, String pass, String name, Pointer<NativeFunction<Void Function(Int)>> callback) {
  final Pointer<Utf8> c_id = ID.toNativeUtf8();
  final Pointer<Utf8> c_ap = ap.toNativeUtf8();
  final Pointer<Utf8> c_pass = pass.toNativeUtf8();
  final Pointer<Utf8> c_name = name.toNativeUtf8();

  int ret = _bindings.wifiSet(c_id, c_ap, c_pass, c_name, callback);

  calloc.free(c_id);
  calloc.free(c_ap);
  calloc.free(c_name);
  calloc.free(c_pass);

  return ret;
}
//int wifiSet(String ap, String pass, String name) => _bindings.wifiSet(ap.toNativeUtf8().cast<Int8>(), pass.toNativeUtf8().cast<Int8>(), name.toNativeUtf8().cast<Int8>());

int mnetSetShuffle(String ID, int shuffle) => _bindings.mnetSetShuffle(ID.toNativeUtf8(), shuffle);
int mnetSetVolume(String ID, double volume) => _bindings.mnetSetVolume(ID.toNativeUtf8(), volume);

int mnetStoreSwitch(String ID, String name) => _bindings.mnetStoreSwitch(ID.toNativeUtf8(), name.toNativeUtf8());
int mnetPlay(String ID) => _bindings.mnetPlay(ID.toNativeUtf8());
int mnetPlayID(String ID, String trackid) => _bindings.mnetPlayID(ID.toNativeUtf8(), trackid.toNativeUtf8());
int mnetPlayArtist(String ID, String artist) => _bindings.mnetPlayArtist(ID.toNativeUtf8(), artist.toNativeUtf8());
int mnetPlayAlbum(String ID, String name, String title) => _bindings.mnetPlayAlbum(ID.toNativeUtf8(), name.toNativeUtf8(), title.toNativeUtf8());
int mnetPause(String ID) => _bindings.mnetPause(ID.toNativeUtf8());
int mnetResume(String ID) => _bindings.mnetResume(ID.toNativeUtf8());
int mnetNext(String ID) => _bindings.mnetNext(ID.toNativeUtf8());
int mnetPrevious(String ID) => _bindings.mnetPrevious(ID.toNativeUtf8());
int mnetDragTO(String ID, double percent) => _bindings.mnetDragTO(ID.toNativeUtf8(), percent);
int mnetStoreList(String ID) => _bindings.mnetStoreList(ID.toNativeUtf8());

int omusicSyncStore(String ID, String name) => _bindings.omusicSyncStore(ID.toNativeUtf8(), name.toNativeUtf8());
int omusicClearStore(String ID, String name, bool rmdir) => _bindings.omusicClearStore(ID.toNativeUtf8(), name.toNativeUtf8(), rmdir);
int omusicSyncArtist(String ID, String name) => _bindings.omusicSyncArtist(ID.toNativeUtf8(), name.toNativeUtf8());
int omusicClearArtist(String ID, String name) => _bindings.omusicClearArtist(ID.toNativeUtf8(), name.toNativeUtf8());
int omusicSyncAlbum(String ID, String name, String title) => _bindings.omusicSyncAlbum(ID.toNativeUtf8(), name.toNativeUtf8(), title.toNativeUtf8());
int omusicClearAlbum(String ID, String name, String title) => _bindings.omusicClearAlbum(ID.toNativeUtf8(), name.toNativeUtf8(), title.toNativeUtf8());
int omusicDeleteAlbum(String ID, String name, String title) => _bindings.omusicDeleteAlbum(ID.toNativeUtf8(), name.toNativeUtf8(), title.toNativeUtf8());

int mnetStoreSync(String ID, String Libname) => _bindings.mnetStoreSync(ID.toNativeUtf8(), Libname.toNativeUtf8());

int mnetPlayInfo(String ID, Pointer<NativeFunction<Void Function(Pointer<Utf8>, Int, Pointer<Utf8>, Pointer<Utf8>)>> callback) {
  final Pointer<Utf8> c_id = ID.toNativeUtf8();
  int ret = _bindings.mnetPlayInfo(c_id, callback);

  return ret;
}

int mnetOnStep(String ID, Pointer<NativeFunction<Void Function(Pointer<Utf8>, Int, Pointer<Utf8>, Pointer<Utf8>)>> callback) {
  final Pointer<Utf8> c_id = ID.toNativeUtf8();
  int ret = _bindings.mnetOnStep(c_id, callback);

  return ret;
}

int mnetOnServerConnectted(Pointer<NativeFunction<Void Function(Pointer<Utf8>, Int)>> callback) => _bindings.mnetOnServerConnectted(callback);
int mnetOnServerClosed(Pointer<NativeFunction<Void Function(Pointer<Utf8>, Int)>> callback) => _bindings.mnetOnServerClosed(callback);
int mnetOnConnectionLost(Pointer<NativeFunction<Void Function(Pointer<Utf8>, Int)>> callback) => _bindings.mnetOnConnectionLost(callback);
int mnetOnReceiving(Pointer<NativeFunction<Void Function(Pointer<Utf8>, Pointer<Utf8>)>> callback) => _bindings.mnetOnReceiving(callback);
int mnetOnFileReceived(Pointer<NativeFunction<Void Function(Pointer<Utf8>, Pointer<Utf8>)>> callback) => _bindings.mnetOnFileReceived(callback);
int mnetOnReceiveDone(Pointer<NativeFunction<Void Function(Pointer<Utf8>, Int)>> callback) => _bindings.mnetOnReceiveDone(callback);
int mnetOnUdiskMount(Pointer<NativeFunction<Void Function(Pointer<Utf8>)>> callback) => _bindings.mnetOnUdiskMount(callback);
int mnetOnFree(Pointer<NativeFunction<Void Function(Pointer<Utf8>)>> callback) => _bindings.mnetOnFree(callback);
int mnetOnBusyIndexing(Pointer<NativeFunction<Void Function(Pointer<Utf8>)>> callback) => _bindings.mnetOnBusyIndexing(callback);

/// A longer lived native function, which occupies the thread calling it.
///
/// Do not call these kind of native functions in the main isolate. They will
/// block Dart execution. This will cause dropped frames in Flutter applications.
/// Instead, call these native functions on a separate isolate.
///
/// Modify this to suit your own use case. Example use cases:
///
/// 1. Reuse a single isolate for various different kinds of requests.
/// 2. Use multiple helper isolates for parallel execution.
Future<int> sumAsync(int a, int b) async {
  final SendPort helperIsolateSendPort = await _helperIsolateSendPort;
  final int requestId = _nextSumRequestId++;
  final _SumRequest request = _SumRequest(requestId, a, b);
  final Completer<int> completer = Completer<int>();

  _sumRequests[requestId] = completer;

  helperIsolateSendPort.send(request);
  return completer.future;
}

Future<String> mocDiscovery() async {
  final SendPort helperIsolateSendPort = await _helperIsolateSendPort;
  final int requestId = _nextSumRequestId++;
  final _CoverRequest request = _CoverRequest(requestId);
  final Completer<String> completer = Completer<String>();

  _coverRequests[requestId] = completer;

  helperIsolateSendPort.send(request);
  return completer.future;
}

const String _libName = 'libmoc';

/// The dynamic library in which the symbols for [LibmocBindings] can be found.
final DynamicLibrary _dylib = () {
  if (Platform.isMacOS || Platform.isIOS) {
    return DynamicLibrary.open('$_libName.framework/$_libName');
  }
  if (Platform.isAndroid || Platform.isLinux) {
    return DynamicLibrary.open('lib$_libName.so');
  }
  if (Platform.isWindows) {
    return DynamicLibrary.open('$_libName.dll');
  }
  throw UnsupportedError('Unknown platform: ${Platform.operatingSystem}');
}();

/// The bindings to the native functions in [_dylib].
final LibmocBindings _bindings = LibmocBindings(_dylib);

/// A request to compute `sum`.
///
/// Typically sent from one isolate to another.
class _SumRequest {
  final int id;
  final int a;
  final int b;

  const _SumRequest(this.id, this.a, this.b);
}

class _CoverRequest {
  final int id;

  const _CoverRequest(this.id);
}

/// A response with the result of `sum`.
///
/// Typically sent from one isolate to another.
class _SumResponse {
  final int id;
  final int result;

  const _SumResponse(this.id, this.result);
}

class _CoverResponse {
  final int id;
  final String result;

  const _CoverResponse(this.id, this.result);
}

/// Counter to identify [_SumRequest]s and [_SumResponse]s.
int _nextSumRequestId = 0;

/// Mapping from [_SumRequest] `id`s to the completers corresponding to the correct future of the pending request.
final Map<int, Completer<int>> _sumRequests = <int, Completer<int>>{};
final Map<int, Completer<String>> _coverRequests = <int, Completer<String>>{};

/// The SendPort belonging to the helper isolate.
Future<SendPort> _helperIsolateSendPort = () async {
  // The helper isolate is going to send us back a SendPort, which we want to
  // wait for.
  final Completer<SendPort> completer = Completer<SendPort>();

  // Receive port on the main isolate to receive messages from the helper.
  // We receive two types of messages:
  // 1. A port to send messages on.
  // 2. Responses to requests we sent.
  final ReceivePort receivePort = ReceivePort()
    ..listen((dynamic data) {
      if (data is SendPort) {
        // The helper isolate sent us the port on which we can sent it requests.
        completer.complete(data);
        return;
      }
      if (data is _SumResponse) {
        // The helper isolate sent us a response to a request we sent.
        final Completer<int> completer = _sumRequests[data.id]!;
        _sumRequests.remove(data.id);
        completer.complete(data.result);
        return;
      } else if (data is _CoverResponse) {
        final Completer<String> completer = _coverRequests[data.id]!;
        _coverRequests.remove(data.id);
        completer.complete(data.result);
        return;
      }
      throw UnsupportedError('Unsupported message type: ${data.runtimeType}');
    });

  // Start the helper isolate.
  await Isolate.spawn((SendPort sendPort) async {
    final ReceivePort helperReceivePort = ReceivePort()
      ..listen((dynamic data) {
        // On the helper isolate listen to requests and respond to them.
        if (data is _SumRequest) {
          final int result = _bindings.sum_long_running(data.a, data.b);
          final _SumResponse response = _SumResponse(data.id, result);
          sendPort.send(response);
          return;
        } else if (data is _CoverRequest) {
          Pointer<Int8> resultPtr = _bindings.mnet_discovery();
          //Pointer<Int8> resultPtr = _bindings.mnet_discover2();
          String result = "";
          if (resultPtr.address != nullptr.address) {
            result = resultPtr.cast<Utf8>().toDartString();
          }
          final _CoverResponse response = _CoverResponse(data.id, result);
          sendPort.send(response);
          return;
        }
        throw UnsupportedError('Unsupported message type: ${data.runtimeType}');
      });

    // Send the port to the main isolate on which we can receive requests.
    sendPort.send(helperReceivePort.sendPort);
  }, receivePort.sendPort);

  // Wait until the helper isolate has sent us back the SendPort on which we
  // can start sending requests.
  return completer.future;
}();
