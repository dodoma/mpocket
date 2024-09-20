import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:form_controller/form_controller.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:list_picker/list_picker.dart';
import 'package:mpocket/ffi/libmoc.dart' as libmoc;
import 'package:mpocket/models/imsource.dart';
import 'package:mpocket/models/msource.dart';
import 'package:provider/provider.dart';
import 'package:wifi_scan/wifi_scan.dart';

typedef NativeWifisetCallback = Void Function(Int);

class MsourceScreen extends StatefulWidget {
  const MsourceScreen({
    super.key,
  });

  @override
  State<MsourceScreen> createState() => _MsourceScreenState();
}

class _MsourceScreenState extends State<MsourceScreen> {

  @override
  Widget build(BuildContext context) {
    final IMsource source = Provider.of<IMsource>(context);
    if (source.deviceID.isEmpty) {
      return ConfigDeviceScreen();
    } else {
      return showDeviceScreen(deviceID: source.deviceID);
    }
  }
}

class ConfigDeviceScreen extends StatefulWidget {
  const ConfigDeviceScreen ({super.key});

  @override
  State<ConfigDeviceScreen> createState() => _ConfigDeviceScreenState();
}

class _ConfigDeviceScreenState extends State<ConfigDeviceScreen> {

  late FormController _formctl;
  late Future<String> sourceID = libmoc.mocDiscovery();

  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();
  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  bool searching = true;

  @override
  void initState() {
    super.initState();

    scanWifiAP();
    Timer(Duration(seconds: 5), () async {
      await getScanResults();
      setState(() {
        searching = false;
      });
    });

    _formctl = FormController();
  }

  @override
  void dispose() async {
    //await _formctl.dispose();
    super.dispose();
  }

  scanWifiAP() async {
    // check platform support and necessary requirements
    final can = await WiFiScan.instance.canStartScan(askPermissions: true);
    switch(can) {
    case CanStartScan.yes:
      // start full scan async-ly
      print('start scanning wifi ap...');
      final isScanning = await WiFiScan.instance.startScan();
      break;
    default: 
      print('cant scan wifi ap');
      break;
    }
  }

  Future<bool> canGetScanResults() async {
    final can = await WiFiScan.instance.canGetScannedResults(askPermissions: true);
    if (can != CanGetScannedResults.yes) {
      accessPoints = <WiFiAccessPoint> [];
      return false;
    }
    return true;
  }

