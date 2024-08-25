import 'package:flutter/material.dart';
import 'package:mpocket/config/language.dart';

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
    return ElevatedButton(
          onPressed:() async {
            await Language.instance.set(value: LanguageData(code: 'en_US', name: 'English', country: 'United States'));
          },
          child: const Text('changde'),
      );
  }
    //return Text(Language.instance.TAB_MSOURCE);
  //}
}
