import 'dart:async';
import 'dart:io';

import 'package:audio_metadata_extractor/audio_metadata_extractor.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mpocket/models/imlocal.dart';
import 'package:mpocket/models/imsource.dart';
import 'package:mpocket/views/music_album_screen.dart';
import 'package:mpocket/views/music_artist_screen.dart';
import 'package:provider/provider.dart';

class LocalPlayingScreen extends StatefulWidget {
  const LocalPlayingScreen({super.key});

  @override
  State<LocalPlayingScreen> createState() => _LocalPlayingScreenState();
}

class _LocalPlayingScreenState extends State<LocalPlayingScreen> {
  final progress = StreamController<double>();
  bool paused = false;
  bool _dragging = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    progress.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width;
    String? url = context.watch<IMlocal>().onListenURL;
    String? cover = context.read<IMlocal>().onListenCover;
    AudioMetadata? mdata = context.read<IMlocal>().onListenTrack;
    Duration duration = context.watch<IMlocal>().duration;
    Duration position = context.watch<IMlocal>().position;
    double volume = context.read<IMlocal>().volume;
    String trackName = (mdata == null || mdata.trackName == null) ? '未知曲目': mdata.trackName!;
    String artistName = mdata == null ? '未知艺术家' : mdata.firstArtists != null ? mdata.firstArtists! : mdata.secondArtists != null ? mdata.secondArtists! : '未知艺术家';
    //String artistName = (mdata == null || mdata.firstArtists == null) ? '未知艺术家' : mdata.firstArtists!;
    String albumName = (mdata == null || mdata.album == null) ? '未知专辑' : mdata.album!;

    double fval = duration.inMilliseconds > 0 ? position.inMilliseconds / duration.inMilliseconds : 0.0;
    if (!_dragging && fval >= 0.0 && fval <= 1.0) progress.add(fval);

    if (url == null) return Scaffold(body: Center(child: CircularProgressIndicator()));
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
                        File(cover!),
                        width: MediaQuery.of(context).size.width,
                        height: 300, 
                        fit: BoxFit.cover,
                      ),
                      Positioned(left: 10, top: 40, child: IconButton(onPressed:() {
                        Navigator.pop(context);
                        context.read<IMbanner>().turnOnBanner();
                      }, icon: Icon(Icons.close, color: Colors.white,)),),
                    ],
                  ),
                  const Gap(10),
                  Container(
                    width: containerWidth * 0.9,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,  
                      children: [
                        Text(trackName, textScaler: TextScaler.linear(1.6), overflow: TextOverflow.ellipsis, maxLines: 3,),  
                        Row(
                          children: [
                            GestureDetector(
                              child: Text(artistName, style: TextStyle(color: Colors.green)),
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => MusicArtistScreen(artist: artistName)
                                ));
                              },
                            ),
                            Text('   ·   '),
                            GestureDetector(
                              child: SizedBox(child: Text(albumName, style: TextStyle(color: Colors.green), overflow: TextOverflow.ellipsis, maxLines: 1,), width: 180,),
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => MusicAlbumScreen(artist: artistName, album: albumName,)
                                ));
                              },
                            ),
                          ],
                        ),
                        //const Gap(5),
                        //Text('MP3  ·  ${meo.bps}  ·  ${meo.rate}'),
                      ],
                    ),
                  ),
                  const Gap(10),
                  Container(
                    width: containerWidth * 0.9,
                    child: Column(
                      children: [
                        //LinearProgressIndicator(value: progress, minHeight: 5,),
                        StreamBuilder<double>(
                          stream: progress.stream,
                          builder: (context, snapshot) {
                            double sliderValue = snapshot.data ?? 0.0;
                            return Column(
                              children: [
                                Slider(
                                  value: sliderValue,
                                  min: 0.0,
                                  max: 1.0,
                                  divisions: 100,
                                  onChanged: (value){
                                    _dragging = true;
                                    print("drag to ${value}");
                                    progress.add(value);
                                  },
                                  onChangeEnd: (value) {
                                    _dragging = false;
                                    print("draged to ${value}");
                                    progress.add(value);
                                    context.read<IMlocal>().dragTo(value);
                                  }
                                ),
                                const Gap(5),
                                Row(
                                  children: [
                                    //Text("${((position.inSeconds * sliderValue).toInt() ~/ 60).toString().padLeft(2, '0')}:${((position.inSeconds * sliderValue).toInt() % 60).toString().padLeft(2, '0')}"),
                                    Text("${(position.inSeconds ~/ 60).toString().padLeft(2, '0')}:${(position.inSeconds % 60).toString().padLeft(2, '0')}"),
                                    Spacer(),
                                    Text("${(duration.inSeconds ~/ 60).toString().padLeft(2, '0')}:${(duration.inSeconds % 60).toString().padLeft(2, '0')}"),
                                  ],
                                ),
                              ],
                            );
                          }
                        ),
                        const Gap(30),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 图标之间均匀分布
                          children: [
                            Icon(Icons.list, size: 32),
                            IconButton(icon: Icon(Icons.skip_previous, size: 32), onPressed: () {
                              context.read<IMlocal>().playPrevious(context);
                            },),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(10),                            
                              child: paused ?
                                IconButton(icon: Icon(Icons.play_arrow, size: 32, color: Colors.white,), onPressed: () {
                                  context.read<IMlocal>().resume();
                                  setState(() {
                                    paused = false;
                                  });
                                },)
                               :
                                IconButton(icon: Icon(Icons.pause, size: 32, color: Colors.white,), onPressed: () {
                                  context.read<IMlocal>().pause();
                                  setState(() {
                                    paused = true;
                                  });
                                },)
                            ),
                            IconButton(icon: Icon(Icons.skip_next, size: 32), onPressed: (){
                              context.read<IMlocal>().playNext(context);
                            },),
                            context.read<IMlocal>().shuffle ?
                              IconButton(icon: Icon(Icons.shuffle_on_outlined, size: 32), onPressed: () {
                                context.read<IMlocal>().shuffle = false;
                              },)
                            :
                              IconButton(icon: Icon(Icons.shuffle, size: 32), onPressed: () {
                                context.read<IMlocal>().shuffle = true;
                              },),
                        ],),
                        const Gap(20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 图标之间均匀分布
                          children: [
                            IconButton(icon: Icon(Icons.volume_down), onPressed: () {
                                if (volume > 0.1) {
                                    volume -= 0.05;
                                    context.read<IMlocal>().setVolume(volume);
                                }
                            },),
                            Container(
                              width: 160,  
                              child: SliderTheme(
                                data: SliderTheme.of(context).copyWith(
                                  trackHeight: 1.0, // 设置滑道的高度
                                  thumbShape: RoundSliderThumbShape(enabledThumbRadius: 4.0), // 设置滑块的大小
                                  trackShape: RoundedRectSliderTrackShape(), // 设置滑道的形状
                                ),
                                child: Slider(
                                  value: volume, 
                                  min: 0.0,
                                  max: 1.0,
                                  divisions: 20, 
                                  onChanged: (value){},
                                  onChangeEnd: (value) {
                                      volume = value;
                                      context.read<IMlocal>().setVolume(volume);
                                  },
                                ),
                              ),
                            ),
                            IconButton(icon: Icon(Icons.volume_up), onPressed: () {
                                if (volume < 0.95) {
                                    volume += 0.05;
                                    context.read<IMlocal>().setVolume(volume);
                                }
                            },),
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