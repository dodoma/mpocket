import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mpocket/config/language.dart';


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

    return Scaffold(
      body: widget.child,
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
