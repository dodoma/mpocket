import 'dart:async';
import 'dart:ffi';
import 'dart:io';

import 'package:audio_metadata_extractor/audio_metadata_extractor.dart';
import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mpocket/common/global.dart';
import 'package:mpocket/config/language.dart';
import 'package:mpocket/ffi/libmoc.dart' as libmoc;
import 'package:mpocket/models/imlocal.dart';
import 'package:mpocket/models/imsource.dart';
import 'package:mpocket/models/omusic_playing.dart';
import 'package:provider/provider.dart';

typedef NativePlayStepCallback = Void Function(Pointer<Utf8>, Int, Pointer<Utf8>, Pointer<Utf8>);

class BottomNavigationBarScaffold extends StatefulWidget {
  const BottomNavigationBarScaffold({super.key, this.child});

  final Widget? child;

  @override
  State<BottomNavigationBarScaffold> createState() => _BottomNavigationBarScaffoldState();
}

class _BottomNavigationBarScaffoldState extends State<BottomNavigationBarScaffold> {

  void changeTab(int index) {
    //setState((){
      //currentIndex = index;
      switch (index) {
        case 0:
          context.go('/music');
          break;
        case 1:
          context.go('/msource');
          break;
        case 2:
          context.go('/user');
          break;
      }
    //});
  }

  int _getSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).uri.toString();

    switch (location) {
      case '/music':
        return 0;
      case '/msource':
        return 1;
      case '/user':
        return 2;
      default:
        return 0; // 默认是首页
    }
  }

  @override
  Widget build(BuildContext context) {
    final int selectedIndex = _getSelectedIndex(context);
    bool visible = context.watch<IMbanner>().isVisible;

    return Scaffold(
      body: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(top:0, bottom: 0),
            child: widget.child!
          ),
          if (visible)
            Positioned(
              left: 0,
              right: 0,
              bottom: 0,
              child: Container(
                padding: EdgeInsets.all(10.0),
                color: Colors.grey[400],
                child: Global.profile.phonePlay ? NowPlayingLocal() : NowPlaying()
              )
            )
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
//        type: BottomNavigationBarType.shifting,
        onTap: changeTab,
        currentIndex: selectedIndex,
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.music_note), label: Language.instance.TAB_MUSIC),
          BottomNavigationBarItem(icon: Icon(Icons.storage), label: Language.instance.TAB_MSOURCE),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: Language.instance.TAB_USER),
        ]
      ),
    );
  }
}

class NowPlaying extends StatefulWidget {
  const NowPlaying({super.key});

  @override
  State<NowPlaying> createState() => _NowPlayingState();
}

class _NowPlayingState extends State<NowPlaying> with SingleTickerProviderStateMixin {
  final progress = StreamController<double>();
  late final NativeCallable<NativePlayStepCallback> callback = NativeCallable<NativePlayStepCallback>.listener(onResponse);
  late AnimationController avtanimate;
  bool paused = false;

  void onResponse(Pointer<Utf8> client, int ok, Pointer<Utf8> errmsgPtr, Pointer<Utf8> responsePtr) {
    print('on play STEP s');
    OmusicPlaying? onListenTrack = context.read<IMsource>().onListenTrack;
    if (onListenTrack != null) {
      onListenTrack.pos += 2;
      double percent = onListenTrack.pos / onListenTrack.length;
      progress.add(percent);
    }
  }

  @override
  void initState() {
    super.initState();
    avtanimate = AnimationController(vsync: this, duration: Duration(seconds: 10))..repeat();
    //libmoc.mnetOnStep(Provider.of<IMsource>(context, listen: false).deviceID, callback.nativeFunction);
    libmoc.mnetOnStep(Global.profile.msourceID, callback.nativeFunction);
  }

