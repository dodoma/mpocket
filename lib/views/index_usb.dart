import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:mpocket/common/global.dart';
import 'package:mpocket/ffi/libmoc.dart' as libmoc;
import 'package:mpocket/models/omusicstore.dart';
import 'package:path/path.dart' hide context;

@JsonSerializable()
class DirEntry {
  DirEntry();

  late int type;      /* 0 directory, 1 music file, 2 other file */
  late String name;
  late int? trackCount;

  factory DirEntry.fromJson(Map<String, dynamic> json) => _$DirEntryFromJson(json);
  Map<String, dynamic> toJson() => _$DirEntryToJson(this);
}

@JsonSerializable()
class DirInfo {
  DirInfo();

  late int trackCount;
  late List<DirEntry> nodes;

  factory DirInfo.fromJson(Map<String, dynamic> json) => _$DirInfoFromJson(json);
  Map<String, dynamic> toJson() => _$DirInfoToJson(this);
}

DirEntry _$DirEntryFromJson(Map<String, dynamic> json) =>
    DirEntry()
      ..type = json['type'] as int
      ..name = json['name'] as String
      ..trackCount = json['trackCount'] as int?;

Map<String, dynamic> _$DirEntryToJson(DirEntry instance) =>
    <String, dynamic>{
      'type': instance.type,
      'name': instance.name,
      'trackCount': instance.trackCount,
    };

DirInfo _$DirInfoFromJson(Map<String, dynamic> json) => DirInfo()
  ..trackCount = json['trackCount'] as int
  ..nodes = (json['nodes'] as List<dynamic>)
      .map((e) => DirEntry.fromJson(e as Map<String, dynamic>))
      .toList();

Map<String, dynamic> _$DirInfoToJson(DirInfo instance) =>
    <String, dynamic>{
      'trackCount': instance.trackCount,
      'nodes': instance.nodes,
    };

class Crumb {
  String name;
  int mediaCount;

  Crumb(this.name, this.mediaCount);

  void printInfo()
  {
    print("名称 ${name}, 个数 ${mediaCount}");
  }
}

class NoOverscrollGlowBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
      BuildContext context, Widget child, ScrollableDetails details) {
    return child;
  }
}

class DirectoryPickerScreen extends StatefulWidget {
  const DirectoryPickerScreen({super.key});

  @override
  State<DirectoryPickerScreen> createState() => _DirectoryPickerScreenState();
}

class _DirectoryPickerScreenState extends State<DirectoryPickerScreen> {
  // 使用 _navigatorKey 实现局部导航，让导航局限在当前 SubPage 范围内，而不会影响主 Navigator。
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();
  //final ValueNotifier<List<String>> crumbs = ValueNotifier(<String>['.']);
  //final ValueNotifier<List<Crumb>> crumbs = ValueNotifier(<Crumb>[Crumb('.', 0)]);
  final ValueNotifier<List<Crumb>> crumbs = ValueNotifier([]);
  final ScrollController addressBarScrollController = ScrollController();
  String? volume;

  String emot = '''
{
  "trackCount": 10,
  "nodes": [
    {"type": 0, "name": "foo"},
    {"type": 0, "name": "android"},
    {"type": 1, "name": "xx.mp3"},
    {"type": 1, "name": "yy.mp3"}
  ]
}
''';

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
  
  void scrollAddressBarToRight() async {
    await Future.delayed(const Duration(milliseconds: 400));
    try {
      debugPrint(
        addressBarScrollController.position.maxScrollExtent.toString(),
      );
      if (addressBarScrollController.hasClients) {
        addressBarScrollController.jumpTo(
          addressBarScrollController.position.maxScrollExtent,
        );
      }
    } catch (exception, stacktrace) {
      debugPrint(exception.toString());
      debugPrint(stacktrace.toString());
    }
  }

