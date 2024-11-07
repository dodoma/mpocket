import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mpocket/common/global.dart';
import 'package:mpocket/ffi/libmoc.dart' as libmoc;
import 'package:mpocket/models/omusic_artist.dart';
import 'package:mpocket/views/music_album_screen.dart';


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
    //await Future.delayed(Duration(seconds: 1));  
    String emos = libmoc.omusicArtist(Global.profile.msourceID, widget.artist);
    setState(() {
      meo = OmusicArtist.fromJson(jsonDecode(emos));
      _isLoading = false;
    });
  }

  String dummys = '''
{
    "artist": "Santana",
    "countAlbum": 3,
    "countTrack": 46,
    "avt": "assets/image/erhu.jfif",
    "albums": [
        {"name": "哈哈大笑", "cover": "assets/image/caiQ.jfif", "countTrack": 12, "PD": "2022-12-21", "cached": false},
        {"name": "一切都是因为谎言", "countTrack": 12, "PD": "2012-12-21", "cached": false, "cover": "assets/image/linkP.jfif"},
        {"name": "OPEN MUSIC", "countTrack": 12, "PD": "2017-12-21", "cached": true, "cover": "assets/image/deepF.jfif"}
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
  double containerWidth = MediaQuery.of(context).size.width;

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
            Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  children: [
                    Image.file(
                      File(meo.avt),
                      width: MediaQuery.of(context).size.width,
                      height: 220,
                      fit: BoxFit.cover,
                    ),
                    Positioned(
                      left: 10,  
                      top: 40,
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(Icons.arrow_back, size: 32, color: Colors.white,)
                      )
                    ),
                    Positioned(
                      right: 10,  
                      bottom: 10,
                      child: IconButton(
                        onPressed: () {
                          libmoc.mnetPlayArtist(Global.profile.msourceID, meo.artist);
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
                Container(
                  width: containerWidth * 0.9,
                  child: Row(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('${widget.artist}', textScaler: TextScaler.linear(1.6),),
                          Text('${meo.countAlbum} 张专辑 ${meo.countTrack} 首歌曲'),
                        ],
                      ),
                      Spacer(),
                      IconButton(icon: Icon(Icons.sync), onPressed: () {},),
                      IconButton(icon: Icon(Icons.delete_outline), onPressed: () {},),
                      IconButton(icon: Icon(Icons.delete_forever), onPressed: () {},)
                    ],
                  ),
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
                        width: containerWidth,
                        height: constrains.maxHeight,
                        child: ListView.builder(
                          itemCount: meo.albums.length,
                          itemBuilder: (context, index) {
                            return ListTile(
                              leading: Image.file(File(meo.albums[index].cover), height: 60),
                              title: SizedBox(child:
                                Text(meo.albums[index].name, overflow: TextOverflow.ellipsis, maxLines: 1,),
                              ),
                              subtitle: Text('${meo.albums[index].PD} ${meo.albums[index].countTrack} 首'),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (meo.albums[index].cached) Text('已缓存'),
                                  IconButton(
                                    onPressed: () {
                                      libmoc.mnetPlayAlbum(Global.profile.msourceID, meo.artist, meo.albums[index].name);
                                    },
                                    icon: Icon(size: 20, Icons.play_arrow)),
                                  IconButton(onPressed: () {
                                    showModalBottomSheet(
                                      context: context, 
                                      builder: (BuildContext context) {
                                        return Padding(
                                          padding: const EdgeInsets.all(20),
                                          child: Column(
                                            //mainAxisAlignment: MainAxisAlignment.center,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Container(
                                                width: containerWidth * 0.8,
                                                child: Text(meo.albums[index].name, style: TextStyle(fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis, maxLines: 1,)
                                              ),
                                              const Gap(20),
                                              Row(children: [
                                                IconButton(icon: Icon(Icons.sync, size: 20,), onPressed: () {
                                                  libmoc.omusicSyncAlbum(Global.profile.msourceID, meo.artist, meo.albums[index].name);
                                                  Navigator.pop(context);
                                                },),
                                                const Gap(20),
                                                Text('缓存至本地')
                                              ],),
                                              Divider(color: Colors.grey,),

                                              const Gap(10),
                                              Row(children: [
                                                IconButton(icon: Icon(Icons.delete_outline, size: 20,), onPressed: () {},),
                                                const Gap(20),
                                                Text('清除本地缓存')
                                              ],),
                                              Divider(color: Colors.grey,),

                                              const Gap(10),
                                              Row(children: [
                                                IconButton(icon: Icon(Icons.delete_forever, size: 20,), onPressed: () {},),
                                                const Gap(20),
                                                Text('删除本地与音源')
                                              ],),
                                              Divider(color: Colors.grey,),
                                            ],
                                          )
                                        );
                                      }
                                    );
                                  }, icon: Icon(size: 20, Icons.more_vert)),
                                ],
                              ),
                              onTap: () {
                                print('zzzz');
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => MusicAlbumScreen(artist: widget.artist, album: meo.albums[index].name)
                                ));
                              },
                            );
                          }
                        )
                      );
                    }
                  )
                )
              ],
            ),
          ],
        )
      ),
    );
  }
  }
}