  @override
  void dispose() {
    progress.close();
    callback.close();
    avtanimate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    OmusicPlaying? onListenTrack = context.watch<IMsource>().onListenTrack;
    final String location = GoRouterState.of(context).uri.toString();

    if (location != "/now_playing" && onListenTrack != null) {
      return Container(
        width: MediaQuery.of(context).size.width,
        child: InkWell(
          child: Row(
            children: [
              //Image.asset(onListenTrack.cover, width: 60),
              AnimatedBuilder(
                animation: avtanimate,
                builder: (context, child) {
                  return RotationTransition(turns: avtanimate, child: CircleAvatar(backgroundImage: FileImage(File(onListenTrack.cover!)), radius: 30,));
                  //return RotationTransition(turns: Tween<double>(begin: 0.0, end: 0.2).animate(avtanimate), child: CircleAvatar(backgroundImage: AssetImage(onListenTrack.cover), radius: 30,));
                  //return Transform.rotate(angle: avtanimate.value * 2 * pi, child: CircleAvatar(backgroundImage: FileImage(File(onListenTrack.cover)), radius: 30,));
                },
              ),
              const Gap(20),
              Expanded(
                child: Column(
                  children: [
                    StreamBuilder<double>(
                      stream: progress.stream, 
                      builder: (context, snapshot) {
                        if (snapshot.hasData) {
                          return LinearProgressIndicator(value: snapshot.data, minHeight: 2,);
                        }
                        return LinearProgressIndicator(valueColor: AlwaysStoppedAnimation(Color.fromRGBO(0x7a, 0x51, 0xe2, 100)));
                      }
                    ),
                    const Gap(10),
                    Row(children: [
                      Expanded(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(onListenTrack.title, textScaler: TextScaler.linear(1.2), overflow: TextOverflow.ellipsis,),
                            Text(onListenTrack.artist)
                          ],
                        ),
                      ),
                      //Spacer(),
                      paused ? 
                        Expanded(flex: 1, child: IconButton(icon: Icon(Icons.play_arrow), onPressed: () {
                          libmoc.mnetResume(Global.profile.msourceID);
                          avtanimate.repeat();
                          setState(() {
                            paused = false;
                          });
                        }))
                        : Expanded(flex: 1, child: IconButton(icon: Icon(Icons.pause), onPressed: () {
                          libmoc.mnetPause(Global.profile.msourceID);
                          avtanimate.stop();
                          setState(() {
                            paused = true;
                          });
                        })),
                      const Gap(8),
                      Expanded(flex: 1, child: IconButton(icon: Icon(Icons.skip_next), onPressed: () {
                        libmoc.mnetNext(Global.profile.msourceID);
                      },))
                    ],)
                  ],
                ),
              )
            ],
          ),
          onTap: () {
            context.read<IMbanner>().turnOffBanner();
            context.push('/now_playing');
          },
        ),
      );
    } else return SizedBox.shrink();
    //} else Navigator.pop(context);
  }
}

class NowPlayingLocal extends StatefulWidget {
  const NowPlayingLocal({super.key});

  @override
  State<NowPlayingLocal> createState() => _NowPlayingLocalState();
}

class _NowPlayingLocalState extends State<NowPlayingLocal> with SingleTickerProviderStateMixin {
  bool paused = false;
  late AnimationController avtanimate;

  @override
  void initState() {
    avtanimate = AnimationController(vsync: this, duration: Duration(seconds: 10)) ..repeat();
    super.initState();
  }

  @override
  void dispose() {
    avtanimate.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String? url = context.watch<IMlocal>().onListenURL;
    String? cover = context.read<IMlocal>().onListenCover;
    AudioMetadata? mdata = context.read<IMlocal>().onListenTrack;
    Duration duration = context.watch<IMlocal>().duration;
    Duration position = context.watch<IMlocal>().position;

    final String location = GoRouterState.of(context).uri.toString();
    double progress = duration.inMilliseconds > 0 ? position.inMilliseconds / duration.inMilliseconds : 0.0;

    if (location != "/local_playing" && url != null) {      
      return Container(
        width: MediaQuery.of(context).size.width,
        child: InkWell(
          child: Row(
            children: [
              AnimatedBuilder(
                animation: avtanimate, 
                builder: (context, child) {
                  return RotationTransition(turns: avtanimate, child: CircleAvatar(backgroundImage: FileImage(File(cover!)), radius: 30,));
                }
              ),
              const Gap(20),
              Expanded(
                child: Column(
                  children: [
                    LinearProgressIndicator(value: progress),
                    const Gap(10),
                    Row(children: [
                      Expanded(
                        flex: 7,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(mdata!.trackName!, textScaler: TextScaler.linear(1.2), overflow: TextOverflow.ellipsis,),
                            Text(mdata.firstArtists!)
                          ],
                        ),
                      ),
                      paused ?
                        Expanded(flex: 1, child: IconButton(icon: Icon(Icons.play_arrow), onPressed: () async {
                          await context.read<IMlocal>().resume();  
                          avtanimate.repeat();
                          setState(() {
                            paused = false;
                          });
                        }))
                      : Expanded(flex: 1, child: IconButton(icon: Icon(Icons.pause), onPressed: () async {
                          await context.read<IMlocal>().pause();
                          avtanimate.stop();
                          setState(() {
                            paused = true;
                          });
                      })),
                      const Gap(8),
                      Expanded(flex: 1, child: IconButton(icon: Icon(Icons.skip_next), onPressed: () {
                        context.read<IMlocal>().playNext(context);
                      },))
                    ],),
                  ],
                ),
              ),
            ],
          ),
          onTap: () {
            context.read<IMbanner>().turnOffBanner();
            context.push("/local_playing");
          },
        ),
      );
    } else return SizedBox.shrink();
  }
}