  Future<void> pushDirectoryIntoStack(BuildContext context, String directory) async {
    String emo = libmoc.msourceDirectoryInfo(Global.profile.msourceID, directory);
    late DirInfo dirinfo;
    if (emo.isEmpty) {
      await Navigator.of(_navigatorKey.currentContext!).pushNamed(
        '/listDir',
        arguments: Text('获取数据失败，请确保u盘正确连接')
      );
      return;
    } else {
      try {
        dirinfo = DirInfo.fromJson(jsonDecode(emo));
      } catch (e) {
        await Navigator.of(_navigatorKey.currentContext!).pushNamed(
          '/listDir',
          arguments: Text(emo)
        );
        return;
      }
    }

    dirinfo.nodes.sort((a, b) {
      if (a.type == 0 && b.type == 1) return -1;
      if (a.type == 1 && b.type == 0) return 1;
      return a.name.compareTo(b.name);
    });

    crumbs.value = [
      ...crumbs.value,
      Crumb(basename(directory), dirinfo.trackCount)
    ];
    scrollAddressBarToRight();
    //crumbs.value.forEach((crumb) {
    //  crumb.printInfo();
    //});

    final showMovedUpButtom = crumbs.value.length > 1;

    await Navigator.of(_navigatorKey.currentContext!).pushNamed(
      '/listDir',
      arguments: Scrollbar(
        child: ListView.separated(
          itemCount: dirinfo.nodes.length + (showMovedUpButtom ? 1 : 0),
          itemBuilder: (context, i) {
            if (i == 0 && showMovedUpButtom) {
              return Material(
                color: Colors.transparent,  
                child: ListTile(
                  dense: false,
                  enabled: showMovedUpButtom,
                  onTap: () async {
                    crumbs.value = crumbs.value.sublist(0, crumbs.value.length-1);
                    Navigator.of(context).pop();
                    scrollAddressBarToRight();
                  },
                  leading: CircleAvatar(
                    child: Icon(Icons.arrow_upward, size: 24,),
                    foregroundColor: Theme.of(context).iconTheme.color,
                    backgroundColor: Colors.transparent,
                  ),
                  title: Text('...'),
                )
              );
            } else {
              if (showMovedUpButtom) i--;
              return Material(
                color: Colors.transparent,
                child: ListTile(
                  dense: false,
                  enabled: dirinfo.nodes[i].type == 0,
                  onTap: dirinfo.nodes[i].type == 0
                    ? () => pushDirectoryIntoStack(context, crumbs.value.length > 1
                                                              ? crumbs.value.sublist(1, crumbs.value.length).map((crumb) => crumb.name).join('/') + '/' + dirinfo.nodes[i].name + '/'
                                                              : dirinfo.nodes[i].name + '/')
                    : null,
                  leading: CircleAvatar(
                    foregroundColor: Theme.of(context).iconTheme.color,
                    backgroundColor: Colors.transparent,
                    child: dirinfo.nodes[i].type == 0
                      ? const Icon(Icons.folder_outlined, size: 24,)
                      : dirinfo.nodes[i].type == 1
                        ? const Icon(Icons.music_note, size: 24)
                        : const Icon(Icons.description_outlined, size: 24,)
                  ),
                  title: Text(basename(dirinfo.nodes[i].name), maxLines: 1, overflow: TextOverflow.ellipsis,),
                ),
              );
            }
          }, 
          separatorBuilder: (context, i) => const Divider(
            indent: 72,
            height: 1,
            thickness: 1,
          ), 
        ),
      )
    );
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (volume == null) {
        volume = '/';
        setState(() {});
        await pushDirectoryIntoStack(context, volume!);
      }
    });
  }

  @override
  void dispose() {
    addressBarScrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        await Navigator.of(_navigatorKey.currentContext!).maybePop();

        if (crumbs.value.length > 1) {
          crumbs.value = crumbs.value.sublist(0, crumbs.value.length-1);
          return false;
        } else return true;
      },
      child: Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(Icons.close),
            splashRadius: 20.0,
          ),
          title: Text('选择同步目录'),
          bottom: PreferredSize(
            child: Container(
              height: 64.0,
              width: MediaQuery.of(context).size.width,
              child: ValueListenableBuilder<List<Crumb>>(
                valueListenable: crumbs,
                builder: (context, stack, _) => stack.length <= 0
                    ? const SizedBox(height: 64.0)
                    : ScrollConfiguration(
                        behavior: NoOverscrollGlowBehavior(),
                        child: ListView.separated(
                          physics: ClampingScrollPhysics(),
                          key: ValueKey(
                            'directory_screen_picker/address_bar',
                          ),
                          controller: addressBarScrollController,
                          padding: EdgeInsets.symmetric(horizontal: 16.0),
                          scrollDirection: Axis.horizontal,
                          itemBuilder: (context, i) => Container(
                            alignment: Alignment.center,
                            child: Text(stack[i].name)
                          ),
                          separatorBuilder: (context, i) => Container(
                            height: 64.0,
                            width: 32.0,
                            child: Icon(Icons.chevron_right),
                          ),
                          itemCount: stack.length,
                        ),
                      ),
              ),
            ),
            preferredSize: Size(
              MediaQuery.of(context).size.width,
              64.0,
            ),
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: Navigator(
                key: _navigatorKey,
                onGenerateRoute: (settings) {
                  final Widget? page = settings.arguments as Widget?;
                  if (page != null) {
                    return MaterialPageRoute(
                      builder: (context) => page,
                      settings: settings,
                    );
                  }
      
                  // 默认页面
                  return MaterialPageRoute(
                    builder: (context) => Scaffold(
                      body: Center(child: Text('Unknown route: ${settings.name}')),
                    ),
                  );
                },
              ),
            ),
            GestureDetector(
              child: Align(
                alignment: Alignment.centerRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 5.0, bottom: 5.0, right: 18.0),
                  child: Text('深度同步当前目录', style: TextStyle(color: Colors.green), overflow: TextOverflow.ellipsis, maxLines: 1,),
                )
              ),
              onTap: () async {
                String path = '/' + crumbs.value.where((crumb) => crumb.name != '/').map((crumb) => crumb.name).join('/');
                if (crumbs.value.length > 1) path += '/';
                debugPrint(path);

                bool confirm = await confirmDialog(context, '确认递归添加 ${path} 及其子目录下所有媒体文件？\n\n这可能会占用音源较大存储空间。');
                if (confirm) {
                  Navigator.of(context).pop(path);
                }
              },
            ),
            ValueListenableBuilder<List<Crumb>>(
              valueListenable: crumbs,
              builder: (context, stack, _) { 
                return Container(
                padding: EdgeInsets.all(8.0),
                width: MediaQuery.of(context).size.width,
                child: stack.length > 0
                  ? ElevatedButton(
                      onPressed: stack.last.mediaCount <= 0
                          ? null
                          : () async {
                              String path = stack.where((crumb) => crumb.name != '/').map((crumb) => crumb.name).join('/');
                              if (crumbs.value.length > 1) path += '/';
                              debugPrint(path);
                              Navigator.of(context).pop(path);
                              //Navigator.of(context).maybePop(path);
                            },
                      child: stack.last.mediaCount <= 0 ? Text('无媒体文件') : Text('选择该目录 (${stack.last.mediaCount}个媒体文件)'),
                    )
                  : Text('数据加载中')
              );
              }
            ),
          ]
        )
      ),
    );
  }
}

