import 'dart:async';
import 'dart:convert';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mpocket/common/global.dart';
import 'package:mpocket/ffi/libmoc.dart' as libmoc;
import 'package:mpocket/models/imlocal.dart';
import 'package:mpocket/models/imsource.dart';
import 'package:mpocket/models/omusic.dart';
import 'package:mpocket/models/omusicstore.dart';
import 'package:mpocket/views/music_artist_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

typedef NativePlayInfoCallback = Void Function(Int, Pointer<Utf8>, Pointer<Utf8>);

class MusicScreen extends StatefulWidget {
  const MusicScreen({
    super.key,
  });

  @override
  State<MusicScreen> createState() => _MusicScreenState();
}

class _MusicScreenState extends State<MusicScreen> {

  Future<String> fetchData() async {
    await Future.delayed(Duration(seconds: 2));
    return 'b342d90visdv';
  }

  Future<void> initStorage() async {
    await _requestStoragePermission();
  }

  late Future<String> sourceID = libmoc.mocDiscovery();

  // 检查并请求存储权限
  Future<void> _requestStoragePermission() async {
    var status = await Permission.storage.status;
    if (!status.isGranted) {
      // 请求权限
      await Permission.storage.request();
    }

    if (await Permission.storage.isGranted) {
      // 用户授予了权限，执行相关操作
      print("Storage permission granted");
    } else {
      // 用户拒绝了权限请求
      print("Storage permission denied");
    }
  }

  @override
  void initState() {
    initStorage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width * 0.9;
    double containerHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<String>(
              //future: fetchData(), 
              future: sourceID,
              builder: (BuildContext context, AsyncSnapshot<String> value) {
                if (!value.hasData) {
                  if (context.read<IMsource>().setting == true) {
                    // 音源正在配置中
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text('正在连接音源设备', textScaler: TextScaler.linear(1.6)),
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
                  } else {
                    if (Global.profile.msourceID.isNotEmpty) {
                      //按理说，此时应该有 Global 的 deviceID (除非路由器没正常干活)
                      return showMusicScreen(deviceID: Global.profile.msourceID, 
                        maxWidth: containerWidth,
                        maxHeight: containerHeight
                      );
                    } else return SizedBox.shrink();
                  }
                } else {
                    context.read<IMsource>().setting = false;

                    //连上的是个还没配网的音源
                    if (value.data![0] == 'b') {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (context.mounted) {
                          context.go('/msource');
                        }
                      });
                      return Container();
                    }
            
                    context.read<IMonline>().onOnline(value.data!);
                    context.read<IMonline>().bindOffline();
                    context.read<IMbanner>().bindReceiving();
                    context.read<IMbanner>().bindFileReceived();
                    context.read<IMbanner>().bindReceiveDone();
                    context.read<IMnotify>().bindUdiskMount();
                    Global.profile.msourceID = value.data!;
                    Global.profile.storeDir = Global.profile.appDir + "/${value.data}/";
                    Global.saveProfile();

                    // 开始展示干货
                    return showMusicScreen(deviceID: value.data!, 
                      maxWidth: containerWidth,
                      maxHeight: containerHeight,
                    );
                  }
              }
            )
          ],
        ),
      )
    );
  }
}

class showMusicScreen extends StatefulWidget {
  final String deviceID;
  final double maxWidth;
  final double maxHeight;

  const showMusicScreen({super.key, required this.deviceID, 
    required this.maxWidth, required this.maxHeight});

  @override
  State<showMusicScreen> createState() => _showMusicScreenState();
}

class _showMusicScreenState extends State<showMusicScreen> {
  bool _isLoading = true;
  late Omusic meo;
  late List<OmusicStore> storelist;
  bool phonePlay = Global.profile.phonePlay;
  String _dftStore = Global.profile.defaultLibrary.isEmpty ? "默认媒体库" : Global.profile.defaultLibrary;
  List<String> filteredItems = ['aa', 'bb', 'cc'];
  final LayerLink _layerLink = LayerLink();
  OverlayEntry? _overlayEntry;

  String dummys = '''
{
    "deviceID": "bd939vASIF",
    "countArtist": 80,
    "countAlbum": 21,
    "countTrack": 219,
    "localPlay": true,
    "artists": [
        {"name": "Black Pink", "avt": "assets/image/caiQ.jfif"},
        {"name": "Link Park", "avt": "assets/image/linkP.jfif"},
        {"name": "乐器二胡", "avt": "assets/image/erhu.jfif"},
        {"name": "Black Pink", "avt": "assets/image/caiQ.jfif"},
        {"name": "Link Park", "avt": "assets/image/linkP.jfif"},
        {"name": "乐器二胡", "avt": "assets/image/erhu.jfif"},
        {"name": "Santana", "avt": "assets/image/deepF.jfif"}
    ]
}
''';

