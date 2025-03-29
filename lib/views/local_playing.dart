import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:audio_metadata_extractor/audio_metadata_extractor.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mpocket/common/global.dart';
import 'package:mpocket/models/imlocal.dart';
import 'package:mpocket/models/imsource.dart';
import 'package:mpocket/models/teachnote.dart';
import 'package:mpocket/views/music_album_screen.dart';
import 'package:mpocket/views/music_artist_screen.dart';
import 'package:provider/provider.dart';

class IconMenuItem {
  final IconData icon;
  final Color color;
  final VoidCallback? onPressed;

  IconMenuItem ({
    required this.icon,
    required this.color,
    required this.onPressed,
  });
}

class LocalPlayingScreen extends StatefulWidget {
  const LocalPlayingScreen({super.key});

  @override
  State<LocalPlayingScreen> createState() => _LocalPlayingScreenState();
}

class _LocalPlayingScreenState extends State<LocalPlayingScreen> {
  final progress = StreamController<double>();
  bool paused = false;
  bool _dragging = false;

  bool _isloading = true;
  late List<TeachNote> notes; // 所有教学列表
  late TeachNote trackNote;   // 当前播放文件的教学列表
  int noteIndex = 0;          // 当前显示的教学点
  bool noteSetted = false;    // 当前教学点编辑指示

  String dummys = '''
[
    {"trackidA": [[12, 32], [36, 45], [55, 98]]},
    {"trackidB": [[12, 32], [36, 45], [55, 98]]}
]
''';


  final LayerLink _linkA = LayerLink();
  final LayerLink _linkB = LayerLink();

  OverlayEntry? _entryA;
  OverlayEntry? _entryB;

  Future<void> _fetchData() async {
    List<dynamic> rawList = jsonDecode(dummys);
    notes = rawList.map((e) => TeachNote.fromJson(e)).toList();
    _isloading = false;
  }


  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  @override
  void dispose() {
    _removeMenuA();
    _removeMenuB();
    progress.close();
    super.dispose();
  }

  void _removeMenuA() {
    _entryA?.remove();
    _entryA = null;
  }

  void _removeMenuB() {
    _entryB?.remove();
    _entryB = null;
  }

  void _toggleMenuA(secStart, secEnd) {
    _removeMenuB();

    if (_entryA == null) {
      final List<IconMenuItem> menuItems = [
        IconMenuItem(
          icon: Icons.looks_one, 
          color: noteIndex == 1 ? 
            Colors.green
            : trackNote.points[0].b != 0 ?
              Colors.black
              : Colors.grey,
          onPressed: () {
            setState(() {
              noteIndex = 1;
            });
            if (trackNote.points[0].b != 0) {
              context.read<IMlocal>().seekTo(trackNote.points[0].a);
              context.read<IMlocal>().resetStartPoint(trackNote.points[0].a);
              context.read<IMlocal>().resetEndPoint(trackNote.points[0].b);
            }
          }
        ),
        IconMenuItem(
          icon: Icons.looks_two, 
          color: noteIndex == 2 ? 
            Colors.green
            : trackNote.points[1].b != 0 ?
              Colors.black
              : Colors.grey,
          onPressed: () {
            setState(() {
              noteIndex = 2;
            });
            if (trackNote.points[1].b != 0) {
              context.read<IMlocal>().seekTo(trackNote.points[1].a);
              context.read<IMlocal>().resetStartPoint(trackNote.points[1].a);
              context.read<IMlocal>().resetEndPoint(trackNote.points[1].b);
            }
          }
        ),
        IconMenuItem(
          icon: Icons.looks_3, 
          color: noteIndex == 3 ? 
            Colors.green
            : trackNote.points[2].b != 0 ?
              Colors.black
              : Colors.grey,
          onPressed: () {
            setState(() {
              noteIndex = 3;
            });
            if (trackNote.points[2].b != 0) {
              context.read<IMlocal>().seekTo(trackNote.points[2].a);
              context.read<IMlocal>().resetStartPoint(trackNote.points[2].a);
              context.read<IMlocal>().resetEndPoint(trackNote.points[2].b);
            }
          }
        ),
        IconMenuItem(
          icon: Icons.save, 
          color: noteSetted ? Colors.black : Colors.grey,
          onPressed: noteSetted ? () {
            setState(() {
              noteSetted = false;
            });
            if (noteIndex >= 0 && noteIndex <= 3) {
              // 保存当前教学点（首次使用保存至卡槽1）
              int saveindex = noteIndex == 0 ? 0 : noteIndex - 1;
              trackNote.points[saveindex].a = secStart;
              trackNote.points[saveindex].b = secEnd;
              int nindex = Global.tnotes.indexWhere((note) => note.id == trackNote.id);
              if (nindex != -1) Global.tnotes[nindex] = trackNote;
              else Global.tnotes.add(trackNote);
              Global.saveTeachNotes();
            }
          } : null,
        ),
      ];
      _entryA = _createMenu(_linkA, menuItems, () {_removeMenuA();});
      Overlay.of(context).insert(_entryA!);
    } else _removeMenuA();
  }

