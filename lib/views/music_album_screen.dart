import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mpocket/models/imsource.dart';
import 'package:mpocket/models/omusic_album.dart';
import 'package:provider/provider.dart';

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
    await Future.delayed(Duration(seconds: 1));  
    setState(() {
      meo = OmusicAlbum.fromJson(jsonDecode(dummys));
      _isLoading = false;
    });
  }

  String dummys = '''
{
    "name": "一切都是因为谎言",
    "artist": "Santana",
    "PD": "2017-12-21",
    "cover": "assets/image/caiQ.jfif",
    "countTrack": 11,
    "tracks": [
        {"name": "Premonition", "duration": "03:52"},
        {"name": "Dream Song", "duration": "05:33"},
        {"name": "Pyrrhic Victoria", "duration": "02:19"},
        {"name": "Light Years Away", "duration": "03:30"},
        {"name": "Solitude", "duration": "03:52"},
        {"name": "Littleworth Lane", "duration": "03:52"},
        {"name": "Dream Song", "duration": "05:33"},
        {"name": "Pyrrhic Victoria", "duration": "02:19"},
        {"name": "Light Years Away", "duration": "03:30"},
        {"name": "Solitude", "duration": "03:52"},
        {"name": "Littleworth Lane", "duration": "03:52"}
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
                    Image.asset(
                      meo.cover,
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
                          print('play whole');
                        },
                        icon: Container(
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.7), // 灰色背景，带透明度
                            shape: BoxShape.circle, // 圆形背景
                          ),                            
                          child: Icon(Icons.play_arrow, size: 32, color: Colors.white,)
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
                          Text('${widget.album}', textScaler: TextScaler.linear(1.6),),
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
                              title: meo.tracks[index].name,
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
  final String title;
  final String duration;

  const AlbumTile({super.key, required this.artist, required this.album, required this.cover, required this.sn, required this.title, required this.duration});

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
                        Text(title, textScaler: TextScaler.linear(1.2),),
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
        context.read<IMsource>().updateListenTrack(OmusicTrack(title, cover, artist));
        context.read<IMsource>().turnOnPlaying();
      },
    );
  }
}