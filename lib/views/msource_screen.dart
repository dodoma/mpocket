import 'package:flutter/material.dart';
import 'package:gap/gap.dart';
import 'package:mpocket/models/msource.dart';
import 'package:provider/provider.dart';

class noDeviceScreen extends StatelessWidget {
  const noDeviceScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
               Text('无音源设备', textScaler: TextScaler.linear(1.8),),
               const Gap(20),
               Text('打开音源电源后连接音源 wifi 进行配置', style: TextStyle(fontWeight: FontWeight.w700)),
            ],
        )
      )
    );
  }
}

Widget configDevice(String deviceID) {
  return Scaffold(
      body: Center(
          child: Text('配置设备' + deviceID)));
}

Widget showDevice(String deviceID) {
  return Scaffold(
      body: Center(
          child: Text('展示设备' + deviceID)));
}

class MsourceScreen extends StatefulWidget {
  const MsourceScreen({
    super.key,
  });

  @override
  State<MsourceScreen> createState() => _MsourceScreenState();
}

class _MsourceScreenState extends State<MsourceScreen> {
  @override
  Widget build(BuildContext context) {
    final Msource source = Provider.of<Msource>(context);

    if (source.configable.isNotEmpty) {
      return configDevice(source.configable);
    } else if (source.defaultDevice.isNotEmpty) {
      return showDevice(source.defaultDevice);
    } else {
      return noDeviceScreen();
    }
  }
}