Future<String?> pickRemoteDirectory(BuildContext context) async {
  return showGeneralDialog(
    context: context, 
    useRootNavigator: true,
    barrierColor: Colors.transparent,
    pageBuilder: (context, animation, secondaryAnimation) => DirectoryPickerScreen(),
  );
}

Future<String?> confirmLibrary(BuildContext context) async {
  String emot = libmoc.omusicStoreList(Global.profile.msourceID);
  List<dynamic> jsonData = jsonDecode(emot);
  List<OmusicStore> storelist = jsonData.map((obj) => OmusicStore.fromJson(obj)).toList();
  String destStore = storelist.firstWhere((store) => store.moren == true).name;

  return await showDialog(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (BuildContext context, StateSetter setDialogState) {
          return AlertDialog(
            title: Text('选择目标媒体库'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('请选择目标媒体库'),
                DropdownButton(
                  items: storelist.map((OmusicStore store) {
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

void pickUSBFolder(BuildContext context) async {
  final directory = await pickRemoteDirectory(context);
  if (directory != null) {
    final libname = await confirmLibrary(context);
    if (libname != null) {
      print("xxxxxx ${directory}, to ${libname}");
      int ret = libmoc.msourceMediaCopy(Global.profile.msourceID, directory, libname, directory[0] == '/' ? true : false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: ret == 0 ? Text('触发拷贝失败') : Text('开始拷贝媒体文件'),
        duration: Duration(seconds: 3)
      ));
    }
  }
}