import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mpocket/ffi/libmoc.dart' as libmoc;
import 'package:mpocket/models/imsource.dart';
import 'package:provider/provider.dart';

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

  late Future<String> sourceID = libmoc.mocDiscovery();

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width * 0.9;

    return Scaffold(
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
          if (Provider.of<IMsource>(context).deviceID.isEmpty)
            FutureBuilder<String>(
              future: fetchData(), 
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
                if (value.data![0] == 'a') {
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    if (context.mounted) {
                      context.go('/msource');
                    }
                  });
                  return Container();
                }
        
                Provider.of<IMsource>(context).deviceID = value.data!;
        
                // 开始展示干货
                return showMusicScreen(deviceID: value.data!, maxWidth: containerWidth);
                }
              }
            )
          else 
            showMusicScreen(deviceID: Provider.of<IMsource>(context).deviceID, maxWidth: containerWidth)
          ],
        ),
      )
    );
  }
}

class showMusicScreen extends StatefulWidget {
  final String deviceID;
  final double maxWidth;

  const showMusicScreen({super.key, required this.deviceID, required this.maxWidth});

  @override
  State<showMusicScreen> createState() => _showMusicScreenState();
}

class _showMusicScreenState extends State<showMusicScreen> {
  
  @override
  Widget build(BuildContext context) {
  return Container(
    // 页面一大框
    width: widget.maxWidth,
    margin: EdgeInsets.only(top:50, bottom: 80),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
          Container(
            // 第一坨
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
                Icon(Icons.phone_iphone, size: 32),
                Icon(Icons.shuffle_on_rounded, size: 32),
              ],
            ),
          ),
          Spacer(),
          Text('无媒体文件', textScaler: TextScaler.linear(1.8),),
          const Gap(20),
          Text('可通过以下三种方式导入媒体文件：\n 1. 将媒体文件拷贝至音源媒体库共享路径\n 2. 将U盘中的文件导入媒体库 \n 3. 添加本地曲目路径，同步至音源', style: TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
  }
}
