import 'package:flutter/material.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({
    super.key,
  });

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('音乐家'),
      ),  
      body: Center(
        child: Text('xxx')
      ),
    );
    //return Text(Language.instance.TAB_MSOURCE);
  }
}
