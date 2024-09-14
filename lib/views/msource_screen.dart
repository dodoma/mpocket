import 'dart:async';

import 'package:flutter/material.dart';
import 'package:form_controller/form_controller.dart';
import 'package:gap/gap.dart';
import 'package:list_picker/list_picker.dart';
import 'package:mpocket/ffi/libmoc.dart' as libmoc;
import 'package:mpocket/models/msource.dart';
import 'package:provider/provider.dart';
import 'package:wifi_scan/wifi_scan.dart';

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

//  Widget configDeviceScreen(String deviceIP) {
//    late FormController _fmctl;
//    return Scaffold(
//        body: Center(
//            child: ConfigDeviceScreen()));
// }


class ConfigDeviceScreen extends StatefulWidget {
  final String deviceIP;

  const ConfigDeviceScreen ({ Key? key, required this.deviceIP }): super(key: key);

  @override
  State<ConfigDeviceScreen> createState() => _ConfigDeviceScreenState();
}

class _ConfigDeviceScreenState extends State<ConfigDeviceScreen> {

  late FormController _formctl;
  late Future<String> sourceID = libmoc.mocDiscovery();

  FocusNode focusNode1 = FocusNode();
  FocusNode focusNode2 = FocusNode();
  FocusNode focusNode3 = FocusNode();
  List<WiFiAccessPoint> accessPoints = <WiFiAccessPoint>[];
  bool searching = true;

  @override
  void initState() {
    super.initState();
    _formctl = FormController();

    scanWifiAP();                            
                          
    Timer(Duration(seconds: 5), () async {
      await getScanResults();
      setState(() {
        searching = false;
      });
    });
  }

  @override
  void dispose() async {
    await _formctl.dispose();
    super.dispose();
  }

  scanWifiAP() async {
    // check platform support and necessary requirements
    final can = await WiFiScan.instance.canStartScan(askPermissions: true);
    switch(can) {
    case CanStartScan.yes:
      // start full scan async-ly
      print('start scanning wifi ap...');
      final isScanning = await WiFiScan.instance.startScan();
      break;
    default: 
      print('cant scan wifi ap');
      break;
    }
  }

  Future<bool> canGetScanResults() async {
    final can = await WiFiScan.instance.canGetScannedResults(askPermissions: true);
    if (can != CanGetScannedResults.yes) {
      accessPoints = <WiFiAccessPoint> [];
      return false;
    }
    return true;
  }

  Future<bool?> showTipDialog() {
    return showDialog<bool>(
      context: context,
       builder: (context) {
        return AlertDialog(
          title: Text('提示'),
          content: Text('请选择常用的热点名称'),
          actions:<Widget> [
            TextButton(onPressed: (){Navigator.of(context).pop();}, child: Text('知道了'))
          ]
        );
       }
    );
  }

  getScanResults() async {
    if (await canGetScanResults()) {
      final results = await WiFiScan.instance.getScannedResults();
      setState(() => accessPoints = results);
      print(results[0].toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Form(
        key: _formctl.key,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            FutureBuilder<String>(
              future: sourceID,
              builder: (BuildContext context, AsyncSnapshot<String> value) {
              final displayxxx = (value.hasData) ?  value.data : 'loading';
            return Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget> [
                Text('配置音源 xx + ${displayxxx}', textAlign: TextAlign.left, textScaler: TextScaler.linear(1.2), style: TextStyle(fontWeight: FontWeight.w700)),
                if (this.searching == true) ...[
                  SizedBox(
                    height: 5,
                    width: 100,
                    child: LinearProgressIndicator(valueColor: AlwaysStoppedAnimation(Color.fromRGBO(0x7a, 0x51, 0xe2, 100)),)
                  )
                ],
                const Gap(50),
                Row(
                  children: [ 
                    SizedBox(width: 260, child: ListPickerField(label: '热点名称', items: [
                      //...accessPoints.map((ap){return ap.ssid;}).toList(),
                      ...accessPoints.where((ap) => ap.ssid.isNotEmpty).map((ap){return ap.ssid;}).toList(),
                      ],
                      controller: _formctl.controller('apname'),
                      isRequired: true,
                    )),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: () async {
                          await scanWifiAP();                            
                          setState(() {
                            searching = true;
                          });
                          Timer(Duration(seconds: 5), () async {
                            await getScanResults();
                            setState(() {
                              searching = false;
                            });
                          });
                      },
                    ),
                  ]
                ),
                const Gap(20),
                Row(
                   children: [
                     const Text('热点密码'),
                     const Gap(20),
                     SizedBox(width: 200, child: TextFormField(
                      controller: _formctl.controller('appasswd'), 
                      validator: (v){return v!.trim().isNotEmpty ? null : '密码不能为空';},
                      focusNode: focusNode2,
                    )),
                   ],
                 ),
                const Gap(20),
                Row(
                   children: [
                     const Text('音源命名'),
                     const Gap(20),
                     SizedBox(width: 200, child: TextFormField(
                      controller: _formctl.controller('deviceName', initialText: '默认音源'),
                      focusNode: focusNode3,
                    )),
                   ],
                 ),
                const Gap(30),
                Row(
                  children: [
                    ElevatedButton(
                      style: ButtonStyle(
                        padding: WidgetStatePropertyAll(EdgeInsets.fromLTRB(70, 10, 70, 10)), 
                        backgroundColor: WidgetStatePropertyAll<Color>(Color.fromRGBO(0x7a, 0x51, 0xe2, 100),
                      )),
                      onPressed: () async {
                        debugPrint('xxxxx' + _formctl.value('apname'));
                        focusNode1.unfocus();
                        focusNode2.unfocus();
                        focusNode3.unfocus();
                        if (_formctl.value('apname').isEmpty) {
                          await showTipDialog();
                        } else {
                          if (_formctl.validate()) {
                            print('验证通过');
                          }
                          libmoc.wifiSet(value.data!, _formctl.value('apname'), _formctl.value('appasswd'), _formctl.value('deviceName'));
                        }
                      },
                      child: Text('确认', style: TextStyle(color: Colors.white))
                    )
                  ]
                ),
              ],
            );

              },
            ),
          ],
        )
      )
    );
  }
}

Widget showDeviceScreen(String deviceID) {
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
      return ConfigDeviceScreen(deviceIP: source.configable);
    } else if (source.defaultDevice.isNotEmpty) {
      return showDeviceScreen(source.defaultDevice);
    } else {
      return noDeviceScreen();
    }
  }
}