  Future<bool?> showTipDialog() {
    return showDialog<bool>(
      context: context,
       builder: (context) {
        return AlertDialog(
          title: Text('提示'),
          content: Text('请选择常用的热点名称'),
          actions:<Widget> [
            TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text('知道了'))
          ]
        );
       }
    );
  }

  getScanResults() async {
    if (await canGetScanResults()) {
      final results = await WiFiScan.instance.getScannedResults();
      results.sort((a,b) => b.level.compareTo(a.level));
      setState(() => accessPoints = results);
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double containerWidth = screenWidth * 0.9;

    return Scaffold(
        body: Center(
          child: Container(
            width: containerWidth,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                FutureBuilder<String>(
                  future: sourceID,
                  builder: (BuildContext context, AsyncSnapshot<String> value) {
                if (value.hasData && searching == false) {
                  if (value.data![0] == 'b') {
                    // 确保导航操作是在 build 结束后进行
                    WidgetsBinding.instance.addPostFrameCallback((_) {
                      // 检查当前的上下文是否依然有效（防止页面被销毁时仍然调用 Navigator）
                      if (context.mounted) {
                        context.go('/music');
                      }
                    });
                    // 在导航操作之前返回一个空的 Widget
                    return Container(); // 返回一个空的容器或其他 widget
                  }

                  return Form(
                    key: _formctl.key,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: <Widget>[
                        Text('配置音源  + ${value.data}',
                            textAlign: TextAlign.left,
                            textScaler: TextScaler.linear(1.2),
                            style: TextStyle(fontWeight: FontWeight.w700)),
                            if (this.searching == true) ...[
                              SizedBox(
                                  height: 5,
                                  width: 100,
                                  child: LinearProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation(
                                        Color.fromRGBO(0x7a, 0x51, 0xe2, 100)),
                                  ))
                            ],
                            const Gap(50),
                            Row(children: [
                              SizedBox(
                                  width: 260,
                                  child: ListPickerField(
                                    label: '热点名称',
                                    items: [
                                      //...accessPoints.map((ap){return ap.ssid;}).toList(),
                                      ...accessPoints
                                          .where((ap) => ap.ssid.isNotEmpty)
                                          .map((ap) {
                                        return ap.ssid;
                                      }).toList(),
                                    ],
                                    controller: _formctl.controller('apname'),
                                    isRequired: true,
                                  )),
                              IconButton(
                                icon: const Icon(Icons.refresh),
                                onPressed: () async {
                                  await scanWifiAP();
                                  setState(() {
                                    searching = true;
                                  });
                                  Timer(Duration(seconds: 5), () async {
                                    await getScanResults();
                                    setState(() {
                                      searching = false;
                                    });
                                  });
                                },
                              ),
                            ]),
                            const Gap(20),
                            Row(
                              children: [
                                const Text('热点密码'),
                                const Gap(20),
                                SizedBox(
                                    width: 200,
                                    child: TextFormField(
                                      controller: _formctl.controller('appasswd'),
                                      validator: (v) {
                                        return v!.trim().isNotEmpty
                                            ? null
                                            : '密码不能为空';
                                      },
                                      focusNode: focusNode2,
                                    )),
                              ],
                            ),
                            const Gap(20),
                            Row(
                              children: [
                                const Text('音源命名'),
                                const Gap(20),
                                SizedBox(
                                    width: 200,
                                    child: TextFormField(
                                      controller: _formctl.controller(
                                          'deviceName',
                                          initialText: '默认音源'),
                                      focusNode: focusNode3,
                                    )),
                              ],
                            ),
                        const Gap(30),
                        Row(children: [
                          ElevatedButton(
                              style: ButtonStyle(
                                  padding: WidgetStatePropertyAll(
                                      EdgeInsets.fromLTRB(70, 10, 70, 10)),
                                  backgroundColor:
                                      WidgetStatePropertyAll<Color>(
                                    Color.fromRGBO(0x7a, 0x51, 0xe2, 100),
                                  )),
                              onPressed: () async {
                                focusNode1.unfocus();
                                focusNode2.unfocus();
                                focusNode3.unfocus();
                                if (_formctl.value('apname').isEmpty) {
                                  await showTipDialog();
                                } else {
                                  if (_formctl.validate()) {
                                    print('验证通过');
                                  }

                                  late final NativeCallable<NativeWifisetCallback> callback;
                                  void onResponse(int succcess) {
                                    // Remember to close the NativeCallable once the native API is
                                    // finished with it, otherwise this isolate will stay alive
                                    // indefinitely.
                                    callback.close();
                                    //context.goNamed(AppRoute.music.name);
                                    context.go('/music');
                                  }

                                  callback = NativeCallable<NativeWifisetCallback>.listener(onResponse);

                                  //final Pointer<NativeFunction<Void Function(Int)>> pointerToCallback = Pointer.fromFunction<Void Function(Int)>(setCallback);
                                  libmoc.wifiSet(
                                      value.data!,
                                      _formctl.value('apname'),
                                      _formctl.value('appasswd'),
                                      _formctl.value('deviceName'),
                                      callback.nativeFunction);
                                }
                              },
                              child: Text('确认',
                                  style: TextStyle(color: Colors.white)))
                        ]),
                          ],
                        ),
                      );                     
                    } else {
                  return Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        '正在搜寻音源设备',
                        textScaler: TextScaler.linear(1.8),
                      ),
                      const Gap(20),
                      Text(
                        '请连接至音源 wifi 进行配置',
                        style: TextStyle(fontWeight: FontWeight.w700),
                      ),
                      const Gap(10),
                      SizedBox(
                          height: 5,
                          width: containerWidth,
                          child: LinearProgressIndicator(
                            valueColor: AlwaysStoppedAnimation(
                                Color.fromRGBO(0x7a, 0x51, 0xe2, 100)),
                          ))
                    ],
                  );
                    }
                  },
                ),
              ],
            ),
          ),
        )
    );
  }
}

class showDeviceScreen extends StatefulWidget {
  final String deviceID;

  const showDeviceScreen({super.key, required this.deviceID});

  @override
  State<showDeviceScreen> createState() => _showDeviceScreenState();
}

class _showDeviceScreenState extends State<showDeviceScreen> {
  bool _isLoading = true;  
  late Msource meo;

  String dummys = '''{
    "deviceID": "bd939vASIF",
    "deviceName": "默认音源",
    "capacity": "128G",
    "useage": "73.2G",
    "percent": 0.34,
    "usbON": false,
    "autoPlay": false,
    "shareLocation": "//192.134.23.2/music/",
    "libraries": [
        {"name": "默认媒体库", "space": "239MB", "countSong": 129, "countCached": 22, "dft": true},
        {"name": "媒体库2", "space": "239MB", "countSong": 129, "countCached": 22, "dft": false},
        {"name": "媒体库3", "space": "239MB", "countSong": 129, "countCached": 22, "dft": false},
        {"name": "媒体库4", "space": "239MB", "countSong": 129, "countCached": 22, "dft": false},
        {"name": "工作以后", "space": "239MB", "countSong": 129, "countCached": 22, "dft": false}
    ]
}''';

