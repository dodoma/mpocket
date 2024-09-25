import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mpocket/models/omusic_artist.dart';

class MusicArtistScreen extends StatefulWidget {

  final String artist;
  const MusicArtistScreen({super.key, required this.artist});

  @override
  State<MusicArtistScreen> createState() => _MusicArtistScreenState();
}

class _MusicArtistScreenState extends State<MusicArtistScreen> {
  bool _isLoading = true;
  late OmusicArtist meo;

  Future<void> _fetchData() async {
    await Future.delayed(Duration(seconds: 1));  
    setState(() {
      meo = OmusicArtist.fromJson(jsonDecode(dummys));
      _isLoading = false;
    });
  }

  String dummys = '''{
    "artist": "Santana",
    "countAlbum": 3,
    "countTrack": 46,
    "avt": "http://m.mbox.net.cn/d/lm/album/cover?artist=%E4%BA%8C%E6%B3%89%E6%98%A0%E6%9C%88&album=%E4%BA%8C%E8%83%A1%E5%90%8D%E6%9B%B2%E5%85%B8%E8%94%B5CD2&_reqtype=image",
    "albums": [
        {"name": "哈哈大笑", "cover": "http://m.mbox.net.cn/d/lm/album/cover?artist=Deep%20Forest&album=Comparsa&_reqtype=image", "countTrack": 12, "PD": "2022-12-21", "cached": false},
        {"name": "一切都是因为谎言", "countTrack": 12, "PD": "2012-12-21", "cached": false, "cover": "http://m.mbox.net.cn/d/lm/album/cover?artist=Linkin%20Park&album=Meteora%20(LP%20Version)&_reqtype=image"},
        {"name": "OPEN MUSIC", "countTrack": 12, "PD": "2017-12-21", "cached": true, "cover": "http://m.mbox.net.cn/d/lm/album/cover?artist=%E5%91%A8%E6%9D%B0%E4%BC%A6&album=%E8%8C%83%E7%89%B9%E8%A5%BF&_reqtype=image"}
    ]
}
''';

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
  double containerWidth = MediaQuery.of(context).size.width * 0.9;

  if (_isLoading) {
    return Scaffold(body: Center(child: CircularProgressIndicator()));
  } else {
    return Scaffold(
      //appBar: AppBar(
      //  title: Text(widget.artist),
      //),  
      body: Center(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: containerWidth,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      Image.network(
                        meo.avt,
                        width: MediaQuery.of(context).size.width,
                        height: 220,
                        fit: BoxFit.cover,
                      ),
                      Positioned(
                        left: 10,  
                        top: 20,
                        child: IconButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          icon: Icon(Icons.arrow_back, size: 32)
                        )
                      ),
                      Positioned(
                        right: 10,  
                        bottom: 10,
                        child: IconButton(
                          onPressed: () {
                            print('play shuffle');
                          },
                          icon: Container(
                            decoration: BoxDecoration(
                              color: Colors.grey.withOpacity(0.7), // 灰色背景，带透明度
                              shape: BoxShape.circle, // 圆形背景
                            ),                            
                            child: Icon(Icons.shuffle, size: 32, color: Colors.white,)
                          )
                        )
                      )
                    ]
                  ),
                  const Gap(10),
                  Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${widget.artist}', textScaler: TextScaler.linear(1.6),),
                          Text('${meo.countAlbum} 张专辑 ${meo.countTrack} 首歌曲'),
                        ],
                      ),
                      Spacer(),
                      Icon(Icons.delete)
                    ],
                  ),
                  const Gap(5),
                  Divider(
                    color: Colors.grey,
                    thickness: 2.0,
                  ),
                  const Gap(5),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (BuildContext context, BoxConstraints constrains) {
                        return Container(
                          //padding: EdgeInsets.all(10),
                          height: constrains.maxHeight,
                          child: ListView.builder(
                            itemCount: meo.albums.length,
                            itemBuilder: (context, index) {
                              return ListTile(
                                leading: Image.network(meo.albums[index].cover, height: 60),
                                title: Text(meo.albums[index].name),
                                subtitle: Text('${meo.albums[index].PD} ${meo.albums[index].countTrack} 首'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (meo.albums[index].cached) Text('已缓存'),
                                    IconButton(onPressed: () {print('xxxx');}, icon: Icon(size: 20, Icons.play_arrow)),
                                    IconButton(onPressed: () {print('yyyy');}, icon: Icon(size: 20, Icons.more_vert)),
                                  ],
                                )
                              );
                            }
                          )
                        );
                      }
                    )
                  )
                ],
              ),
            ),
          ],
        )
      ),
    );
  }
  }
}