  Future<void> _fetchData() async {
    if (mounted) {
      libmoc.omusicStoreSelect(Global.profile.msourceID, Global.profile.defaultLibrary.isEmpty ? "默认媒体库" : Global.profile.defaultLibrary);
      String emos = libmoc.omusicHome(Global.profile.msourceID);
      String emot = libmoc.omusicStoreList(Global.profile.msourceID);
      List<dynamic> jsonData = jsonDecode(emot);
      setState(() {
        if (emos.isEmpty) {meo = Omusic(); meo.deviceID = "";}
        else meo = Omusic.fromJson(jsonDecode(emos));
        storelist = jsonData.map((obj) => OmusicStore.fromJson(obj)).toList();
        _dftStore = storelist.firstWhere((store) => store.moren == true).name;
        _isLoading = false;
      });
      if (Global.profile.defaultLibrary != _dftStore) {
        print("GLOBAL set default library from ${Global.profile.defaultLibrary} to ${_dftStore}");
        Global.profile.defaultLibrary = _dftStore;
        Global.saveProfile();
      }
    }
  }

  @override
  void initState() {
    //context.read<IMsource>().bindPlayInfo();
    _fetchData(); // 调用异步方法
    super.initState();
  }

  @override
  void dispose() {
    _overlayEntry?.remove();
    super.dispose();
  }

  void showOverlay(BuildContext context) {
    if (_overlayEntry != null) _overlayEntry!.remove();

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return Positioned(
          width: widget.maxWidth,
          height: widget.maxHeight - 150,
          child: CompositedTransformFollower(
            link: _layerLink,
            showWhenUnlinked: false,
            offset: Offset(0, 60),
            child: Material(
              elevation: 4.0,
              child: DraggableScrollableSheet(
                initialChildSize: 1.0,  
                //minChildSize: 0.2,
                //maxChildSize: 1.0,
                builder: (context, scrollController) {
                  return ListView.builder(
                    //shrinkWrap: true,  
                    //physics: ClampingScrollPhysics(),
                    controller: scrollController,
                    itemCount: filteredItems.length,
                    itemBuilder: (context, index) {
                      return ListTile(
                        title: Text(filteredItems[index]),
                        onTap: (){
                          print('select item ${filteredItems[index]}');
                          _overlayEntry?.remove();
                          _overlayEntry = null;
                        },
                      );
                    }
                  );
                }
              )
            ),
          )
        );
      }
    );

    Overlay.of(context).insert(_overlayEntry!);
  }

  void searchMusic(value) {
    filteredItems.add(value);
    filteredItems.add('Santana');
    filteredItems.add('Black Pink');
    
    if (filteredItems.isNotEmpty) {
      showOverlay(context);
    } else {
      _overlayEntry?.remove();
      _overlayEntry = null;  
    }
  }

  void _showSnackBar(BuildContext context) {
    String message = '音频将在音源播放';
    if (phonePlay) message = '音频将在手机播放';
    final snackBar = SnackBar(content: Text(message), duration: Duration(seconds: 3),);
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  @override
  Widget build(BuildContext context) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // 检查当前的上下文是否依然有效（防止页面被销毁时仍然调用 Navigator）
      if (context.mounted) {
        context.read<IMbanner>().turnOnBanner();
      }
    });
    context.read<IMsource>().bindPlayInfo();
    int online = context.watch<IMonline>().online;
  if (_isLoading) {
  return CircularProgressIndicator();
  } else {
  if (meo.deviceID.isEmpty) return Scaffold(body: Center(child: Text('获取数据失败')));
  else return Container(
    // 页面一大框
    width: widget.maxWidth,
    margin: EdgeInsets.only(top:10, bottom: 10),
    child: Column(
      //mainAxisSize: MainAxisSize.min,
      children: [
          //搜索
          CompositedTransformTarget(
            link: _layerLink,  
            child: TextField( 
              onChanged: (value) {searchMusic(value);},
              decoration: InputDecoration(
                labelText: '搜索媒体库',
                hintText: '搜索 曲名 · 专辑 · 艺术家',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8)
                )
              ),
            ),
          ),
          const Gap(20),
          Container(
            // 第二坨
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(10)
            ),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        if (online == 1)
                          CircleAvatar(
                            radius: 5,
                            backgroundColor: const Color.fromARGB(255, 87, 241, 32),
                          )
                        else
                          CircleAvatar(
                            radius: 5,
                            backgroundColor: Colors.grey,
                          ),
                        const Gap(5),
                        //Text('默认媒体库'),
                        //Icon(Icons.arrow_drop_down)
                        DropdownButton(
                          items: storelist.map((OmusicStore store) {
                            return DropdownMenuItem(child: Text(store.name), value: store.name);
                          }).toList(),
                          value: _dftStore,
                          onChanged: (String? val) async {
                            if (val is String) {
                              libmoc.omusicStoreSelect(Global.profile.msourceID, val);
                              libmoc.mnetStoreSwitch(Global.profile.msourceID, val);
                              await libmoc.mnetStoreSync(Global.profile.msourceID, val);
                              String emos = libmoc.omusicHome(Global.profile.msourceID);
                              try {
                              setState(() {
                                meo = Omusic.fromJson(jsonDecode(emos));
                                _dftStore = val;
                              });  
                              } catch (e) {
                                print("xxxxxx emos decode error");
                              }
                            }
                          }
                        )
                      ],
                    ),
                    const Gap(2),
                    Text('${meo.countAlbum} 位艺术家  ${meo.countAlbum} 张专辑  ${meo.countTrack} 首歌曲', textScaler: TextScaler.linear(0.6))
                  ],
                ),
                Spacer(),
                phonePlay ? IconButton(icon: Icon(Icons.phone_iphone, size: 32, color: Colors.green), onPressed: () {
                  setState(() {
                    phonePlay = false;
                  });
                  Global.profile.phonePlay = false;
                  Global.saveProfile();
                  _showSnackBar(context);
                },)
                : IconButton(icon: Icon(Icons.phone_iphone, size: 32, color: Colors.grey,), onPressed: () {
                  setState(() {
                    phonePlay = true;
                  });
                  Global.profile.phonePlay = true;
                  Global.saveProfile();
                  _showSnackBar(context);
                },),
                IconButton(icon: Icon(Icons.shuffle, size: 32), onPressed: () {
                  //pickUSBFolder(context);
                  if (Global.profile.phonePlay) context.read<IMlocal>().playLibrary(context);
                  else libmoc.mnetPlay(Global.profile.msourceID);
                },),
              ],
            ),
          ),
          if (meo.countTrack <= 0) ...[
            const Gap(60),
            Text('无媒体文件', textScaler: TextScaler.linear(1.8),),
            const Gap(20),
            Text('可通过以下三种方式导入媒体文件：\n 1. 将媒体文件拷贝至音源媒体库共享路径\n 2. 将U盘中的文件导入媒体库 \n 3. 添加本地曲目路径，同步至音源', style: TextStyle(fontWeight: FontWeight.w700)),
          ] else ...[
            const Gap(10),
            Expanded(
              child: LayoutBuilder(
                builder: (BuildContext context, BoxConstraints constrains) {
                  return Container(
                    // 艺术家列表
                    //padding: EdgeInsets.all(10),
                    height: constrains.maxHeight,
                    decoration: BoxDecoration(
                      //color: const Color.fromARGB(255, 21, 140, 236),
                      color: Colors.grey[100],
                      border: Border.all(color: Colors.grey[400]!),
                      borderRadius: BorderRadius.circular(10), // 可选：圆角边框
                    ),
                    child: GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 3,
                        crossAxisSpacing: 5,
                        mainAxisSpacing: 10,
                      ),
                      itemCount: meo.artists.length,
                      itemBuilder: (context, index) {
                        return ArtistTile(
                          name: meo.artists[index].name,
                          head: meo.artists[index].avt,
                          cachePercent: meo.artists[index].cachePercent,
                        );
                      }
                    )
                  );
                }
              )
            )
          ]
      ],
    ),
  );
  }
  }
}

