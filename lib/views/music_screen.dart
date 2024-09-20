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
        child: Container(
          width: containerWidth,
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
                  return showMusicScreen(value.data!, containerWidth);
                  }
                }
              )
            else 
              showMusicScreen(Provider.of<IMsource>(context).deviceID, containerWidth)
            ],
          ),
        ),
      )
    );
  }
}

Widget showMusicScreen(String deviceID, double maxWidth) {
  return Container(
    margin: EdgeInsets.only(top:50, bottom: 30),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
          Container(
            //color: const Color.fromARGB(255, 212, 215, 218),
            width: maxWidth,
            padding: EdgeInsets.all(10),
            child: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.ac_unit, size: 12,),
                        Text('默认媒体库'),
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