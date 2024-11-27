import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:json_annotation/json_annotation.dart';
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
  final ValueNotifier<List<String>> crumbs = ValueNotifier(<String>['.']);
  final ScrollController addressBarScrollController = ScrollController();
  String? volume;

  String emot = '''
[
  {"type": 0, "name": "fucku/", "trackCount": 10},
  {"type": 0, "name": "android/", "trackCount": 13},
  {"type": 1, "name": "xx.mp3"},
  {"type": 1, "name": "yy.mp3"},
  {"type": 0, "name": "fucku/", "trackCount": 10},
  {"type": 0, "name": "android/", "trackCount": 13},
  {"type": 1, "name": "xx.mp3"},
  {"type": 1, "name": "yy.mp3"},
  {"type": 0, "name": "fucku/", "trackCount": 10},
  {"type": 0, "name": "android/", "trackCount": 13},
  {"type": 1, "name": "xx.mp3"},
  {"type": 1, "name": "yy.mp3"},
  {"type": 2, "name": "我们是工程.txt"}
]
''';

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
    if (directory.isNotEmpty) {
      crumbs.value.add(basename(directory));
      crumbs.notifyListeners();
      scrollAddressBarToRight();
      debugPrint(crumbs.value.toString());
    }

    List<dynamic> jsonData = jsonDecode(emot);
    final List<DirEntry> nodes = jsonData.map((obj) => DirEntry.fromJson(obj)).toList();
    final showMovedUpButtom = crumbs.value.length > 1;

    await Navigator.of(_navigatorKey.currentContext!).pushNamed(
      '/listDir',
      arguments: Scrollbar(
        child: ListView.separated(
          itemCount: nodes.length + (showMovedUpButtom ? 1 : 0),
          itemBuilder: (context, i) {
            if (i == 0 && showMovedUpButtom) {
              return Material(
                color: Colors.transparent,  
                child: ListTile(
                  dense: false,
                  enabled: showMovedUpButtom,
                  onTap: () async {
                    crumbs.value.removeLast();
                    crumbs.notifyListeners();
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
                  enabled: nodes[i].type == 0,
                  onTap: nodes[i].type == 0
                    ? () => pushDirectoryIntoStack(context, nodes[i].name)
                    : null,
                  leading: CircleAvatar(
                    foregroundColor: Theme.of(context).iconTheme.color,
                    backgroundColor: Colors.transparent,
                    child: nodes[i].type == 0
                      ? const Icon(Icons.folder_outlined, size: 24,)
                      : nodes[i].type == 1
                        ? const Icon(Icons.music_note, size: 24)
                        : const Icon(Icons.description_outlined, size: 24,)
                  ),
                  title: Text(basename(nodes[i].name), maxLines: 1, overflow: TextOverflow.ellipsis,),
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
        volume = '';
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
          crumbs.value.removeLast();
          crumbs.notifyListeners();
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
              child: ValueListenableBuilder<List<String>>(
                valueListenable: crumbs,
                builder: (context, stack, _) => volume == null
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
                            child: Text(stack[i])
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
            ValueListenableBuilder<List<String>>(
              valueListenable: crumbs,
              builder: (context, stack, _) => Container(
                padding: EdgeInsets.all(8.0),
                width: MediaQuery.of(context).size.width,
                child: ElevatedButton(
                  onPressed: stack.length <= 1
                      ? null
                      : () async {
                          final path = joinAll(stack.sublist(1));
                          debugPrint(path);
                          //final result = Directory(path);
                          //Navigator.of(context).maybePop(
                          //  await result.exists_() ? result : null,
                          //);
                        },
                  child: Text('选择该目录'),
                ),
              ),
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

void pickUSBFolder(BuildContext context) async {
  final directory = await pickRemoteDirectory(context);
  print("xxxxxx ${directory}");
}