class ArtistTile extends StatelessWidget {
  final String name;
  final String head;
  final double cachePercent;
  const ArtistTile({super.key, required this.name, required this.head, required this.cachePercent});

  @override
  Widget build(BuildContext context) {
    double bigd = cachePercent * 1000;
    int bigi = bigd.toInt();
    int num = bigi - bigi % 100;
    ImageProvider headimg = AssetImage('assets/image/artist_cover.jpg');
    try {
      File file = File(head);
      if (file.existsSync()) {
        headimg = FileImage(file);
      }
    } catch (e) {
      //
    }
    return InkWell(
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: headimg,
            radius: 35,
          ),
          const Gap(5),
          Stack(
            clipBehavior: Clip.none,
            children: [
              Container(
                width: 100,
                alignment: Alignment.center,
                child: Text(
                  overflow: TextOverflow.ellipsis, // 溢出时显示省略号
                  maxLines: 1, // 限制文本行数为1
                  name
                )
              ),
              cachePercent > 0.0 ?
                Positioned(left: 80, top: -18, 
                  child: cachePercent == 1.0 ?
                    Icon(Icons.download_done, color: Colors.green, size: 18)
                  :
                    Icon(Icons.download, color: Colors.green[num], size: 18)
                )
              : SizedBox.shrink()
            ]
          ),
        ],
      ),
      onTap: () {
        print('clicked ${name}');
        //context.push('/user');
        Navigator.push(context, MaterialPageRoute(
          builder: (context) => MusicArtistScreen(artist: name)
        ));
      },
    );
  }
}