  void _toggleMenuB() {
    _removeMenuA();

    if (_entryB == null) {
      final List<IconMenuItem> menuItems = [
        IconMenuItem(
          icon: Icons.remove, 
          color: Colors.black,
          onPressed: () {
            context.read<IMlocal>().speedDown();
          }
        ),
        IconMenuItem(
          icon: Icons.crop_free, 
          color: Colors.black,
          onPressed: () {
            context.read<IMlocal>().speedNormal();
          }
        ),
      ];
      _entryB = _createMenu(_linkB, menuItems, () {_removeMenuB();});
      Overlay.of(context).insert(_entryB!);
    } else _removeMenuB();
  }

  OverlayEntry _createMenu(LayerLink link, List<IconMenuItem> menuItems, VoidCallback onClose) {
    return OverlayEntry(
      builder: (context) => Positioned(
        width: 48,
        child: CompositedTransformFollower(
          link: link,
          offset: Offset(0, -(menuItems.length * 48 + 4).toDouble()),
          showWhenUnlinked: false,
          child: Material(
            elevation: 6,
            borderRadius: BorderRadius.circular(8),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: menuItems.map((item) => IconButton(onPressed: item.onPressed != null ? () {item.onPressed!(); onClose();} : null, icon: Icon(item.icon, color: item.color))).toList(),
            )
          )
        )
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    double containerWidth = MediaQuery.of(context).size.width;
    String? id = context.watch<IMlocal>().onListenID;
    String? url = context.watch<IMlocal>().onListenURL;
    String? cover = context.read<IMlocal>().onListenCover;
    AudioMetadata? mdata = context.read<IMlocal>().onListenTrack;
    Duration duration = context.watch<IMlocal>().duration;
    Duration position = context.watch<IMlocal>().position;
    Duration positionStart = context.watch<IMlocal>().positionStart;
    Duration positionEnd = context.watch<IMlocal>().positionEnd;
    double volume = context.read<IMlocal>().volume;
    String trackName = (mdata == null || mdata.trackName == null) ? '未知曲目': mdata.trackName!;
    String artistName = mdata == null ? '未知艺术家' : mdata.firstArtists != null ? mdata.firstArtists! : mdata.secondArtists != null ? mdata.secondArtists! : '未知艺术家';
    //String artistName = (mdata == null || mdata.firstArtists == null) ? '未知艺术家' : mdata.firstArtists!;
    String albumName = (mdata == null || mdata.album == null) ? '未知专辑' : mdata.album!;

    double fval = duration.inMilliseconds > 0 ? position.inMilliseconds / duration.inMilliseconds : 0.0;
    if (!_dragging && fval >= 0.0 && fval <= 1.0) progress.add(fval);

    if (_isloading) return Scaffold(body: Center(child: CircularProgressIndicator()));
    else if (url == null) return Scaffold(body: Center(child: CircularProgressIndicator()));
    else {
      int nindex = Global.tnotes.indexWhere((note) => note.id == id);
      //int nindex = 1;
      if (nindex != -1) {
        setState(() {
          trackNote = Global.tnotes[nindex];   
        });
      } else trackNote = TeachNote(id: id!, points: [TeachPoint(0, 0), TeachPoint(0, 0), TeachPoint(0, 0)]);

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
                            positionStart.inMilliseconds > 0 ?
                              Column(
                                children: [
                                  Text("${(positionStart.inSeconds ~/ 60).toString().padLeft(2, '0')}:${(positionStart.inSeconds % 60).toString().padLeft(2, '0')}",
                                    style: TextStyle(fontSize:12, fontWeight: FontWeight.w700, color: Colors.blue),
                                  ),
                                  IconButton(icon: Icon(Icons.arrow_right, size: 28, color: Colors.blue,), onPressed: () {
                                    context.read<IMlocal>().unsetStartPoint();
                                  },),
                                ],
                              )
                              : IconButton(icon: Icon(Icons.arrow_right, size: 32), onPressed: () {
                                context.read<IMlocal>().setStartPoint();
                                setState(() {
                                  noteSetted = true;
                                });
                              },),
                            positionEnd.inMilliseconds > 0 ?
                              Column(
                                children: [
                                  Text("${(positionEnd.inSeconds ~/ 60).toString().padLeft(2, '0')}:${(positionEnd.inSeconds % 60).toString().padLeft(2, '0')}", 
                                    style: TextStyle(fontSize:12, fontWeight: FontWeight.w700, color: Colors.blue),
                                  ),
                                  IconButton(icon:Icon(Icons.arrow_left, size: 28, color: Colors.blue,), onPressed: () {
                                    context.read<IMlocal>().unsetEndPoint();
                                  },),
                                ],
                              )
                            : IconButton(icon:Icon(Icons.arrow_left, size: 32), onPressed: () {
                                context.read<IMlocal>().setEndPoint();
                                setState(() {
                                  noteSetted = true;
                                });
                              },),
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
                            //FloatingMenuSeek(),
                            CompositedTransformTarget(
                              link: _linkA,
                              child: IconButton(icon: Icon(Icons.school), onPressed: () {
                                _toggleMenuA(positionStart.inSeconds, positionEnd.inSeconds);
                              },),
                            ),
                            CompositedTransformTarget(
                              link: _linkB,
                              child: IconButton(icon: Icon(Icons.speed), onPressed: () {
                                _toggleMenuB();
                              },),
                            ),
                            IconButton(icon: Icon(Icons.volume_down), onPressed: () {
                                if (volume > 0.1) {
                                    volume -= 0.05;
                                    context.read<IMlocal>().setVolume(volume);
                                }
                            },),
                            Container(
                              width: 130,  
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
