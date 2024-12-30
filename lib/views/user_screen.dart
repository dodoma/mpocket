import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mpocket/common/global.dart';
import 'package:path_provider/path_provider.dart';

class UserScreen extends StatefulWidget {
  const UserScreen({
    super.key,
  });

  @override
  State<UserScreen> createState() => _UserScreenState();
}

class _UserScreenState extends State<UserScreen> {
  List<String> sourceList = [];
  bool _isLoading = true;

  Future<void> listSources() async {
    // 创建正则表达式
    final regExp = RegExp(r'^a[0-9a-fA-F]+$');

    // 获取应用程序文档目录
    Directory appDir = await getApplicationDocumentsDirectory();

    // 列出目录中的文件和子目录
    List<FileSystemEntity> files = appDir.listSync();

    // 筛选匹配正则表达式的文件
    for (var file in files) {
      if (file is Directory) { // 确保是文件而不是目录
        final fileName = file.path.split('/').last;
        if (regExp.hasMatch(fileName)) {
          print('Matched File: ${file.path}');
          sourceList.add(fileName);
        }
      }
    }
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void initState() {
    // TODO: implement initState
    listSources();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading)
    return Scaffold(body: Center(child: CircularProgressIndicator()));
    else return Scaffold(
      appBar: AppBar(
        title: Text('音乐家'),
      ),  
      body: Center(
        child: Column(
          children: [
            Text('xxx'),
            DropdownButton(
              items: sourceList.map((String sourceID) {
                return DropdownMenuItem(child: Text(sourceID), value: sourceID);
              }).toList(),
              value: Global.profile.msourceID,
              onChanged: (String? val) async {
                if (val is String) {
                  Global.profile.msourceID = val;
                  Global.profile.storeDir = Global.profile.appDir + "/${val}/";
                  Global.saveProfile();
                }
              }
            )
          ],
        )
      ),
    );
    //return Text(Language.instance.TAB_MSOURCE);
  }
}
