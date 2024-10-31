import 'package:flutter/material.dart';
//import 'package:flutter/rendering.dart';
import 'package:mpocket/common/global.dart';
import 'package:mpocket/config/language.dart';
import 'package:mpocket/ffi/libmoc.dart' as libmoc;
import 'package:mpocket/models/imsource.dart';
import 'package:mpocket/router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final directory = await getApplicationDocumentsDirectory();  
  libmoc.mocInit(directory.path);
  await Global.init(directory.path);
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
        ChangeNotifierProvider(create: (context) => IMsource()),
        ChangeNotifierProvider(create: (context) => IMonline()),
        ChangeNotifierProvider(create: (context) => IMbanner())
      ],
      child: MaterialApp.router(
        routerConfig: router,
      )
    );
  }
}
