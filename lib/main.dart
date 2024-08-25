import 'package:flutter/material.dart';
import 'package:mpocket/config/language.dart';
import 'package:mpocket/router.dart';
import 'package:provider/provider.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Language.initialize(language: LanguageData(code: 'zh_CN', name: '中文', country: '中国'));

  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => Language.instance,
        ),
      ],
      child: MaterialApp(
        title: 'Mpocket Music Player',
        home: const StartApp(),
      )
    );
  }
}

class StartApp extends StatefulWidget {
  const StartApp({super.key,});

  @override
  State<StartApp> createState() => _StartAppState();
}

class _StartAppState extends State<StartApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: router,
    );
  }
}
