import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';
import 'package:mpocket/common/global.dart';
import 'package:mpocket/config/language.dart';
import 'package:mpocket/models/msource.dart';
import 'package:mpocket/router.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Global.init();
  await Language.initialize(language: LanguageData(code: Global.profile.local, name: '', country: ''));

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    //debugPaintSizeEnabled = true;
    //return MaterialApp.router(routerConfig: router,);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => Msource()),
      ],
      child: MaterialApp.router(
        routerConfig: router,
      )
    );
  }
}
