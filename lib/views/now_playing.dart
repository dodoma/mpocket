import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mpocket/models/imsource.dart';
import 'package:mpocket/models/omusic_playing.dart';
import 'package:mpocket/views/music_album_screen.dart';
import 'package:mpocket/views/music_artist_screen.dart';
import 'package:provider/provider.dart';

class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {

  bool _isLoading = true;
  late OmusicPlaying meo;

  Future<void> _fetchData() async {
    setState(() {
      meo = OmusicPlaying.fromJson(jsonDecode(dummys));
      _isLoading = false;
    });
  }

  String dummys = '''
{
    "title": "Proemonition",
    "cover": "assets/image/erhu.jfif",
    "artist": "Santana",
    "album": "一切都是因为谎言",
    "file_type": "MP3",
    "bps": "32kb/s",
    "rate": "44.1khz",
    "duration": "3:53",
    "now_at": "1:32",
    "volume": 0.76,
    "progress": 0.34
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
                        height: 300, 
                        fit: BoxFit.cover,
                      ),
                      Positioned(left: 10, top: 20, child: IconButton(onPressed:() {
                        context.read<IMsource>().turnOnPlaying();
                        Navigator.pop(context);
                      }, icon: Icon(Icons.arrow_back)),),
                    ],
                  ),
                  const Gap(10),
                  Container(
                    width: containerWidth * 0.9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,  
                      children: [
                        Text(meo.title, textScaler: TextScaler.linear(1.6),),  
                        Row(
                          children: [
                            GestureDetector(
                              child: Text(meo.artist, style: TextStyle(color: Colors.green),),
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => MusicArtistScreen(artist: meo.artist)
                                ));
                              },
                            ),
                            Text('   ·   '),
                            GestureDetector(
                              child: Text(meo.album, style: TextStyle(color: Colors.green),),
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => MusicAlbumScreen(artist: meo.artist, album: meo.album,)
                                ));
                              },
                            ),
                          ],
                        ),
                        const Gap(5),
                        Text('${meo.file_type}  ·  ${meo.bps}  ·  ${meo.rate}'),
                      ],
                    ),
                  ),
                  const Gap(10),
                  Container(
                    width: containerWidth * 0.9,
                    child: Column(
                      children: [
                        //LinearProgressIndicator(value: 0.3, minHeight: 5,),
                        Slider(
                          value: meo.progress,
                          min: 0.0,
                          max: 1.0,
                          divisions: 10,
                          onChanged: (value) {
                            setState(() {
                              meo.progress = value;
                            });
                          }
                        ),
                        const Gap(5),
                        Row(
                          children: [
                            Text(meo.now_at),
                            Spacer(),
                            Text(meo.duration)
                          ],
                        ),
                        const Gap(30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 图标之间均匀分布
                          children: [
                            Icon(Icons.list, size: 32),
                            Icon(Icons.skip_previous, size: 32),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(10),                            
                              child: Icon(Icons.pause, size: 32, color: Colors.white,)
                            ),
                            Icon(Icons.skip_next, size: 32),
                            Icon(Icons.shuffle, size: 32),
                        ],),
                        const Gap(20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 图标之间均匀分布
                          children: [
                            Icon(Icons.volume_down),
                            Container(
                              width: 160,  
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 1.0, // 设置滑道的高度
                                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4.0), // 设置滑块的大小
                                  trackShape: RoundedRectSliderTrackShape(), // 设置滑道的形状
                                ),
                                child: Slider(
                                  value: meo.volume, 
                                  min: 0.0,
                                  max: 1.0,
                                  divisions: 20, 
                                  onChanged: (value) {
                                    print('xxxx ${value}');
                                    setState(() {
                                      meo.volume = value;
                                    });
                                  },
                                ),
                              ),
                            ),
                            Icon(Icons.volume_up),
                          ]
                        )
                      ],
                    ),
                  ),
                ],
              )
            ],
          ),
        ),  
      );
    }
  }
}