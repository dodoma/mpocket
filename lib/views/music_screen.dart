import 'dart:async';
import 'dart:convert';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mpocket/ffi/libmoc.dart' as libmoc;
import 'package:mpocket/models/imsource.dart';
import 'package:mpocket/models/omusic.dart';
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
          if (Provider.of<IMsource>(context).deviceID.isEmpty)
            FutureBuilder<String>(
              //future: fetchData(), 
              future: sourceID,
              builder: (BuildContext context, AsyncSnapshot<String> value) {
                if (!value.hasData) {
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
                //连上的是个还没配网的音源
                if (value.data![0] == 'b') {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      context.go('/msource');
                    }
                  });
                  return Container();
                }
        
                //Provider.of<IMsource>(context).deviceID = value.data!;
                context.read<IMsource>().changeDevice(value.data!);

                // 开始展示干货
                return showMusicScreen(deviceID: value.data!, 
                  maxWidth: containerWidth,
                  maxHeight: containerHeight,
                );
                }
              }
            )
          else 
            showMusicScreen(deviceID: Provider.of<IMsource>(context).deviceID, 
              maxWidth: containerWidth,
              maxHeight: containerHeight
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

  @override
  void initState() {
    super.initState();
    _fetchData(); // 调用异步方法
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

  Future<void> _fetchData() async {
    await Future.delayed(Duration(seconds: 2));  
    if (mounted) {
      setState(() {
        meo = Omusic.fromJson(jsonDecode(dummys));
        _isLoading = false;
      });
    }
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

  @override
  Widget build(BuildContext context) {
  if (_isLoading) {
      return CircularProgressIndicator();
  } else {
  return Container(
    // 页面一大框
    width: widget.maxWidth,
    margin: EdgeInsets.only(top:30, bottom: 30),
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
                        CircleAvatar(
                          radius: 5,
                          backgroundColor: const Color.fromARGB(255, 87, 241, 32),
                        ),
                        const Gap(3),                        Text('默认媒体库'),
                        Icon(Icons.arrow_drop_down)
                      ],
                    ),
                    const Gap(2),
                    Text('0首歌曲, 0首歌曲, 0首歌曲, 112130首歌曲', textScaler: TextScaler.linear(0.6))
                  ],
                ),
                Spacer(),
                IconButton(icon: Icon(Icons.phone_iphone, size: 32), onPressed: () {
                  libmoc.mnetStoreSync(Provider.of<IMsource>(context, listen: false).deviceID, "默认媒体库");
                },),
                IconButton(icon: Icon(Icons.shuffle_on_rounded, size: 32), onPressed: () {
                  libmoc.mnetPlay(Provider.of<IMsource>(context, listen: false).deviceID);
                },),
              ],
            ),
          ),
          if (meo.countTrack <= 0) ...[
            Spacer(),
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
                    padding: EdgeInsets.all(10),
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
                        mainAxisSpacing: 20,
                      ),
                      itemCount: meo.artists.length,
                      itemBuilder: (context, index) {
                        return ArtistTile(
                          name: meo.artists[index].name,
                          head: meo.artists[index].avt,
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
  const ArtistTile({super.key, required this.name, required this.head});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Column(
        children: [
          CircleAvatar(
            backgroundImage: AssetImage(head),
            radius: 35,
          ),
          const Gap(5),
          Container(
            width: 100,
            alignment: Alignment.center,
            child: Text(
              overflow: TextOverflow.ellipsis, // 溢出时显示省略号
              maxLines: 1, // 限制文本行数为1
              name
            )
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