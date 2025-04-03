import 'dart:io';

import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mpocket/common/global.dart';
import 'package:mpocket/config/language.dart';
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
  late Set<LanguageData> languages;
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

    languages = await Language.instance.available;

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
            Text('Music Source List'),
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
            ),
            const Gap(20),
            Text('Language'),
            DropdownButton(
              items: languages.map((lang) {
                return DropdownMenuItem(child: Text(lang.name), value: lang.code);
              }).toList(),
              value: Global.profile.language.code,
              onChanged: (String? val) async {
                if (val is String) {
                  LanguageData langa = languages.firstWhere(
                    (lang) => lang.code == val,
                    orElse: () => LanguageData(code: 'en_US', name: 'English', country: 'United States'),
                  );

                  Global.profile.language = langa;
                  Global.saveProfile();
                  Language.instance.set(value: langa);
                }
              }
            ),
          ],
        )
      ),
    );
    //return Text(Language.instance.TAB_MSOURCE);
  }
}
