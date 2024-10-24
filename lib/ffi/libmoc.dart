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

int mnetPlay(String ID) => _bindings.mnetPlay(ID.toNativeUtf8());
int mnetPause(String ID) => _bindings.mnetPause(ID.toNativeUtf8());
int mnetResume(String ID) => _bindings.mnetResume(ID.toNativeUtf8());
int mnetNext(String ID) => _bindings.mnetNext(ID.toNativeUtf8());
int mnetStoreList(String ID) => _bindings.mnetStoreList(ID.toNativeUtf8());

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
