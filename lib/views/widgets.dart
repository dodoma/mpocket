import 'dart:async';
import 'dart:ffi';

import 'package:ffi/ffi.dart';
import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mpocket/config/language.dart';
import 'package:mpocket/ffi/libmoc.dart' as libmoc;
import 'package:mpocket/models/imsource.dart';
import 'package:provider/provider.dart';

typedef NativePlayStepCallback = Void Function(Int, Pointer<Utf8>, Pointer<Utf8>);

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
    OmusicTrack? onListenTrack = context.watch<IMsource>().onListenTrack;
    bool showPlaying = context.watch<IMsource>().showPlaying;

    return Scaffold(
      body: Stack(
        children: [
          widget.child!,
          if (showPlaying && onListenTrack != null) Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            child: Container(
              padding: EdgeInsets.all(10.0),
              color: Colors.grey[400],
              child: NowPlaying()
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
  //late Stream<double> progress;
  final progress = StreamController<double>();
  late final NativeCallable<NativePlayStepCallback> callback = NativeCallable<NativePlayStepCallback>.listener(onResponse);
  late AnimationController avtanimate;
  Timer? _timer;
  bool implaying = false;
  bool paused = false;

  void onResponse(int ok, Pointer<Utf8> errmsgPtr, Pointer<Utf8> responsePtr) {
    print('on play STEP');

    OmusicTrack? onListenTrack = context.read<IMsource>().onListenTrack;
    if (onListenTrack != null) {
      onListenTrack.pos += 2;
      double percent = onListenTrack.pos / onListenTrack.length;
      progress.add(percent);
      if (percent >= 1) {
        print('play done');
        //callback.close();
      }
      //avtanimate.forward(from: 0);
      implaying = true;
    }
  }

  @override
  void initState() {
    super.initState();
    avtanimate = AnimationController(vsync: this, duration: Duration(seconds: 10))..repeat();
    //avtanimate.forward();
    _startTimer();

    libmoc.mnetOnStep(Provider.of<IMsource>(context, listen: false).deviceID, callback.nativeFunction);
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 3), (timer) {
      if (!implaying) {
        print("not playing, stop.");
        avtanimate.stop();
        _timer?.cancel();
      } else {
        implaying = false;
      }
    });
  }

  @override
  void dispose() {
    avtanimate.dispose();
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    OmusicTrack? onListenTrack = context.watch<IMsource>().onListenTrack;

    if (onListenTrack != null) {
      return Container(
        width: MediaQuery.of(context).size.width,
        child: InkWell(
          child: Row(
            children: [
              //Image.asset(onListenTrack.cover, width: 60),
              AnimatedBuilder(
                animation: avtanimate,
                builder: (context, child) {
                  return RotationTransition(turns: avtanimate, child: CircleAvatar(backgroundImage: AssetImage(onListenTrack.cover), radius: 30,));
                  //return RotationTransition(turns: Tween<double>(begin: 0.0, end: 0.2).animate(avtanimate), child: CircleAvatar(backgroundImage: AssetImage(onListenTrack.cover), radius: 30,));
                  //return Transform.rotate(angle: avtanimate.value * 2 * pi, child: CircleAvatar(backgroundImage: AssetImage(onListenTrack.cover), radius: 30,));
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
                    //LinearProgressIndicator(value: onListenTrack.progress, minHeight: 2,),
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
                          libmoc.mnetResume(Provider.of<IMsource>(context, listen: false).deviceID);
                          setState(() {
                            paused = false;
                          });
                        }))
                        : Expanded(flex: 1, child: IconButton(icon: Icon(Icons.pause), onPressed: () {
                          libmoc.mnetPause(Provider.of<IMsource>(context, listen: false).deviceID);
                          setState(() {
                            paused = true;
                          });
                        })),
                      const Gap(8),
                      Expanded(flex: 1, child: IconButton(icon: Icon(Icons.skip_next), onPressed: () {
                        libmoc.mnetNext(Provider.of<IMsource>(context, listen: false).deviceID);
                      },))
                    ],)
                  ],
                ),
              )
            ],
          ),
          onTap: () {
            context.read<IMsource>().turnOffPlaying();
            context.push('/now_playing');
          },
        ),
      );
    } else return const Placeholder();
  }
}