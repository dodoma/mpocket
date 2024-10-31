import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mpocket/common/global.dart';
import 'package:mpocket/ffi/libmoc.dart' as libmoc;
import 'package:mpocket/models/imsource.dart';
import 'package:mpocket/models/omusic_playing.dart';
import 'package:mpocket/views/music_album_screen.dart';
import 'package:mpocket/views/music_artist_screen.dart';
import 'package:provider/provider.dart';

typedef NativePlayStepCallback = Void Function(Pointer<Utf8>, Int, Pointer<Utf8>, Pointer<Utf8>);


class NowPlayingScreen extends StatefulWidget {
  const NowPlayingScreen({super.key});

  @override
  State<NowPlayingScreen> createState() => _NowPlayingScreenState();
}

class _NowPlayingScreenState extends State<NowPlayingScreen> {
  final progress = StreamController<double>();
  late final NativeCallable<NativePlayStepCallback> callback = NativeCallable<NativePlayStepCallback>.listener(onResponse);
  bool paused = false;

  void onResponse(Pointer<Utf8> client, int ok, Pointer<Utf8> errmsgPtr, Pointer<Utf8> responsePtr) {
    print('on play STEP l');
    OmusicPlaying? onListenTrack = context.read<IMsource>().onListenTrack;
    if (onListenTrack != null) {
      onListenTrack.pos += 2;
      double percent = onListenTrack.pos / onListenTrack.length;
      if (percent > 1.0) percent = 1.0;
      progress.add(percent);
    }
  }

  @override
  void initState() {
    super.initState();
    libmoc.mnetOnStep(Global.profile.msourceID, callback.nativeFunction);
  }

  @override
  void dispose() {
    progress.close();
    callback.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width;
    OmusicPlaying? meo = context.read<IMsource>().onListenTrack;

    if (meo == null) return Scaffold(body: Center(child: CircularProgressIndicator()));
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
                        File(meo.cover!),
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
                        Text(meo.title, textScaler: TextScaler.linear(1.6), overflow: TextOverflow.ellipsis, maxLines: 3,),  
                        Row(
                          children: [
                            GestureDetector(
                              child: Text(meo.artist, style: TextStyle(color: Colors.green)),
                              onTap: (){
                                Navigator.push(context, MaterialPageRoute(
                                  builder: (context) => MusicArtistScreen(artist: meo.artist)
                                ));
                              },
                            ),
                            Text('   ·   '),
                            GestureDetector(
                              child: SizedBox(child: Text(meo.album, style: TextStyle(color: Colors.green), overflow: TextOverflow.ellipsis, maxLines: 1,), width: 180,),
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
                                    print("drag to ${value}");
                                    progress.add(value);
                                  },
                                  onChangeEnd: (value) {
                                    print("draged to ${value}");
                                    progress.add(value);
                                    libmoc.mnetDragTO(Global.profile.msourceID, value);
                                  }
                                ),
                                const Gap(5),
                                Row(
                                  children: [
                                    Text("${((meo.length * sliderValue).toInt() ~/ 60).toString().padLeft(2, '0')}:${((meo.length * sliderValue).toInt() % 60).toString().padLeft(2, '0')}"),
                                    Spacer(),
                                    Text("${(meo.length ~/ 60).toString().padLeft(2, '0')}:${(meo.length % 60).toString().padLeft(2, '0')}"),
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
                              libmoc.mnetPrevious(Global.profile.msourceID);
                            },),
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.purple.withOpacity(0.7),
                                shape: BoxShape.circle,
                              ),
                              padding: EdgeInsets.all(10),                            
                              child: paused ?
                                IconButton(icon: Icon(Icons.play_arrow, size: 32, color: Colors.white,), onPressed: () {
                                  libmoc.mnetResume(Global.profile.msourceID);
                                  setState(() {
                                    paused = false;
                                  });
                                },)
                               :
                                IconButton(icon: Icon(Icons.pause, size: 32, color: Colors.white,), onPressed: () {
                                  libmoc.mnetPause(Global.profile.msourceID);                                
                                  setState(() {
                                    paused = true;
                                  });
                                },)
                            ),
                            IconButton(icon: Icon(Icons.skip_next, size: 32), onPressed: (){
                              libmoc.mnetNext(Global.profile.msourceID);
                            },),
                            meo.shuffle ?
                              IconButton(icon: Icon(Icons.shuffle_on_outlined, size: 32), onPressed: () {
                                libmoc.mnetSetShuffle(Global.profile.msourceID, 0);
                                setState(() {
                                  meo.shuffle = false;
                                });
                              },)
                            :
                              IconButton(icon: Icon(Icons.shuffle, size: 32), onPressed: () {
                                libmoc.mnetSetShuffle(Global.profile.msourceID, 1);
                                setState(() {
                                  meo.shuffle = true;
                                });
                              },),
                        ],),
                        const Gap(20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly, // 图标之间均匀分布
                          children: [
                            IconButton(icon: Icon(Icons.volume_down), onPressed: () {
                                if (meo.volume > 0.1) {
                                  setState(() {
                                    meo.volume -= 0.05;
                                  });
                                  libmoc.mnetSetVolume(Global.profile.msourceID, meo.volume);
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
                                  value: meo.volume, 
                                  min: 0.0,
                                  max: 1.0,
                                  divisions: 20, 
                                  onChanged: (value){},
                                  onChangeEnd: (value) {
                                    setState(() {
                                      meo.volume = value;
                                    });
                                    libmoc.mnetSetVolume(Global.profile.msourceID, value);
                                  },
                                ),
                              ),
                            ),
                            IconButton(icon: Icon(Icons.volume_up), onPressed: () {
                                if (meo.volume < 0.95) {
                                  setState(() {
                                    meo.volume += 0.05;
                                  });
                                  libmoc.mnetSetVolume(Global.profile.msourceID, meo.volume);
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