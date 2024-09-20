import 'package:flutter/material.dart';
import 'package:gap/gap.dart';

class _SkeletonScreenState extends StatefulWidget {
  const _SkeletonScreenState({super.key});
  @override
  State<_SkeletonScreenState> createState() => __SkeletonScreenStateState();
}
class __SkeletonScreenStateState extends State<_SkeletonScreenState> {
  @override
  Widget build(BuildContext context) {
  double containerWidth = MediaQuery.of(context).size.width * 0.9;

  return Scaffold(
    body: Center(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            // 页面一大框
            width: containerWidth,
            margin: EdgeInsets.only(top: 50, bottom: 30),
            child: Column(
            mainAxisSize: MainAxisSize.min,  
            children: [
              Container(
                // 第一坨
                padding: EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  border: Border.all(color: Colors.grey[400]!),
                  borderRadius: BorderRadius.circular(10)
                ),
                child: Text('xxxxxx')
              ),
              const Gap(10),
              Expanded(
                child: LayoutBuilder(
                  builder: (BuildContext context, BoxConstraints constrains) {
                    return Container(
                      // 第二坨
                      padding: EdgeInsets.all(10),
                      height: constrains.maxHeight,
                      decoration: BoxDecoration(
                        //color: const Color.fromARGB(255, 21, 140, 236),
                        color: Colors.grey[100],
                        border: Border.all(color: Colors.grey[400]!),
                        borderRadius: BorderRadius.circular(10), // 可选：圆角边框
                      ),
                      child: Text('xxxxxx')
                    );
                  }
                )
              )
              ],
            )
          ),
        ],
      )
    )
  );
  }
}

Widget showDeviceScreenOLD(String deviceID, double maxWidth) {
  return Container(
    // 页面一大框
    width: maxWidth,
    margin: EdgeInsets.only(top:50, bottom: 80),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
          Container(
            // 第一坨
            padding: EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border.all(color: Colors.grey[400]!),
              borderRadius: BorderRadius.circular(10)
            ),
            child: Text('xxxxxx'),
          ),
          const Gap(20),
          Text('xxxxxx', style: TextStyle(fontWeight: FontWeight.w700)),
      ],
    ),
  );
}
