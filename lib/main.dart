import 'package:flutter/material.dart';
import 'package:flutter_foreground_service/flutter_foreground_service.dart';
import 'package:mpocket/common/global.dart';
import 'package:mpocket/config/language.dart';
import 'package:mpocket/ffi/libmoc.dart' as libmoc;
import 'package:mpocket/models/imlocal.dart';
import 'package:mpocket/models/imsource.dart';
import 'package:mpocket/router.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final directory = await getApplicationDocumentsDirectory();  
  libmoc.mocInit(directory.path);

  await Global.init(directory.path);
  await Language.initialize(language: Global.profile.language);

  runApp(const MainApp());
  //startForegroundService();
}

void startForegroundService() async {
  ForegroundService().start();
  debugPrint("Started FOREGROUND service");
}

class MainApp extends StatefulWidget {
  const MainApp({super.key});

  @override
  State<MainApp> createState() => _MainAppState();
}

class _MainAppState extends State<MainApp> {
  @override
  void dispose() {
    ForegroundService().stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    //debugPaintSizeEnabled = true;
    //return MaterialApp.router(routerConfig: router,);
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => IMsource()),
        ChangeNotifierProvider(create: (context) => IMlocal()),
        ChangeNotifierProvider(create: (context) => IMonline()),
        ChangeNotifierProvider(create: (context) => IMnotify()),
        ChangeNotifierProvider(create: (context) => IMbanner())
      ],
      child: MaterialApp.router(
        routerConfig: router,
      )
    );
  }
}
