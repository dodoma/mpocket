import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:form_controller/form_controller.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:list_picker/list_picker.dart';
import 'package:mpocket/common/global.dart';
import 'package:mpocket/ffi/libmoc.dart' as libmoc;
import 'package:mpocket/models/imsource.dart';
import 'package:mpocket/models/msource.dart';
import 'package:mpocket/views/index_usb.dart';
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
    if (context.read<IMonline>().online == 0) {
      // 配置局域网内音源设备
      return ConfigDeviceScreen();
    } else {
      // 展示已配置的音源设备
      return showDeviceScreen(deviceID: Global.profile.msourceID);
    }
  }
}

class ConfigDeviceScreen extends StatefulWidget {
  const ConfigDeviceScreen ({super.key});

  @override
  State<ConfigDeviceScreen> createState() => _ConfigDeviceScreenState();
}

class _ConfigDeviceScreenState extends State<ConfigDeviceScreen> {
  Timer? _timer;
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
    _timer = Timer(Duration(seconds: 5), () async {
      await getScanResults();
      setState(() {
        searching = false;
      });
    });

    _formctl = FormController();
  }

  @override
  void dispose() {
     _formctl.dispose();
    _timer?.cancel();
    super.dispose();
  }

  scanWifiAP() async {
    // check platform support and necessary requirements
    final can = await WiFiScan.instance.canStartScan(askPermissions: true);
    switch(can) {
    case CanStartScan.yes:
      // start full scan async-ly
      print('start scanning wifi ap...');
      await WiFiScan.instance.startScan();
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
                  if (value.data![0] == 'a') {
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
                                          .where((ap) => ap.ssid.isNotEmpty && ap.ssid != 'AVM')
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
                                  void onResponse(int success) async {
                                    // Remember to close the NativeCallable once the native API is
                                    // finished with it, otherwise this isolate will stay alive
                                    // indefinitely.
                                    callback.close();
                                    if (success == 1) {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text('设置成功，请等待音源重启。'),
                                        duration: Duration(seconds: 2)
                                      ));
                                      await Future.delayed(Duration(seconds: 3), () { //等待 close 事件回调后，再切换页面
                                        context.read<IMsource>().setting = true;
                                        context.go('/music');
                                      });
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                        content: Text('设置失败，请重连AVM热点进行设置。'),
                                        duration: Duration(seconds: 2)
                                      ));
                                    }
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
    "remain": "73.2G",
    "percent": 0.34,
    "usbON": false,
    "autoPlay": false,
    "shareLocation": "//192.134.23.2/music/",
    "libraries": [
        {"name": "默认媒体库", "space": "239MB", "countTrack": 129, "countCached": 22, "dft": true},
        {"name": "媒体库2", "space": "239MB", "countTrack": 129, "countCached": 22, "dft": false},
        {"name": "媒体库3", "space": "239MB", "countTrack": 129, "countCached": 22, "dft": false},
        {"name": "媒体库4", "space": "239MB", "countTrack": 129, "countCached": 22, "dft": false},
        {"name": "工作以后", "space": "239MB", "countTrack": 129, "countCached": 22, "dft": false}
    ]
}''';

  @override
  void initState() {
    super.initState();
    _fetchData(); // 调用异步方法
  }

  Future<void> _fetchData() async {
    //await Future.delayed(Duration(seconds: 2)); 
    String emos = libmoc.msourceHome(Global.profile.msourceID); 
    setState(() {
      if (emos.isEmpty) {meo = Msource(); meo.deviceID = "";}
      else meo = Msource.fromJson(jsonDecode(emos));
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
              onPressed: () async {
                if (newItemName.isNotEmpty) {
                  //bool exist = false;  
                  //meo.libraries.forEach((lib) {
                  //  if (lib.name == newItemName) exist = true;
                  //});
                  if (meo.libraries.any((lib) => lib.name == newItemName)) {
                    await _showTipDialog();
                  } else {
                    String res = libmoc.msourceLibraryCreate(Global.profile.msourceID, newItemName);
                    await showDialog (
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('提示'),
                          content: res.isEmpty ? Text('创建成功') : Text(res),
                          actions:<Widget> [
                            TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text('知道了'))
                          ]
                        );
                      }
                    );
                    if (res.isEmpty) {
                      await libmoc.mnetStoreList(Global.profile.msourceID); //更新媒体库列表
                      setState(() {
                        meo.libraries.add(MsourceLibrary.fromJson({'name': newItemName, 'space': '0MB', 'countTrack': 0, 'countCached': 0, 'dft': false}));
                      });
                    }
                    Navigator.of(context).pop(); // 关闭对话框
                  }
                }
              },
              child: Text('确认'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // 关闭对话框
              },
              child: Text('取消'),
              style: TextButton.styleFrom(foregroundColor: Colors.grey),              
            ),
          ],
        );
      },
    );
  }

  Future<bool> confirmDialog(BuildContext context, String alertText) async {
    return await showDialog<bool> (
      context: context,
       builder: (context) {
        return AlertDialog(
          title: Text('提示'),
          content: Text(alertText),
          actions: [
            TextButton(onPressed: (){Navigator.of(context).pop(true);}, child: Text('确定')),
            TextButton(onPressed: (){Navigator.of(context).pop(false);}, child: Text('取消'), style: TextButton.styleFrom(foregroundColor: Colors.grey),)
          ]
        );
       }
    ) ?? false;
  }

  Future<String?> confirmMerge(BuildContext context, String libname) async {
    String destStore = meo.libraries.firstWhere((lib) => lib.name != libname).name;
    return await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setDialogState) {
            return AlertDialog(
              title: Text('合并 ${libname}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('请选择目标媒体库'),
                  DropdownButton(
                    items: meo.libraries.where((lib) => lib.name != libname).map((MsourceLibrary store) {
                        return DropdownMenuItem(child: Text(store.name), value: store.name);
                    }).toList(),
                    value: destStore,
                    onChanged: (String? val) async {
                      if (val is String) {
                        setDialogState(() {
                          destStore = val;
                        });  
                      }
                    }
                  )
                ],
              ),
              actions: [
                TextButton(onPressed: (){Navigator.of(context).pop(destStore);}, child: Text('确定')),
                TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text('取消'), style: TextButton.styleFrom(foregroundColor: Colors.grey),)
              ]
            );
          }
        );
      }
    );
  }

  Future<void> ListAction(BuildContext context, int action, String libname) async {
    switch (action) {
      case 0:
        //重命名
        final TextEditingController namectl = TextEditingController(text: libname);
        await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: Text('媒体库改名'),
              content: TextField(
                controller: namectl,
              ),
              actions: [
                TextButton(
                  child: Text('确定'),
                  onPressed: () async {
                    String res = libmoc.msourceLibraryRename(Global.profile.msourceID, libname, namectl.text);
                    await showDialog(
                      context: context,
                      builder: (context) {
                        return AlertDialog(
                          title: Text('提示'),
                          content: res.isEmpty ? Text('修改成功') : Text(res),
                          actions:<Widget> [
                            TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text('知道了'))
                          ]
                        );
                      }
                    );
                    if (res.isEmpty) {
                      await libmoc.mnetStoreList(Global.profile.msourceID); //更新媒体库列表
                      int libindex = meo.libraries.indexWhere((lib) => lib.name == libname);
                      if (libindex != -1) {
                        setState(() {
                          meo.libraries[libindex].name = namectl.text;
                        });
                      }
                    }
                    Navigator.of(context).pop(); // 关闭对话框
                  },
                ),
                TextButton(
                  child: Text('取消'),
                  style: TextButton.styleFrom(foregroundColor: Colors.grey),
                  onPressed: () {
                    Navigator.of(context).pop(); // 关闭对话框
                  },
                ),
              ],
            );
          }
        );
      break;
      case 1:
        // 设为默认
        String res = libmoc.msourceLibrarySetDefault(Global.profile.msourceID, libname);
        if (res.isEmpty) {
          Global.profile.defaultLibrary = libname;
          Global.saveProfile();
          await libmoc.mnetStoreList(Global.profile.msourceID); //更新媒体库列表
          setState(() {
            meo.libraries.forEach((lib) {
              if (lib.name == libname) lib.dft = true;
              else lib.dft = false;
            });
          });
          Navigator.of(context).pop();
        } else {
          await showDialog(
            context: context, 
            builder: (context) {
              return AlertDialog(
                title: Text('提示'),
                content: Text(res),
                actions:<Widget> [
                  TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text('知道了'))
                ]
              );
            }
          );
        }
      break;
      case 2:
        // 缓存媒体库
        bool confirm = await confirmDialog(context, '确认同步 ${libname} 下所有的曲目？');
        if (confirm) {
          libmoc.omusicSyncStore(Global.profile.msourceID, libname);
          Navigator.of(context).pop();
        }
      break;
      case 3:
        // 清除缓存
        bool confirm = await confirmDialog(context, '清除媒体库 ${libname} 中本地缓存？');
        if (confirm) {
          Navigator.of(context).pop();

          int delnum = libmoc.omusicClearStore(Global.profile.msourceID, libname, false);
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text('成功删除 ${delnum} 个文件'),
            duration: Duration(seconds: 3)
          ));
        }
      break;
      case 4:
        // 删除媒体库
        int libindex = meo.libraries.indexWhere((lib) => lib.name == libname);
        bool containMedia = false;
        if (libindex != -1) {
          if (meo.libraries[libindex].countTrack > 0) containMedia = true;
        }
        if (containMedia) {
          bool confirm = await confirmDialog(context, '确认删除媒体库 ${libname} 中所有文件？\n\n 删除后不可恢复');
          if (confirm) {
            libmoc.omusicClearStore(Global.profile.msourceID, libname, true);
            String res = libmoc.msourceLibraryDelete(Global.profile.msourceID, libname, true);
            if (res.isEmpty) {
              await libmoc.mnetStoreList(Global.profile.msourceID);
              setState(() {
                meo.libraries.removeAt(libindex);
              });
              Navigator.of(context).pop();
            } else {
              await showDialog(
                context: context, 
                builder: (context) {
                  return AlertDialog(
                    title: Text('提示'),
                    content: Text(res),
                    actions:<Widget> [
                      TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text('知道了'))
                    ]
                  );
                }
              );
            }
          }
        } else {
          // 空的媒体库，直接删掉
          libmoc.omusicClearStore(Global.profile.msourceID, libname, true);
          String res = libmoc.msourceLibraryDelete(Global.profile.msourceID, libname, false);
          if (res.isEmpty) {
            await libmoc.mnetStoreList(Global.profile.msourceID);
            setState(() {
              meo.libraries.removeAt(libindex);
            });
            Navigator.of(context).pop();
          } else {
            await showDialog(
              context: context, 
              builder: (context) {
                return AlertDialog(
                  title: Text('提示'),
                  content: Text(res),
                  actions:<Widget> [
                    TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text('知道了'))
                  ]
                );
              }
            );
          }
        }
      break;
      case 5:
        // 合并媒体库
        int libindex = meo.libraries.indexWhere((lib) => lib.name == libname);
        String? destStore = await confirmMerge(context, libname);
        print("xxx ${libname} ${destStore}");
        if (destStore != null) {
          libmoc.omusicClearStore(Global.profile.msourceID, libname, true);
          String res = libmoc.msourceLibraryMerge(Global.profile.msourceID, libname, destStore);
          if (res.isEmpty) {
            await libmoc.mnetStoreList(Global.profile.msourceID);
            setState(() {
              meo.libraries.removeAt(libindex);
            });
            Navigator.of(context).pop();
          } else {
            await showDialog(
              context: context, 
              builder: (context) {
                return AlertDialog(
                  title: Text('提示'),
                  content: Text(res),
                  actions:<Widget> [
                    TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text('知道了'))
                  ]
                );
              }
            );
          }
        }
      break;
      case 6:
        // 添加 u 盘媒体文件
      break;
      default:
        print('暂未实现');
      break;
    }
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 检查当前的上下文是否依然有效（防止页面被销毁时仍然调用 Navigator）
      if (context.mounted) {
        context.read<IMbanner>().turnOffBanner();
      }
    });
    double containerWidth = MediaQuery.of(context).size.width * 0.9;

    if (_isLoading) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    } else {
      if (meo.deviceID.isEmpty) return Scaffold(body: Center(child: Text('获取数据失败')));
      else return Scaffold(
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
                          ],
                        ),
                        const Gap(10),
                        LinearProgressIndicator(
                          value: meo.percent,
                          minHeight: 5,
                        ),
                        const Gap(10),
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Text('${meo.useage} 已用 '),
                            Text('${meo.remain} 可用', textScaler: TextScaler.linear(0.8)),
                            Spacer(),
                            Text('总容量 ${meo.capacity}'),
                          ],
                        ),
                        const Gap(10),
                        Row(
                          children: [
                            Text('开机自动播放'),
                            Spacer(),
                            Switch(
                              onChanged : (bool value) {
                                print('checked + ${value}');
                                String res = libmoc.msourceSetAutoPlay(Global.profile.msourceID, !meo.autoPlay);
                                if (res.isEmpty) {
                                  setState(() {
                                    meo.autoPlay = !meo.autoPlay;
                                  });
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                                    content: Text('设置自动播放失败 ${res}'),
                                    duration: Duration(seconds: 3)
                                  ));
                                }
                              },
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
                                Text('\\\\${meo.shareLocation}'),
                                Spacer(),
                                if (meo.usbON) 
                                  GestureDetector(
                                    child: Text('导入U盘文件', style: TextStyle(color: Colors.green), overflow: TextOverflow.ellipsis, maxLines: 1,),
                                    onTap: () async {
                                      pickUSBFolder(context);
                                    },
                                  ),
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
                                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(meo.libraries[index].name), Text('${meo.libraries[index].space} ${meo.libraries[index].countTrack} 首歌曲', textScaler: TextScaler.linear(0.8),)],),
                                          Spacer(),
                                          if (meo.libraries[index].dft) Icon(Icons.check),
                                          IconButton(icon: Icon(Icons.more_vert), onPressed: () {
                                            showModalBottomSheet(
                                              context: context, 
                                              builder: (BuildContext context) {
                                                final actions = [
                                                  {'name': '设为默认媒体库',  'val': 1, 'icon': Icon(Icons.check)},
                                                  {'name': '重命名',         'val': 0, 'icon': Icon(Icons.edit)},
                                                  {'name': '全部缓存至本地',  'val': 2, 'icon': Icon(Icons.sync)},
                                                  {'name': '清除本地缓存',    'val': 3, 'icon': Icon(Icons.delete_outline)},
                                                  {'name': '删除媒体库',      'val': 4, 'icon': Icon(Icons.delete_forever)},
                                                  {'name': '合并媒体库',      'val': 5, 'icon': Icon(Icons.merge)},
                                                  //{'name': '添加U盘媒体文件', 'val': 6, 'icon': Icon(Icons.usb)},
                                                ];
                                                return Padding(
                                                  padding: const EdgeInsets.all(20),
                                                  child: Column(
                                                    children: [
                                                      Container(
                                                        width: containerWidth * 0.8,
                                                        child: Text(meo.libraries[index].name, style: TextStyle(fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis, maxLines: 1,)
                                                      ),
                                                      const Gap(20),
                                                      Expanded(
                                                        child: ListView.builder(
                                                          itemCount: actions.length,
                                                          itemBuilder: (context, indexj) {
                                                            final act = actions[indexj];
                                                            return ListTile(
                                                              leading: act['icon'] as Icon,
                                                              title: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(act['name'] as String),
                                                                  Divider( height: 1, color: Colors.grey,)
                                                                ],
                                                              ),
                                                              onTap: () async {
                                                                await ListAction(context, act['val'] as int, meo.libraries[index].name);
                                                              },
                                                            );
                                                          }
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              }
                                            );
                                          },)
                                        ],
                                      ),
                                      const Gap(10),
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
