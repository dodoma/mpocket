import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:go_router/go_router.dart';
import 'package:mpocket/config/language.dart';
import 'package:mpocket/models/imsource.dart';
import 'package:provider/provider.dart';

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

class _NowPlayingState extends State<NowPlaying> {
  @override
  Widget build(BuildContext context) {
    OmusicTrack? onListenTrack = context.watch<IMsource>().onListenTrack;

    if (onListenTrack != null) {
      return Container(
        width: MediaQuery.of(context).size.width,
        child: InkWell(
          child: Row(
            children: [
              Image.asset(onListenTrack.cover, width: 60),
              const Gap(20),
              Expanded(
                child: Column(
                  children: [
                    LinearProgressIndicator(value: 0.3, minHeight: 2,),
                    const Gap(10),
                    Row(children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(onListenTrack.title, textScaler: TextScaler.linear(1.2),),
                          Text(onListenTrack.artist)
                        ],
                      ),
                      Spacer(),
                      Icon(Icons.pause),
                      const Gap(10),
                      Icon(Icons.skip_next)
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