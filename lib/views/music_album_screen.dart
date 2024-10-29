import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mpocket/common/global.dart';
import 'package:mpocket/ffi/libmoc.dart' as libmoc;
import 'package:mpocket/models/omusic_album.dart';

class MusicAlbumScreen extends StatefulWidget {
  final String artist;
  final String album;

  const MusicAlbumScreen({super.key, required this.artist, required this.album});

  @override
  State<MusicAlbumScreen> createState() => _MusicAlbumScreenState();
}

class _MusicAlbumScreenState extends State<MusicAlbumScreen> {
  bool _isLoading = true;
  late OmusicAlbum meo;

  Future<void> _fetchData() async {
    //await Future.delayed(Duration(seconds: 1));  
    String emos = libmoc.omusicAlbum(Global.profile.msourceID, widget.artist, widget.album);
    print(emos);
    setState(() {
      meo = OmusicAlbum.fromJson(jsonDecode(emos));
      _isLoading = false;
    });
  }

  String dummys = '''
{
    "title": "一切都是因为谎言",
    "artist": "Santana",
    "PD": "2017-12-21",
    "cover": "assets/image/caiQ.jfif",
    "countTrack": 11,
    "tracks": [
        {"id": "8193c2922f", "title": "Premonition", "duration": "03:52"},
        {"id": "8193c2922f", "title": "Dream Song", "duration": "05:33"},
        {"id": "8193c2922f", "title": "Pyrrhic Victoria", "duration": "02:19"},
        {"id": "8193c2922f", "title": "Light Years Away", "duration": "03:30"},
        {"id": "8193c2922f", "title": "Solitude", "duration": "03:52"},
        {"id": "8193c2922f", "title": "Littleworth Lane", "duration": "03:52"},
        {"id": "8193c2922f", "title": "Dream Song", "duration": "05:33"},
        {"id": "8193c2922f", "title": "Pyrrhic Victoria", "duration": "02:19"},
        {"id": "8193c2922f", "title": "Light Years Away", "duration": "03:30"},
        {"id": "8193c2922f", "title": "Solitude", "duration": "03:52"},
        {"id": "8193c2922f", "title": "Littleworth Lane", "duration": "03:52"}
    ]    
}''';

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

    if (_isLoading) return Scaffold(body: Center(child: CircularProgressIndicator()));
    else {
    return Scaffold(
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
                      File(meo.cover),
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
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              libmoc.mnetSetShuffle(Global.profile.msourceID, 0);
                              libmoc.mnetPlayAlbum(Global.profile.msourceID, widget.artist, widget.album);
                            },
                            icon: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.7), // 灰色背景，带透明度
                                shape: BoxShape.circle, // 圆形背景
                              ),                            
                              child: Icon(Icons.play_arrow, size: 32, color: Colors.white,)
                            )
                          ),
                          IconButton(
                            onPressed: () {
                              libmoc.mnetSetShuffle(Global.profile.msourceID, 1);
                              libmoc.mnetPlayAlbum(Global.profile.msourceID, widget.artist, widget.album);
                            },
                            icon: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey.withOpacity(0.7), // 灰色背景，带透明度
                                shape: BoxShape.circle, // 圆形背景
                              ),                            
                              child: Icon(Icons.shuffle, size: 32, color: Colors.white,)
                            )
                          ),
                        ],
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
                          SizedBox(child: Text('${widget.album}', textScaler: TextScaler.linear(1.6), overflow: TextOverflow.ellipsis, maxLines: 1,), width: containerWidth * 0.9),
                          Row(
                            children: [
                              Text('${widget.artist}'),
                              const Gap(50),
                              Text('${meo.PD}'),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Container(
                  width: containerWidth,
                  child: Divider(color: Colors.grey, thickness: 2.0,),
                ),
                //const Gap(5),
                Expanded(
                  child: LayoutBuilder(
                    builder: (BuildContext context, BoxConstraints constrains) {
                      return Container(
                        width: containerWidth * 0.9,
                        height: constrains.maxHeight,  
                        child: ListView.builder(
                          itemCount: meo.tracks.length,
                          itemBuilder: (context, index) {
                            return AlbumTile(
                              artist: widget.artist,
                              album: widget.album,
                              cover: meo.cover,
                              sn: index + 1,
                              id: meo.tracks[index].id,
                              title: meo.tracks[index].title,
                              duration: meo.tracks[index].duration
                            );  
                          },
                        )
                      );
                    }
                  )
                )           
              ],
            ),
          ],
        )
      )
    );
  }
  }
}

class AlbumTile extends StatelessWidget {
  final String artist;
  final String album;
  final String cover;
  final num sn;
  final String id;
  final String title;
  final String duration;

  const AlbumTile({super.key, required this.artist, required this.album, required this.cover, required this.sn, required this.id, required this.title, required this.duration});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,  
        children: [
          Container(
            alignment: Alignment.centerRight,  
            width: 40,
            child: Text(sn.toString(), style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),)
          ),
          const Gap(20),
          Expanded(
            child: Column(
              children: [
                Row(
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(child: Text(title, textScaler: TextScaler.linear(1.2), overflow: TextOverflow.ellipsis, maxLines: 1,), width: 160),
                        Text(duration)
                      ],
                    ),
                    Spacer(),
                    IconButton(onPressed: (){}, icon: Icon(Icons.add)),
                    IconButton(onPressed: (){}, icon: Icon(Icons.more_vert)),
                  ],
                ),
                Divider(color: Colors.grey, thickness: 1.0,),
                const Gap(8),
              ],
            ),
          )
        ],
      ),
      onTap: () {
        //context.read<IMsource>().updateListenTrack(OmusicTrack('aabbccddee', title, cover, artist, 120, 0));
        //context.read<IMsource>().turnOnPlaying();
        libmoc.mnetPlayID(Global.profile.msourceID, id);
      },
    );
  }
}