  @override
  void initState() {
    super.initState();
    _fetchData(); // 调用异步方法
  }

  Future<void> _fetchData() async {
    await Future.delayed(Duration(seconds: 2));  
    setState(() {
      meo = Msource.fromJson(jsonDecode(dummys));
      _isLoading = false;
    });
  }

  Future<bool?> _showTipDialog() {
    return showDialog<bool>(
      context: context,
       builder: (context) {
        return AlertDialog(
          title: Text('提示'),
          content: Text('该媒体库已存在'),
          actions:<Widget> [
            TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text('知道了'))
          ]
        );
       }
    );
  }

  Future<void> _showAddItemDialog() async {
    String newItemName = ''; // 用于存储用户输入的名称

    await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('增加媒体库'),
          content: TextField(
            onChanged: (value) {
              newItemName = value; // 获取输入的文本
            },
            decoration: InputDecoration(hintText: "输入媒体库名称"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: Text('取消'),
            ),
            TextButton(
              onPressed: () async {
                if (newItemName.isNotEmpty) {
                  //bool exist = false;  
                  //meo.libraries.forEach((lib) {
                  //  if (lib.name == newItemName) exist = true;
                  //});
                  if (meo.libraries.any((lib) => lib.name == newItemName)) {
                    await _showTipDialog();
                  } else {
                    setState(() {
                      meo.libraries.add(MsourceLibrary.fromJson({'name': newItemName, 'space': '0MB', 'countSong': 0, 'countCached': 0, 'dft': false}));
                    });
                    Navigator.of(context).pop(); // 关闭对话框
                  }
                }
              },
              child: Text('确认'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width * 0.9;

    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    } else {
      return Scaffold(
        body: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
            Container(
            //页面一大框
            width: containerWidth,
            margin: EdgeInsets.only(top: 50, bottom: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                    // 第一坨
                    padding: EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(10), // 可选：圆角边框
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Icon(Icons.speaker),
                            Text('No. ' + meo.deviceName),
                            Spacer(),
                            CircleAvatar(
                              radius: 5,
                              backgroundColor: const Color.fromARGB(255, 87, 241, 32),
                            ),
                            const Gap(3),
                            Text(
                              '本地在线',
                              textScaler: TextScaler.linear(0.6),
                            ),
                          ],
                        ),
                        const Gap(10),
                        LinearProgressIndicator(
                          value: meo.percent,
                          minHeight: 5,
                        ),
                        const Gap(10),
                        Row(
                          children: [
                            Text(meo.useage),
                            Spacer(),
                            Text(meo.capacity),
                          ],
                        ),
                        const Gap(10),
                        Row(
                          children: [
                            Text('开机自动播放'),
                            Spacer(),
                            Switch(
                              onChanged : (bool value) {print('checked + ${value}');},
                              value: meo.autoPlay
                            )
                          ],
                        )
                      ],
                    )
                ),
                const Gap(20),
                Expanded(
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constrains) {
                      return Container(
                        // 第二坨
                        padding: EdgeInsets.all(10),
                        height: constrains.maxHeight,
                        decoration: BoxDecoration(
                          //color: const Color.fromARGB(255, 21, 140, 236),
                          color: Colors.grey[100],
                          border: Border.all(color: Colors.grey[400]!),
                          borderRadius: BorderRadius.circular(10), // 可选：圆角边框
                        ),
                        child: Column(
                          children: [
                            Row(
                              children: [
                                Text('共享路径：'),
                                Text(meo.shareLocation),
                                Spacer(),
                                Icon(Icons.usb),
                                Text('U盘已连接')
                              ],  
                            ),
                            Divider(
                              color: Colors.grey,
                              thickness: 2.0,
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: meo.libraries.length,
                                itemBuilder: (context, index) {
                                  return Column(
                                    children: [
                                      Row(
                                        //crossAxisAlignment: CrossAxisAlignment.end,  
                                        children: [
                                          Icon(Icons.folder),
                                          const Gap(10),
                                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(meo.libraries[index].name), Text('${meo.libraries[index].space} ${meo.libraries[index].countSong} 首歌曲 已缓存 ${meo.libraries[index].countCached} 首', textScaler: TextScaler.linear(0.8),)],),
                                          Spacer(),
                                          if (meo.libraries[index].dft) Icon(Icons.check),
                                          Icon(Icons.more_vert)
                                        ],
                                      ),
                                      const Gap(5),
                                    ],
                                  );                        
                                },
                              ),
                            )
                          ],  
                        )
                      );
                    }
                  ),
                ),
                ],
              )),
            ],
          )
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: _showAddItemDialog,
          child: Icon(Icons.add),
          tooltip: '创建媒体库',
        ),
      );
    }
  }
}